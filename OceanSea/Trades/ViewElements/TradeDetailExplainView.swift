//
//  TradeDetailExplainView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailExplainView: View {
    @State var numOffers = 0
    
    let trade: FatCrabTrade
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            let orderBtc = trade.orderAmount/trade.orderPrice
            
            switch trade {
            case .maker(let maker):
                switch maker {
                case .buy(let buyMaker):
                    Text("As a Maker of a buy order, you are buying Fatcrab with BTC. If this order completes...")
                    HStack {
                        Text("FC + \(buyMaker.orderAmount)")
                        Spacer()
                        Text("BTC - \(orderBtc)")
                    }
                case .sell(let sellMaker):
                    Text("As a Maker of a sell order, you are selling Fatcrab for BTC. If this order completes...")
                    HStack {
                        Text("FC - \(sellMaker.orderAmount)")
                        Spacer()
                        Text("BTC + \(orderBtc)")
                    }
                }
                
            case .taker(let taker):
                switch taker {
                case .buy(let buyTaker):
                    Text("As a Taker of a buy order, you are selling Fatcrab for BTC. If this order completes...")
                    HStack {
                        Text("FC - \(buyTaker.orderAmount)")
                        Spacer()
                        Text("BTC + \(orderBtc)")
                    }
                case .sell(let sellTaker):
                    Text("As a Taker of a sell order, you are buying Fatcrab with BTC. If this order completes...")
                    HStack {
                        Text("FC + \(sellTaker.orderAmount)")
                        Spacer()
                        Text("BTC - \(orderBtc)")
                    }
                }
            }
        }
    }
}

#Preview {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey-000-0011")))
    return TradeDetailExplainView(for: trade)
}
