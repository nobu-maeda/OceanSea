//
//  ContentView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/15.
//

import SwiftUI
import FatCrabTradingFFI

struct ContentView: View {
    @State var fatCrabModel: any FatCrabProtocol = FatCrabModel(for: .signet)
    
    var body: some View {
        HomeView(model: $fatCrabModel)
    }
}

#Preview {
    ContentView()
}
