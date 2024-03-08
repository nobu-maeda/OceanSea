//
//  OrderDetailView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/02/07.
//

import SwiftUI

struct OrderDetailView: View {
    let order: FatCrabOrder
    
    init(order: FatCrabOrder) {
        self.order = order
    }
    
    var body: some View {
        Text("Order Detail View")
    }
}

#Preview {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    return OrderDetailView(order: order)
}
