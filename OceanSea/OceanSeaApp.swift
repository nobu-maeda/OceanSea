//
//  OceanSeaApp.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/15.
//

import SwiftUI

@main
struct OceanSeaApp: App {
    @State var network: Network
    
    init() {
        initTracingForOslog(level: .trace, logTimestamp: false, logLevel: true)
        if let readNetwork = NetworkStorage.read() {
            network = readNetwork
        } else {
            network = .signet
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(network: network)
        }
    }
}
