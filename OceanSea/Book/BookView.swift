//
//  BookView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct BookView: View {
    @Environment(\.fatCrabModel) var model
    
    @State var showMakeNewOrderView = false
    
    var body: some View {
        NavigationStack {
            Text("Hello, World!")
                .toolbar(content: {
                    MakeNewOrderToolbarItem(showMakeNewOrderView: $showMakeNewOrderView)
                })
                .navigationTitle("Order Book")
        }
        .sheet(isPresented: $showMakeNewOrderView) {
            MakeNewOrderView()
        }
    }
}

#Preview {
    BookView().environment(\.fatCrabModel, FatCrabMock())
}
