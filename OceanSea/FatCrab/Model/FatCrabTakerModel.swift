//
//  FatCrabTakerModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabTakerBuyModel: FatCrabTakerBuyProtocol {
    private let taker: FatCrabBuyTaker
    var orderAmount: Double
    var orderPrice: Double
    
    init(taker: FatCrabBuyTaker) {
        self.taker = taker
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        
        Task {
            let order_envelope = try taker.getOrderDetails()
            
            Task { @MainActor in
                self.orderAmount = order_envelope.order().amount
                self.orderPrice = order_envelope.order().price
            }
        }
    }
}

@Observable class FatCrabTakerSellModel: FatCrabTakerSellProtocol {
    private let taker: FatCrabSellTaker
    var orderAmount: Double
    var orderPrice: Double
    
    init(taker: FatCrabSellTaker) {
        self.taker = taker
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        
        Task {
            let order_envelope = try taker.getOrderDetails()
            
            Task { @MainActor in
                self.orderAmount = order_envelope.order().amount
                self.orderPrice = order_envelope.order().price
            }
        }
    }
}
