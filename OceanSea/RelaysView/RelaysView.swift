//
//  RelaysView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct RelaysView: View {
    @Binding var selection: HomeView.Tab
    @Environment(\.fatCrabModel) var model
    
    @State var showAddRelayToolbarView = false
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.relays, id: \.self) { relay in
                    HStack {
                        Text(relay.url)
                        Spacer()
                        Button {
                            removeRelay(url: relay.url)
                        } label: {
                            Image(systemName: "multiply").foregroundColor(.black)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .toolbar {
                switch selection {
                case .relays:
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            showAddRelayToolbarView.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundColor(.blue)
                        })
                    }
                default:
                    ToolbarItem(placement: .primaryAction) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Nostr Relays")
            .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
        }
        .sheet(isPresented: $showAddRelayToolbarView) {
            AddRelayView()
        }
    }
    
    func removeRelay(url: String) {
        Task {
            do {
                try await model.removeRelay(url: url)
            } catch let fatCrabError as FatCrabError {
                Task { @MainActor in
                    alertTitleString = "Error"
                    alertBodyString = fatCrabError.description()
                    showAlert = true
                }
            }
            catch {
                Task { @MainActor in
                    alertTitleString = "Error"
                    alertBodyString = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    @State var selectedTab = HomeView.Tab.relays
    return RelaysView(selection: $selectedTab).environment(\.fatCrabModel, FatCrabMock(for: .signet))
}
