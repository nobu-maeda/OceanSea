//
//  FatCrabTakerMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabTakerBuyMock: FatCrabTakerBuyProtocol {
    var state: FatCrabTakerState
    var orderAmount: Double
    var orderPrice: Double
    var tradeUuid: UUID
    var peerPubkey: String
    var tradeRspEnvelope: FatCrabTradeRspEnvelope?
    
    init(state: FatCrabTakerState, amount: Double, price: Double, tradeUuid: UUID, peerPubkey: String, tradeRspEnvelope: FatCrabTradeRspEnvelope? = nil) {
        self.state = state
        self.orderAmount = amount
        self.orderPrice = price
        self.tradeUuid = tradeUuid
        self.peerPubkey = peerPubkey
        self.tradeRspEnvelope = tradeRspEnvelope
    }
    
    func takeOrder() throws {
        self.state = FatCrabTakerState.submittedOffer
    }
    
    func notifyPeer(fatcrabTxid: String) throws {
        self.state = FatCrabTakerState.notifiedOutbound
    }
    
    func checkBtcTxConfirmation() async throws -> UInt32 {
        return 6
    }
    
    func tradeComplete() throws {
        self.state = FatCrabTakerState.tradeCompleted
    }
}

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
