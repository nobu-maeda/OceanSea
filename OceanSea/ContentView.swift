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
        let url = "ssl://electrum.blockstream.info:60002"
        let network = Network.testnet
        let info = BlockchainInfo.electrum(url: url, network: network)
        let trader = Trader(info: info)
        
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
