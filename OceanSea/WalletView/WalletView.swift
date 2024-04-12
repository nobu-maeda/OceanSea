//
//  WalletView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct WalletView: View {
    enum WalletNavigationDestination: Hashable {
        case send
        case receive
        case showSeedWords
        case newWallet
    }
    
    @Environment(\.fatCrabModel) var model
    
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TitleValueHStack(title: "Confirmed Amount", value: "\(model.confirmedAmount)")
                    TitleValueHStack(title: "Trusted Pending Amount", value: "\(model.trustedPendingAmount)")
                    TitleValueHStack(title: "Untrusted Pending Amount", value: "\(model.untrustedPendingAmount)")
                    TitleValueHStack(title: "Allocated Amount", value: "\(model.allocatedAmount)")
                    TitleValueHStack(title: "Spendable Balance*", value: "\(model.confirmedAmount + model.trustedPendingAmount - model.allocatedAmount)")
                }
                Section {
                    TitleValueHStack(title: "Current Block Height", value: "\(model.blockHeight)")
                }
                Section {
                    NavigationLink("Send Funds", value: WalletNavigationDestination.send)
                    NavigationLink("Receive Funds", value: WalletNavigationDestination.receive)
                }
                Section {
                    NavigationLink("Show Seed Words", value: WalletNavigationDestination.showSeedWords)
                    NavigationLink("Delete Wallet & Enter new Seed", value: WalletNavigationDestination.newWallet)
                }
            }
            .navigationTitle("Wallet")
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh Wallet", systemImage: "arrow.clockwise.circle") {
                        updateBalances()
                    }
                }
            })
            .navigationDestination(for: WalletNavigationDestination.self) { destination in
                switch destination {
                case .send:
                    SendView()
                case .receive:
                    ReceiveView()
                case .showSeedWords:
                    ShowSeedsView()
                case .newWallet:
                    EnterSeedsView()
                    
                }
            }
            .onAppear() {
                updateBalances()
            }
            .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
        }
    }
    
    private func updateBalances() {
        Task {
            do {
                try await model.updateBalances()
            } catch let fatCrabError as FatCrabError {
                alertTitleString = "Error"
                alertBodyString = fatCrabError.description()
                showAlert = true
            }
            catch {
                alertTitleString = "Error"
                alertBodyString = error.localizedDescription
                showAlert = true
            }
        }
    }
}
#Preview {
    WalletView().environment(\.fatCrabModel, FatCrabMock())
}
