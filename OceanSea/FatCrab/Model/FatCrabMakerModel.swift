//
//  FatCrabMakerModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabMakerBuyModel: FatCrabMakerBuyProtocol {
    private let maker: FatCrabBuyMaker
    var orderAmount: Double
    var orderPrice: Double
    
    init(maker: FatCrabBuyMaker) {
        self.maker = maker
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        
        Task {
            let order = try maker.getOrderDetails()
            
            Task { @MainActor in
                self.orderAmount = order.amount
                self.orderPrice = order.price
            }
        }
    }
}

@Observable class FatCrabMakerSellModel: FatCrabMakerSellProtocol {
    private let maker: FatCrabSellMaker
    var orderAmount: Double
    var orderPrice: Double
    
    init(maker: FatCrabSellMaker) {
        self.maker = maker
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        
        Task {
            let order = try maker.getOrderDetails()
            
            Task { @MainActor in
                self.orderAmount = order.amount
                self.orderPrice = order.price
            }
        }
    }
}
