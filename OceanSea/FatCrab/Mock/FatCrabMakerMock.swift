//
//  FatCrabMakerMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabMakerBuyMock: FatCrabMakerBuyProtocol {
    var state: FatCrabMakerState
    var orderAmount: Double
    var orderPrice: Double
    var offers: [FatCrabOfferEnvelope]
    var peerEnvelope: FatCrabPeerEnvelope?
    
    init(amount: Double, price: Double, offers: [FatCrabOfferEnvelope] = [], peerEnvelope: FatCrabPeerEnvelope? = nil) {
        self.state = FatCrabMakerState.new
        self.orderAmount = amount
        self.orderPrice = price
        self.offers = offers
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
    
    func releaseNotifyPeer() throws {
        self.state = FatCrabMakerState.notifiedOutbound
    }
    
    func tradeComplete() throws {
        self.state = FatCrabMakerState.tradeCompleted
    }
}

@Observable class FatCrabMakerSellMock: FatCrabMakerSellProtocol {
    var state: FatCrabMakerState
    var orderAmount: Double
    var orderPrice: Double
    var offers: [FatCrabOfferEnvelope]
    var peerEnvelope: FatCrabPeerEnvelope?
    
    init(amount: Double, price: Double, offers: [FatCrabOfferEnvelope] = [], peerEnvelope: FatCrabPeerEnvelope? = nil) {
        self.state = FatCrabMakerState.new
        self.orderAmount = amount
        self.orderPrice = price
        self.offers = offers
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
    
    func checkBtcTxConfirmation() throws -> UInt32 {
        return 6
    }
    
    func notifyPeer(fatcrabTxid: String) throws {
        self.state = FatCrabMakerState.notifiedOutbound
    }
    
    func tradeComplete() throws {
        self.state = FatCrabMakerState.tradeCompleted
    }
}
