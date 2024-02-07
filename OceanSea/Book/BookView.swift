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
            List {
                let orderUuids: [UUID] = model.queriedOrders.keys.map({ $0 })
                ForEach(orderUuids, id: \.self) { orderUuid in
                    if let order = model.queriedOrders[orderUuid]?.order() {
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderRowView(order: order)
                        }
                    }
                }
            }
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
