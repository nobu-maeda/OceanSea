//
//  TradeDetailView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/04.
//

import SwiftUI

struct TradeDetailView: View {
    let trade: FatCrabTrade
    
    init(trade: FatCrabTrade) {
        self.trade = trade
    }
    
    var body: some View {
        Text("Trade Detail View")
    }
}

#Preview {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(amount: 1234.56, price: 5678.9)))
    return TradeDetailView(trade: trade)
}
