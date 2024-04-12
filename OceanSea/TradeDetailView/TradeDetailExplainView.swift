//
//  TradeDetailExplainView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailExplainView: View {
    @State var numOffers = 0
    
    @State var tradeType: FatCrabTradeType
    @State var orderType: FatCrabOrderType
    @State var orderAmount: Double
    @State var orderPrice: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            let orderBtc = orderAmount/orderPrice
            
            switch tradeType {
            case .maker:
                switch orderType {
                case .buy:
                    Text("As a Maker of a buy order, you are buying FatCrab with BTC. If this order completes...")
                    HStack {
                        Text("FC + \(orderAmount)")
                        Spacer()
                        Text("BTC - \(orderBtc)")
                    }
                case .sell:
                    Text("As a Maker of a sell order, you are selling FatCrab for BTC. If this order completes...")
                    HStack {
                        Text("FC - \(orderAmount)")
                        Spacer()
                        Text("BTC + \(orderBtc)")
                    }
                }
                
            case .taker:
                switch orderType {
                case .buy:
                    Text("As a Taker of a buy order, you are selling FatCrab for BTC. If this order completes...")
                    HStack {
                        Text("FC - \(orderAmount)")
                        Spacer()
                        Text("BTC + \(orderBtc)")
                    }
                case .sell:
                    Text("As a Taker of a sell order, you are buying FatCrab with BTC. If this order completes...")
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
