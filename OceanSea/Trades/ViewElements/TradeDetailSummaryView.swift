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
    
    let PUBKEY_STRING_PLACEHOLDER = "TBD"
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
        self.priceString = trade.orderPrice.formatted()
        self.amountString = trade.orderAmount.formatted()
    }
    
    var body: some View {
        var pubkeyString: String
        
        switch trade {
        case .maker(let maker):
            pubkeyString = maker.peerPubkey ?? PUBKEY_STRING_PLACEHOLDER
        case .taker(let taker):
            pubkeyString = taker.peerPubkey
        }
        
        return VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                Text("Price")
                Spacer()
                Text (priceString)
            }
            HStack {
                Text("Amount")
                Spacer()
                Text(amountString)
            }
            HStack {
                Text("Pubkey")
                Spacer()
                Text(pubkeyString)
            }
        };
        
    }
}

#Preview {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID())))
    return TradeDetailSummaryView(for: trade)
}
