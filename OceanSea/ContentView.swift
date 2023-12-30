//
//  ContentView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/15.
//

import SwiftUI
import FatCrabTradingFFI

struct ContentView: View {
    @StateObject var fatCrabModel = FatCrabModel()
    
    var body: some View {
        HomeView(fatCrabModel: fatCrabModel)
    }
}

#Preview {
    ContentView()
}
