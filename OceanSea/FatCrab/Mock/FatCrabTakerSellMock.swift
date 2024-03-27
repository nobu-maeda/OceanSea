//
//  FatCrabTakerSellMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/26.
//

import Foundation

@Observable class FatCrabTakerSellMock: FatCrabTakerSellProtocol {
    var state: FatCrabTakerState
    var orderAmount: Double
    var orderPrice: Double
    var tradeUuid: UUID
    var peerPubkey: String
    
    init(state: FatCrabTakerState, amount: Double, price: Double, tradeUuid: UUID, peerPubkey: String) {
        self.state = state
        self.orderAmount = amount
        self.orderPrice = price
        self.tradeUuid = tradeUuid
        self.peerPubkey = peerPubkey
    }
    
    func takeOrder() throws {
        self.state = FatCrabTakerState.submittedOffer
    }
    
    func tradeComplete() throws {
        self.state = FatCrabTakerState.tradeCompleted
    }
}
