//
//  OrderDetailSummaryView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct OrderDetailSummaryView: View {
    let tradeUuidString: String
    let amountString: String
    let priceString: String
    let pubkeyString: String
    
    
    let PUBKEY_STRING_PLACEHOLDER = "TBD"
    
    init(tradeUuidString: String, orderAmount: Double, orderPrice: Double, pubkeyString: String?) {
        self.tradeUuidString = tradeUuidString
        self.amountString = orderAmount.formatted()
        self.priceString = orderPrice.formatted()
        self.pubkeyString = pubkeyString ?? PUBKEY_STRING_PLACEHOLDER
    }
    
    var body: some View {
        return VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                Text("Trade-UUID")
                Spacer()
                Text(tradeUuidString)
            }
            HStack {
                Text("Price (Sats)")
                Spacer()
                Text(priceString)
            }
            HStack {
                Text("Amount (Fatcrab)")
                Spacer()
                Text(amountString)
            }
            HStack {
                Text("Peer Pubkey")
                Spacer()
                Text(pubkeyString)
            }
        };
        
    }
}

#Preview {
    OrderDetailSummaryView(tradeUuidString: UUID().uuidString, orderAmount: 1234.56, orderPrice: 5678.9, pubkeyString: UUID().uuidString)
}
