//
//  FatCrabMakerBuyModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/26.
//

import Foundation

@Observable class FatCrabMakerBuyModel: FatCrabMakerBuyProtocol {
    private let maker: FatCrabBuyMaker
    private(set) var state: FatCrabMakerState
    private(set) var orderAmount: Double
    private(set) var orderPrice: Double
    private(set) var tradeUuid: UUID
    private(set) var peerPubkey: String?
    private(set) var offerEnvelopes: [FatCrabOfferEnvelope]
    private(set) var peerEnvelope: FatCrabPeerEnvelope?
    
    init(maker: FatCrabBuyMaker) {
        self.maker = maker
        self.state = FatCrabMakerState.new
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        self.tradeUuid = UUID()
        self.offerEnvelopes = []
        
        Task {
            try maker.registerNotifDelegate(delegate: self)
            
            let state = try maker.getState()
            let order = try maker.getOrderDetails()
            let offerEnvelopes = try maker.queryOffers()
            let peerEnvelope = try maker.queryPeerMsg()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = order.amount
                self.orderPrice = order.price
                self.tradeUuid = UUID(uuidString: order.tradeUuid) ?? UUID.init(uuidString: allZeroUUIDString)!
                self.offerEnvelopes = offerEnvelopes
                self.peerEnvelope = peerEnvelope
            }
        }
    }
    
    var peerFcTxid: String? {
        get {
            peerEnvelope?.message().txid
        }
    }
    
    func postNewOrder() throws {
        Task {
            let state = try self.maker.postNewOrder()
            
            Task { @MainActor in
                self.state = state
            }
        }
    }
    
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) throws {
        Task {
            let state = try self.maker.tradeResponse(tradeRspType: tradeRspType, offerEnvelope: offerEnvelope)
            
            Task { @MainActor in
                self.state = state
                if tradeRspType == .accept {
                    self.peerPubkey = offerEnvelope.pubkey()
                }
            }
        }
    }
    
    func releaseNotifyPeer() throws {
        Task {
            let state = try self.maker.releaseNotifyPeer()
            
            Task { @MainActor in
                self.state = state
            }
        }
    }
    
    func tradeComplete() throws {
        Task {
            let state = try self.maker.tradeComplete()
            
            Task { @MainActor in
                self.state = state
            }
        }
    }
}

extension FatCrabMakerBuyModel: FatCrabMakerNotifDelegate {
    func onMakerOfferNotif(offerNotif: FatCrabMakerNotifOfferStruct) {
        self.offerEnvelopes.append(offerNotif.offerEnvelope)
        self.state = offerNotif.state
    }
    
    func onMakerPeerNotif(peerNotif: FatCrabMakerNotifPeerStruct) {
        self.peerEnvelope = peerNotif.peerEnvelope
        self.state = peerNotif.state
    }
}
