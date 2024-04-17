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
    
    @Binding var model: any FatCrabProtocol
    
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
                    NavigationLink("Enter Seed Words & Reset Wallet", value: WalletNavigationDestination.newWallet)
                }
            }
            .navigationTitle("Wallet")
            .navigationDestination(for: WalletNavigationDestination.self) { destination in
                switch destination {
                case .send:
                    SendView().environment(\.fatCrabModel, model)
                case .receive:
                    ReceiveView().environment(\.fatCrabModel, model)
                case .showSeedWords:
                    ShowSeedsView().environment(\.fatCrabModel, model)
                case .newWallet:
                    EnterSeedsView(model: $model)
                }
            }
            .refreshable {
                await updateWalletView()
            }
            .onAppear() {
                Task {
                    await updateWalletView()
                }
            }
            .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
        }
    }
    
    func updateWalletView() async {
        do {
            try await model.updateBalances()
            _ = try await model.walletGetHeight()
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

#Preview {
    @State var fatCrabMock: any FatCrabProtocol = FatCrabMock()
    return WalletView(model: $fatCrabMock)
}
