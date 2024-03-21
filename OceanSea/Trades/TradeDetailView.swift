//
//  TradeDetailView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/04.
//

import SwiftUI

struct TradeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let trade: FatCrabTrade
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TradeDetailSummaryView(for: trade)
                }
                
                Section {
                    TradeDetailExplainView(for: trade)
                }
                
                Section {
                    TradeDetailStatusView(for: trade)
                }
                
                Section {
                    TradeDetailActionView(for: trade)
                }
            }
            .navigationTitle(self.navigationTitleString(for: trade))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            }
        }
    }
    
    func navigationTitleString(for trade: FatCrabTrade) -> String {
        let buyString = "Order to buy Fatcrabs with BTC"
        let sellString = "Order to sell Fatcrabs for BTC"
        
        switch trade {
        case .maker(let maker):
            switch maker {
            case .buy:
                return buyString
            case .sell:
                return sellString
            }
                
        case .taker(let taker):
            switch taker {
            case .buy:
                return buyString
            case .sell:
                return sellString
            }
        }
    }
}

#Preview {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey-000-0004")))
    return TradeDetailView(for: trade)
}
