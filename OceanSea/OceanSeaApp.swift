//
//  OceanSeaApp.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/15.
//

import SwiftUI

@main
struct OceanSeaApp: App {
    init() {
        initTracingForOslog(level: .trace, logTimestamp: false, logLevel: true)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
