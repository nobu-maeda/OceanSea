//
//  TradeDetailActionView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailActionView: View {
    let trade: FatCrabTrade
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}
