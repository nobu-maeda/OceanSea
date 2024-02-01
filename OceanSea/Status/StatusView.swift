//
//  StatusView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct StatusView: View {
    @Environment(\.fatCrabModel) var model
    
    @State var showMakeNewOrderView = false
    
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .toolbar(content: {
                    MakeNewOrderToolbarItem(showMakeNewOrderView: $showMakeNewOrderView)
                })
                .navigationTitle("Order Status")
        }
        .sheet(isPresented: $showMakeNewOrderView) {
            MakeNewOrderView()
        }
    }
}

#Preview {
    StatusView().environment(\.fatCrabModel, FatCrabMock())
}
