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
    
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    var body: some View {
        NavigationStack {
            List {
                TextField("Relay URL - wws://", text: $relayUrlString)
                    .focused($focusedField, equals: .relayUrl)
                    .onSubmit {
                        if validateRelayUrl() != nil {
                            addRelay()
                        }
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .navigationTitle("Add Relay")
            .navigationBarTitleDisplayMode(.inline)
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
            .alert(alertTitleString, isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}}, message: {
                    Text(alertBodyString)
            })
        }
        .onAppear(perform: { focusedField = .relayUrl })
    }
    
    private func addRelay() {
        guard let relayUrl = validateRelayUrl() else { return }
        let relayAddr = RelayAddr(url: relayUrl.absoluteString, socketAddr: nil)
        
        Task {
            do {
                try await model.addRelays(relayAddrs: [relayAddr])
                
                Task { @MainActor in
                    dismiss()
                }
            } catch {
                Task { @MainActor in
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
