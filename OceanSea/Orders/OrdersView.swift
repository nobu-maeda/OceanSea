//
//  OrdersView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct OrdersView<T: FatCrabProtocol>: View {
    @ObservedObject var fatCrabModel: T
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            Text("Make new Order")
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                })
                .navigationTitle("Order Status")
        }
    }
}

#Preview {
    OrdersView(fatCrabModel: FatCrabMock())
}
