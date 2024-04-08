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
        if let trade = trade {
            let orderTypeString = trade.orderType == .buy ? "Buy" : "Sell"
            let orderAmountString = trade.orderAmount.formatted()
            let orderPriceString = trade.orderPrice.formatted(.number.precision(.fractionLength(0)))
            
            let tradeTypeString = trade.tradeType == .maker ? "Maker" : "Taker"
            let tradeUuidSuffix = String(trade.tradeUuid.uuidString.suffix(4))
            
            let tradeStateString =
            switch trade {
            case .maker(let maker):
                maker.state.string
            case .taker(let taker):
                taker.state.string
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(orderTypeString).font(.headline)
                    Text(tradeTypeString).font(.subheadline)
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("Amount: \(orderAmountString) FCs").font(.subheadline)
                    Text(tradeStateString).font(.subheadline)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Price: \(orderPriceString) sats").font(.subheadline)
                    Text("Trade ID: ...\(tradeUuidSuffix)").font(.subheadline)
                }
            }
        } else if let orderEnvelope = orderEnvelope {
            let orderTypeString = orderEnvelope.order().orderType == .buy ? "Buy" : "Sell"
            let orderAmountString = orderEnvelope.order().amount.formatted()
            let orderPriceString = orderEnvelope.order().price.formatted(.number.precision(.fractionLength(0)))
            
            HStack {
                Text(orderTypeString).font(.headline)
                Spacer()
                Text("Amount: \(orderAmountString) FCs").font(.subheadline)
                Spacer()
                Text("Price: \(orderPriceString) sats").font(.subheadline)
            }
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
