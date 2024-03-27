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
        var makerTakerString = ""
        var buySellString = ""
        var orderAmountString = ""
        var orderPriceString = ""
        
        switch trade {
        case .maker(let maker):
            makerTakerString = "Made"
            switch maker {
            case .buy(let buyMaker):
                buySellString = "Buy"
                orderAmountString = buyMaker.orderAmount.formatted()
                orderPriceString = buyMaker.orderPrice.formatted()
                
            case .sell(let sellMaker):
                buySellString = "Sell"
                orderAmountString = sellMaker.orderAmount.formatted()
                orderPriceString = sellMaker.orderPrice.formatted()
            }
            
        case .taker(let taker):
            makerTakerString = "Taking"
            switch taker {
            case .buy(let buyTaker):
                buySellString = "Buy"
                orderAmountString = buyTaker.orderAmount.formatted()
                orderPriceString = buyTaker.orderPrice.formatted()
                
            case .sell(let sellTaker):
                buySellString = "Sell"
                orderAmountString = sellTaker.orderAmount.formatted()
                orderPriceString = sellTaker.orderPrice.formatted()
            }
        }
        
        return HStack {
            Text(buySellString).font(.headline)
            Spacer()
            Text(makerTakerString).font(.subheadline)
            Spacer()
            Text("Amount: \(orderAmountString)").font(.subheadline)
            Spacer()
            Text("Price: \(orderPriceString)").font(.subheadline)
        }
    }
}

#Preview {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID())))
    return TradeRowView(trade: trade)
}
