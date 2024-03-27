//
//  TradeRowView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/04.
//

import SwiftUI

struct TradeRowView: View {
    let orderEnvelope: FatCrabOrderEnvelopeProtocol?
    let trade: FatCrabTrade?
    
    init(orderEnvelope: FatCrabOrderEnvelopeProtocol?, trade: FatCrabTrade?) {
        self.orderEnvelope = orderEnvelope
        self.trade = trade
    }
    
    var body: some View {
        let tradeType = trade?.tradeType
        let orderType = trade?.orderType ?? orderEnvelope?.order().orderType
        let orderAmount = trade?.orderAmount ?? orderEnvelope?.order().amount
        let orderPrice = trade?.orderPrice ?? orderEnvelope?.order().price
        
        let tradeTypeString: String?
        let orderTypeString: String
        let orderAmountString: String
        let orderPriceString: String
        
        if let tradeType = tradeType {
            tradeTypeString = tradeType == .maker ? "Maker" : "Taker"
        } else {
            tradeTypeString = nil
        }
        
        guard let orderType = orderType else {
            fatalError("orderType is nil")
        }
        orderTypeString = orderType == .buy ? "Buy" : "Sell"
        
        guard let orderAmount = orderAmount else {
            fatalError("orderAmount is nil")
        }
        orderAmountString = orderAmount.formatted()
        
        guard let orderPrice = orderPrice else {
            fatalError("orderPrice is nil")
        }
        orderPriceString = orderPrice.formatted()
        
        return HStack {
            Text(orderTypeString).font(.headline)
            Spacer()
            Text(tradeTypeString ?? "").font(.subheadline)
            Spacer()
            Text("Amount: \(orderAmountString)").font(.subheadline)
            Spacer()
            Spacer()
            Text("Price: \(orderPriceString)").font(.subheadline)
        }
    }
}

#Preview("Trade") {
    let trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0022")))
    return TradeRowView(orderEnvelope: nil, trade: trade)
}

#Preview("Order") {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    let orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    return TradeRowView(orderEnvelope: orderEnvelope, trade: nil)
}

#Preview("Trade & Order") {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    let orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    let trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0044")))
    return TradeRowView(orderEnvelope: orderEnvelope, trade: trade)
}
