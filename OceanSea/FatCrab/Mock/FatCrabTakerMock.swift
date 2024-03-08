//
//  FatCrabTakerMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabTakerBuyMock: FatCrabTakerBuyProtocol {
    var orderAmount: Double
    var orderPrice: Double
    
    init(amount: Double, price: Double) {
        self.orderAmount = amount
        self.orderPrice = price
    }
}

@Observable class FatCrabTakerSellMock: FatCrabTakerSellProtocol {
    var orderAmount: Double
    var orderPrice: Double
    
    init(amount: Double, price: Double) {
        self.orderAmount = amount
        self.orderPrice = price
    }
}
