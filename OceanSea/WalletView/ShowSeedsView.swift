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
        VStack {
            Text("Write down the seed words & keep them in a safe place").font(.caption)
            ScrollView(.vertical) {
                HStack(spacing: 0) {
                    List {
                        ForEach(0..<(numSeedWords/2), id:\.self) { i in
                            Text("\(i+1). \(model.mnemonic[i])")
                        }
                    }.scrollDisabled(true)
                    List {
                        ForEach(0..<(numSeedWords/2), id:\.self) { i in
                            Text("\(i+1+numSeedWords/2). \(model.mnemonic[i+numSeedWords/2])")
                        }
                    }.scrollDisabled(true)
                }.frame(height: 600)
            }
        }
        .navigationTitle("Seed Words")
    }
}

#Preview {
    ShowSeedsView().environment(\.fatCrabModel, FatCrabMock())
}
