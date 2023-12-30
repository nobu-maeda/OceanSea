//
//  WalletView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct WalletView<T: FatCrabProtocol>: View {
    enum WalletNavigationDestination: Hashable {
        case send
        case receive
        case showSeedWords
        case newWallet
    }
    
    @ObservedObject var fatCrabModel: T
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TitleValueHStack(title: "Total Funds in Wallet", value: "\(fatCrabModel.totalBalance)")
                    TitleValueHStack(title: "Allocated Amount", value: "\(fatCrabModel.allocatedAmount)")
                    TitleValueHStack(title: "Spendable Balance", value: "\(fatCrabModel.spendableBalance)")
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
                        fatCrabModel.updateBalances()
                    }
                }
            })
            .navigationDestination(for: WalletNavigationDestination.self) { destination in
                switch destination {
                case .send:
                    SendView(fatCrabModel: fatCrabModel)
                case .receive:
                    ReceiveView(fatCrabModel: fatCrabModel)
                case .showSeedWords:
                    ShowSeedsView(fatCrabModel: fatCrabModel)
                case .newWallet:
                    EnterSeedsView(fatCrabModel: fatCrabModel)
                    
                }
            }
        }
    }
}
#Preview {
    WalletView(fatCrabModel: FatCrabMock())
}
