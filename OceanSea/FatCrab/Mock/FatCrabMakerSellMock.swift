//
//  FatCrabMakerSellMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/26.
//

import Foundation

@Observable class FatCrabMakerSellMock: FatCrabMakerSellProtocol {
    var state: FatCrabMakerState
    var orderAmount: Double
    var orderPrice: Double
    var tradeUuid: UUID
    var peerPubkey: String?
    var peerFcAddr: String?
    var peerBtcTxid: String?
    var offerEnvelopes: [FatCrabOfferEnvelope]
    var peerEnvelope: FatCrabPeerEnvelope?
    
    init(state: FatCrabMakerState, amount: Double, price: Double, tradeUuid: UUID, peerPubkey: String? = nil, peerBtcTxid: String? = nil, offerEnvelopes: [FatCrabOfferEnvelope] = [], peerEnvelope: FatCrabPeerEnvelope? = nil) {
        self.state = state
        self.orderAmount = amount
        self.orderPrice = price
        self.tradeUuid = tradeUuid
        self.peerPubkey = peerPubkey
        self.peerBtcTxid = peerBtcTxid
        self.offerEnvelopes = offerEnvelopes
        self.peerEnvelope = peerEnvelope
    }
    
    func postNewOrder() throws {
        self.state = FatCrabMakerState.waitingForOffers
    }
    
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) throws {
        switch tradeRspType {
        case .accept:
            self.state = FatCrabMakerState.acceptedOffer
        case .reject:
            break
        }
    }
    
    func checkBtcTxConfirmation() async throws -> UInt32 {
        return 6
    }
    
    func notifyPeer(fatcrabTxid: String) throws {
        self.state = FatCrabMakerState.notifiedOutbound
    }
    
    func tradeComplete() throws {
        self.state = FatCrabMakerState.tradeCompleted
    }
}
