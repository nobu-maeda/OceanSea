//
//  ContentView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/15.
//

import SwiftUI
import FatcrabTradingFFI

struct ContentView: View {
    var body: some View {
        let url = "testnet.aranguren.org"
        let auth = Auth.none
        let network = Network.regtest
        let trader = Trader(url: url, auth: auth, network: network)
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
