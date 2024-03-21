//
//  TradeDetailExplainView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailExplainView: View {
    let trade: FatCrabTrade
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey-000-0011")))
    return TradeDetailExplainView(for: trade)
}
