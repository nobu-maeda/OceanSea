//
//  TradeDetailStatusView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailStatusView: View {
    let trade: FatCrabTrade
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(amount: 1234.56, price: 5678.9, tradeUuid: UUID())))
    return TradeDetailStatusView(for: trade)
}
