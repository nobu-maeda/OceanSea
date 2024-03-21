//
//  TradeDetailSummaryView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailSummaryView: View {
    let trade: FatCrabTrade
    let priceString: String
    let amountString: String
    let pubkeyString: String
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
        self.priceString = trade.orderPrice.formatted()
        self.amountString = trade.orderAmount.formatted()
        self.pubkeyString = "TBD"
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(amount: 1234.56, price: 5678.9, tradeUuid: UUID())))
    return TradeDetailSummaryView(for: trade)
}
