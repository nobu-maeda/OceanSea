//
//  OrderDetailSummaryView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct OrderDetailSummaryView: View {
    let amountString: String
    let priceString: String
    let pubkeyString: String
    
    let PUBKEY_STRING_PLACEHOLDER = "TBD"
    
    init(orderAmount: Double, orderPrice: Double, pubkeyString: String?) {
        self.amountString = orderAmount.formatted()
        self.priceString = orderPrice.formatted()
        self.pubkeyString = pubkeyString ?? PUBKEY_STRING_PLACEHOLDER
    }
    
    var body: some View {
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
    OrderDetailSummaryView(orderAmount: 1234.56, orderPrice: 5678.9, pubkeyString: UUID().uuidString)
}
