//
//  FatCrabMakerBuyMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/26.
//

import Foundation

@Observable class FatCrabMakerBuyMock: FatCrabMakerBuyProtocol {
    
    var state: FatCrabMakerState
    var orderAmount: Double
    var orderPrice: Double
    var tradeUuid: UUID
    var peerPubkey: String?
    var peerFcTxid: String?
    var offerEnvelopes: [FatCrabOfferEnvelope]
    var peerEnvelope: FatCrabPeerEnvelope?
    
    init(state: FatCrabMakerState, amount: Double, price: Double, tradeUuid: UUID, peerPubkey: String? = nil, peerFcTxid: String? = nil, offerEnvelopes: [FatCrabOfferEnvelope] = [], peerEnvelope: FatCrabPeerEnvelope? = nil) {
        self.state = state
        self.orderAmount = amount
        self.orderPrice = price
        self.tradeUuid = tradeUuid
        self.peerPubkey = peerPubkey
        self.peerFcTxid = peerFcTxid
        self.offerEnvelopes = offerEnvelopes
        self.peerEnvelope = peerEnvelope
    }
    
    func postNewOrder() async throws {
        self.state = FatCrabMakerState.waitingForOffers
    }
    
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) async throws {
        switch tradeRspType {
        case .accept:
            self.state = FatCrabMakerState.acceptedOffer
        case .reject:
            break
        }
    }
    
    func releaseNotifyPeer() async throws {
        self.state = FatCrabMakerState.notifiedOutbound
    }
    
    func tradeComplete() async throws {
        self.state = FatCrabMakerState.tradeCompleted
    }
    
    func cancelOrder() async throws {
    }
}
