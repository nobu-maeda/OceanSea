//
//  WalletView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct WalletView: View {
    enum WalletNavigationDestination: Hashable {
        case showPubkey
        case showSeedWords
        case newWallet
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Total Fund in Wallet")
                    Text("Allocated Fund")
                    Text("Spendable Fund")
                }
                Section {
                    NavigationLink("Show Pubkey", value: WalletNavigationDestination.showPubkey)
                    NavigationLink("Show Seed Words", value: WalletNavigationDestination.showSeedWords)
                    NavigationLink("Delete Wallet & Enter new Seed", value: WalletNavigationDestination.newWallet)
                }
            }
            .navigationTitle("Wallet")
            .navigationDestination(for: WalletNavigationDestination.self) { destination in
                switch destination {
                case .showPubkey:
                    ShowPubkeyView()
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
    WalletView()
}
