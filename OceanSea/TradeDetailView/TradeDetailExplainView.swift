//
//  TradeDetailExplainView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailExplainView: View {
    let tradeType: FatCrabTradeType
    let orderType: FatCrabOrderType
    let orderAmount: Double
    let orderPrice: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            let orderBtc = orderAmount*orderPrice
            
            switch tradeType {
            case .maker:
                switch orderType {
                case .buy:
                    Text("As Maker of a Buy order, you are buying FatCrab with BTC. If the order completes...")
                    HStack {
                        Text("FC + \(Int(orderAmount.rounded()))")
                        Spacer()
                        Text("Sats - \(Int(orderBtc.rounded()))")
                    }
                case .sell:
                    Text("As Maker of a Sell order, you are selling FatCrab for BTC. If the order completes...")
                    HStack {
                        Text("FC - \(Int(orderAmount.rounded()))")
                        Spacer()
                        Text("Sats + \(Int(orderBtc.rounded()))")
                    }
                }
                
            case .taker:
                switch orderType {
                case .buy:
                    Text("As Taker of a Buy order, you are selling FatCrab for BTC. If the order completes...")
                    HStack {
                        Text("FC - \(Int(orderAmount.rounded()))")
                        Spacer()
                        Text("Sats + \(Int(orderBtc.rounded()))")
                    }
                case .sell:
                    Text("As Taker of a Sell order, you are buying FatCrab with BTC. If the order completes...")
                    HStack {
                        Text("FC + \(Int(orderAmount.rounded()))")
                        Spacer()
                        Text("Sats - \(Int(orderBtc.rounded()))")
                    }
                }
            }
        }
    }
}

#Preview {
    TradeDetailExplainView(tradeType: .taker, orderType: .sell, orderAmount: 123.4, orderPrice: 567.8)
}
