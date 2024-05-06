//
//  HomeView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct HomeView: View {
    enum Tab {
        case wallet, book, trades, relays
    }
    
    @Binding var model: any FatCrabProtocol
    
    @State private var selectedTab: Tab = .wallet
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WalletView(model: $model)
                .tabItem {
                    Label("Wallet", systemImage: "bitcoinsign.square")
                }
                .tag(Tab.wallet)
            
            BookView(selection: $selectedTab).environment(\.fatCrabModel, model)
                .tabItem {
                    Label("Book", systemImage: "text.book.closed")
                }
                .tag(Tab.book)
            
            TradesView(selection: $selectedTab).environment(\.fatCrabModel, model)
                .tabItem {
                    Label("Trades", systemImage: "list.bullet")
                }
                .tag(Tab.trades)
            
            RelaysView(selection: $selectedTab).environment(\.fatCrabModel, model)
                .tabItem {
                    Label("Relays", systemImage: "network")
                }
                .tag(Tab.relays)
        }
    }
}

#Preview {
    @State var fatCrabModel: any FatCrabProtocol = FatCrabMock()
    return HomeView(model: $fatCrabModel)
}
