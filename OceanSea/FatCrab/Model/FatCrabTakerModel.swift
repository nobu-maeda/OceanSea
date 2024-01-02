//
//  FatCrabTakerModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabTakerBuyModel: FatCrabTakerBuyProtocol {
    let taker: FatCrabBuyTaker
    
    init(taker: FatCrabBuyTaker) {
        self.taker = taker
    }
}

@Observable class FatCrabTakerSellModel: FatCrabTakerSellProtocol {
    let taker: FatCrabSellTaker
    
    init(taker: FatCrabSellTaker) {
        self.taker = taker
    }
}
