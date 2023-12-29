//
//  ContentView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/15.
//

import SwiftUI
import FatCrabTradingFFI

struct ContentView: View {
    let fatCrabModel: FatCrabModel
    
    init() {
        fatCrabModel = FatCrabModel()
    }
    
    var body: some View {
        HomeView().environment(\.fatCrabModel, self.fatCrabModel)
    }
}

#Preview {
    ContentView()
}
