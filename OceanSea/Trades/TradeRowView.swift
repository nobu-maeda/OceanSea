//
//  TradeRowView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/04.
//

import SwiftUI

struct TradeRowView: View {
    let trade: FatCrabTrade
    
    init(trade: FatCrabTrade) {
        self.trade = trade
    }
    
    var body: some View {
        var tradeTypeString = ""
        var orderTypeString = ""
        var orderAmountString = ""
        var orderPriceString = ""
        
        switch trade {
        case .maker(let maker):
            tradeTypeString = "Made"
            switch maker {
            case .buy(let buyMaker):
                orderTypeString = "Buy"
                orderAmountString = buyMaker.orderAmount.formatted()
                orderPriceString = buyMaker.orderPrice.formatted()
                
            case .sell(let sellMaker):
                orderTypeString = "Sell"
                orderAmountString = sellMaker.orderAmount.formatted()
                orderPriceString = sellMaker.orderPrice.formatted()
            }
                
        case .taker(let taker):
            tradeTypeString = "Taking"
            switch taker {
            case .buy(let buyTaker):
                orderTypeString = "Buy"
                orderAmountString = buyTaker.orderAmount.formatted()
                orderPriceString = buyTaker.orderPrice.formatted()
                
            case .sell(let sellTaker):
                orderTypeString = "Sell"
                orderAmountString = sellTaker.orderAmount.formatted()
                orderPriceString = sellTaker.orderPrice.formatted()
            }
        }
        
        return HStack {
            Text(orderTypeString).font(.headline)
            Spacer()
            Text(tradeTypeString).font(.subheadline)
            Spacer()
            Text("Amount: \(orderAmountString)").font(.subheadline)
            Spacer()
            Text("Price: \(orderPriceString)").font(.subheadline)
        }
    }
}

#Preview {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(amount: 1234.56, price: 5678.9)))
    return TradeRowView(trade: trade)
}
