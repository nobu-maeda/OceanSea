//
//  OrderRowView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/02/07.
//

import SwiftUI

struct OrderRowView: View {
    let order: FatCrabOrder
    
    init(order: FatCrabOrder) {
        self.order = order
    }
    
    var body: some View {
        let orderTypeString = order.orderType == .buy ? "Buy" : "Sell"
        HStack {
            Text(orderTypeString).font(.headline)
            Spacer()
            Text("Amount: \(order.amount.formatted())").font(.subheadline)
            Spacer()
            Text("Price: \(order.price.formatted())").font(.subheadline)
        }
    }
}

#Preview {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    return OrderRowView(order: order)
}
