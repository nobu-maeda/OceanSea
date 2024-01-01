//
//  ShowSeedsView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct ShowSeedsView: View {
    @Environment(\.fatCrabModel) var model
    
    var body: some View {
        let numSeedWords = model.mnemonic.count
        
        List {
            ForEach(0..<(numSeedWords/2), id:\.self) { i in
                let firstIndex = 2*i
                let secondIndex = 2*i+1
                TitleValueHStack(title: "\(firstIndex+1). \(model.mnemonic[firstIndex])",
                                 value: "\(secondIndex+1). \(model.mnemonic[secondIndex])",
                                 format: .around)
            }
        }
        .navigationTitle("Seed Words")
    }
}

#Preview {
    ShowSeedsView().environment(\.fatCrabModel, FatCrabMock())
}
