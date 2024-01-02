//
//  FatCrabMakerModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabMakerBuyModel: FatCrabMakerBuyProtocol {
    let maker: FatCrabBuyMaker
    
    init(maker: FatCrabBuyMaker) {
        self.maker = maker
    }
}

@Observable class FatCrabMakerSellModel: FatCrabMakerSellProtocol {
    private let maker: FatCrabSellMaker
    
    init(maker: FatCrabSellMaker) {
        self.maker = maker
    }
}
