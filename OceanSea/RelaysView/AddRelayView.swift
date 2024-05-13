//
//  AddRelayView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/02/06.
//

import SwiftUI

struct AddRelayView: View {
    private enum FocusedField: Hashable {
        case relayUrl
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.fatCrabModel) var model
    
    @State private var relayUrlString = ""
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var isBusy = false
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    var body: some View {
        NavigationStack {
            List {
                
                TextField("Relay URL - wss://", text: $relayUrlString)
                    .focused($focusedField, equals: .relayUrl)
                    .onSubmit {
                        if validateRelayUrl() != nil {
                            addRelay()
                        }
                    }
                    
                    .disableAutocorrection(true)
#if os(iOS)
                    .textInputAutocapitalization(.never)
#endif
            }
            .navigationTitle("Add Relay")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        self.addRelay()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            }
            .modifier(ActivityIndicatorModifier(isLoading: isBusy))
            .alert(alertTitleString, isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}}, message: {
                    Text(alertBodyString)
            })
        }
        .onAppear(perform: { focusedField = .relayUrl })
#if os(macOS)
        .frame(width: 300, height: 200)
        .fixedSize()
#endif
    }
    
    private func addRelay() {
        guard let relayUrl = validateRelayUrl() else { return }
        let relayAddr = RelayAddr(url: relayUrl.absoluteString, socketAddr: nil)
        
        isBusy = true
        
        Task {
            do {
                try await model.addRelays(relayAddrs: [relayAddr])
                
                Task { @MainActor in
                    isBusy = false
                    dismiss()
                }
            } catch {
                Task { @MainActor in
                    isBusy = false
                    alertTitleString = "Error"
                    alertBodyString = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    private func validateRelayUrl() -> URL? {
        if !relayUrlString.isEmpty {
            if let url = URL(string: relayUrlString) {
                return url
            }
        }
        return nil
    }
}

#Preview {
    AddRelayView()
}
