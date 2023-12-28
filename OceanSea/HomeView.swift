//
//  HomeView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct HomeView: View {
    enum Tab {
        case wallet, book, orders, relays
    }
    @State private var selectedTab: Tab = .wallet
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WalletView()
                .tabItem {
                    Label("Wallet", systemImage: "bitcoinsign.square")
                }
                .tag(Tab.wallet)
            
            BookView()
                .tabItem {
                    Label("Book", systemImage: "text.book.closed")
                }
                .tag(Tab.book)
            
            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "list.bullet")
                }
                .tag(Tab.orders)
            
            RelaysView()
                .tabItem {
                    Label("Relays", systemImage: "network")
                }
                .tag(Tab.relays)
        }
    }
}

#Preview {
    HomeView()
}
