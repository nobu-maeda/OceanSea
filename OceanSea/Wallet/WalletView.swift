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
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TitleValueHStack(title: "Total Funds in Wallet", value: "\(model.totalBalance)")
                    TitleValueHStack(title: "Allocated Amount", value: "\(model.allocatedAmount)")
                    TitleValueHStack(title: "Spendable Balance", value: "\(model.spendableBalance)")
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
        }
    }
}
#Preview {
    let fatCrabMock = FatCrabMock()
    return WalletView().environment(\.fatCrabModel, fatCrabMock)
}
