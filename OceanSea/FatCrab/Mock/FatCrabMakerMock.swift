//
//  FatCrabMakerMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabMakerBuyMock: FatCrabMakerBuyProtocol {
    var orderAmount: Double
    var orderPrice: Double
    
    init(amount: Double, price: Double) {
        self.orderAmount = amount
        self.orderPrice = price
    }
}

@Observable class FatCrabMakerSellMock: FatCrabMakerSellProtocol {
    var orderAmount: Double
    var orderPrice: Double
    
    init(amount: Double, price: Double) {
        self.orderAmount = amount
        self.orderPrice = price
    }
}
