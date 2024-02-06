//
//  AddRelayToolbarItem.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/02/06.
//

import SwiftUI

struct AddRelayToolbarItem: ToolbarContent {
    @Binding var showAddRelayToolbarView: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                showAddRelayToolbarView.toggle()
            }, label: {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(.blue)
            })
        }
    }
}
