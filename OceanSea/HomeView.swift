//
//  HomeView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct HomeView<T: FatCrabProtocol>: View {
    enum Tab {
        case wallet, book, orders, relays
    }
    
    @ObservedObject var fatCrabModel: T
    @State private var selectedTab: Tab = .wallet
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WalletView(fatCrabModel: fatCrabModel)
                .tabItem {
                    Label("Wallet", systemImage: "bitcoinsign.square")
                }
                .tag(Tab.wallet)
            
            BookView(fatCrabModel: fatCrabModel)
                .tabItem {
                    Label("Book", systemImage: "text.book.closed")
                }
                .tag(Tab.book)
            
            OrdersView(fatCrabModel: fatCrabModel)
                .tabItem {
                    Label("Orders", systemImage: "list.bullet")
                }
                .tag(Tab.orders)
            
            RelaysView(fatCrabModel: fatCrabModel)
                .tabItem {
                    Label("Relays", systemImage: "network")
                }
                .tag(Tab.relays)
        }
    }
}

#Preview {
    HomeView(fatCrabModel: FatCrabMock())
}
