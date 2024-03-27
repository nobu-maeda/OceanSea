//
//  TradeDetailExplainView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailExplainView: View {
    @State var numOffers = 0
    
    let tradeType: FatCrabTradeType
    let orderType: FatCrabOrderType
    let orderAmount: Double
    let orderPrice: Double
    
    init(tradeType: FatCrabTradeType, orderType: FatCrabOrderType, orderAmount: Double, orderPrice: Double) {
        self.tradeType = tradeType
        self.orderType = orderType
        self.orderAmount = orderAmount
        self.orderPrice = orderPrice
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            let orderBtc = orderAmount/orderPrice
            
            switch tradeType {
            case .maker:
                switch orderType {
                case .buy:
                    Text("As a Maker of a buy order, you are buying Fatcrab with BTC. If this order completes...")
                    HStack {
                        Text("FC + \(orderAmount)")
                        Spacer()
                        Text("BTC - \(orderBtc)")
                    }
                case .sell:
                    Text("As a Maker of a sell order, you are selling Fatcrab for BTC. If this order completes...")
                    HStack {
                        Text("FC - \(orderAmount)")
                        Spacer()
                        Text("BTC + \(orderBtc)")
                    }
                }
                
            case .taker:
                switch orderType {
                case .buy:
                    Text("As a Taker of a buy order, you are selling Fatcrab for BTC. If this order completes...")
                    HStack {
                        Text("FC - \(orderAmount)")
                        Spacer()
                        Text("BTC + \(orderBtc)")
                    }
                case .sell:
                    Text("As a Taker of a sell order, you are buying Fatcrab with BTC. If this order completes...")
                    HStack {
                        Text("FC + \(orderAmount)")
                        Spacer()
                        Text("BTC - \(orderBtc)")
                    }
                }
            }
        }
    }
}

#Preview {
    TradeDetailExplainView(tradeType: .taker, orderType: .sell, orderAmount: 1234.56, orderPrice: 5678.9)
}
