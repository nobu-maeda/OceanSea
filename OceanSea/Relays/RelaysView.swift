//
//  RelaysView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct RelaysView: View {
    @Environment(\.fatCrabModel) var model
    
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle("Nostr Relays")
        }
    }
}

#Preview {
    RelaysView().environment(\.fatCrabModel, FatCrabMock())
}
