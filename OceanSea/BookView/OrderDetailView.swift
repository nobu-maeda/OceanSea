//
//  OrderDetailView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/02/07.
//

import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var orderEnvelope: FatCrabOrderEnvelopeProtocol?
    
    var body: some View {
        guard let orderEnvelope = orderEnvelope else {
            fatalError("Order Envelope should not be nil for OrderDetailView")
        }
        
        return NavigationStack {
            List {
                Section {
                    OrderDetailSummaryView(orderAmount: orderEnvelope.order().amount, orderPrice: orderEnvelope.order().price, pubkeyString: orderEnvelope.pubkey())
                } header: {
                    Text("Order Summary")
                }
                
                Section {
                    TradeDetailExplainView(tradeType: .taker, orderType: orderEnvelope.order().orderType, orderAmount: orderEnvelope.order().amount, orderPrice: orderEnvelope.order().price)
                } header: {
                    Text("Explaination")
                }
                
                Section {
                    TakeOrderActionView(for: orderEnvelope)
                } header: {
                    Text("Action")
                }
            }
            .navigationTitle(navigationTitleString(for: orderEnvelope))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            }
        }
    }
    
    func navigationTitleString(for orderEnvelope: FatCrabOrderEnvelopeProtocol) -> String {
        switch orderEnvelope.order().orderType {
        case .buy:
            "Order to buy Fatcrabs with BTC"
        case .sell:
            "Order to sell Fatcrabs for BTC"
        }
    }
}

#Preview {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    return OrderDetailView(orderEnvelope: $orderEnvelope)
}
