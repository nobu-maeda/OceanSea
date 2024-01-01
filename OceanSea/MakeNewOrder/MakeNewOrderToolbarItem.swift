//
//  MakeNewOrderToolbarItem.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/01.
//

import SwiftUI

struct MakeNewOrderToolbarItem: ToolbarContent {
    @Binding var showMakeNewOrderView: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                showMakeNewOrderView.toggle()
            }, label: {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(.blue)
            })
        }
    }
}
