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
    @State var showOrderDetailView = false
    @State var showOrderDetailViewForOrder: FatCrabOrderEnvelopeProtocol? = nil
    
    var body: some View {
        NavigationStack {
            List {
                let orderUuids: [UUID] = model.queriedOrders.keys.map({ $0 })
                ForEach(orderUuids, id: \.self) { orderUuid in
                    if let orderEnvelope = model.queriedOrders[orderUuid] {
                        OrderRowView(order: orderEnvelope.order())
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showOrderDetailViewForOrder = orderEnvelope
                            showOrderDetailView = true
                        }
                    }
                }
            }
            .refreshable {
                model.updateOrderBook()
            }
            .onAppear() {
                model.updateOrderBook()
            }
            .toolbar(content: {
                MakeNewOrderToolbarItem(showMakeNewOrderView: $showMakeNewOrderView)
            })
            .navigationTitle("Order Book")
        }
        .sheet(isPresented: $showMakeNewOrderView) {
            MakeNewOrderView()
        }
        .sheet(isPresented: $showOrderDetailView) {
            OrderDetailView(orderEnvelope: $showOrderDetailViewForOrder)
        }
    }
}

#Preview {
    BookView().environment(\.fatCrabModel, FatCrabMock())
}
