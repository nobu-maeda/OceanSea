//
//  TradeRowView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/04.
//

import SwiftUI

struct TradeRowView: View {
    @Environment(\.fatCrabModel) var model
    
    let orderUuid: UUID
    
    var body: some View {
        let trade = model.trades[orderUuid]
        let orderEnvelope = model.queriedOrders[orderUuid]
        
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
    let model = FatCrabMock(for: .signet)
    let tradeUuid = model.getRandomTradeUuid()
    return TradeRowView(orderUuid: tradeUuid).environment(\.fatCrabModel, model)
}

#Preview("Order") {
    let model = FatCrabMock(for: .signet)
    let orderUuid = model.getRandomOrderUuid()
    return TradeRowView(orderUuid: orderUuid).environment(\.fatCrabModel, model)
}
