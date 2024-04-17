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
    
    @Binding var model: any FatCrabProtocol
    
    @State private var selectedTab: Tab = .wallet
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WalletView(model: $model)
                .tabItem {
                    Label("Wallet", systemImage: "bitcoinsign.square")
                }
                .tag(Tab.wallet)
            
            BookView().environment(\.fatCrabModel, model)
                .tabItem {
                    Label("Book", systemImage: "text.book.closed")
                }
                .tag(Tab.book)
            
            TradesView().environment(\.fatCrabModel, model)
                .tabItem {
                    Label("Trades", systemImage: "list.bullet")
                }
                .tag(Tab.orders)
            
            RelaysView().environment(\.fatCrabModel, model)
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
