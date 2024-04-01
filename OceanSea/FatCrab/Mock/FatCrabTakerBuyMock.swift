//
//  FatCrabTakerBuyMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/26.
//

import Foundation

@Observable class FatCrabTakerBuyMock: FatCrabTakerBuyProtocol {
    var state: FatCrabTakerState
    var orderAmount: Double
    var orderPrice: Double
    var tradeUuid: UUID
    var peerPubkey: String
    var peerBtcTxid: String?
    var tradeRspEnvelope: FatCrabTradeRspEnvelope?
    
    init(state: FatCrabTakerState, amount: Double, price: Double, tradeUuid: UUID, peerPubkey: String, peerBtcTxid: String? = nil, tradeRspEnvelope: FatCrabTradeRspEnvelope? = nil) {
        self.state = state
        self.orderAmount = amount
        self.orderPrice = price
        self.tradeUuid = tradeUuid
        self.peerPubkey = peerPubkey
        self.peerBtcTxid = peerBtcTxid
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
