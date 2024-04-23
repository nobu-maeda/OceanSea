//
//  FatCrabMakerSellModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/26.
//

import Foundation

@Observable class FatCrabMakerSellModel: FatCrabMakerSellProtocol {
    private let maker: FatCrabSellMaker
    private(set) var state: FatCrabMakerState
    private(set) var orderAmount: Double
    private(set) var orderPrice: Double
    private(set) var tradeUuid: UUID
    private(set) var peerPubkey: String?
    private(set) var offerEnvelopes: [FatCrabOfferEnvelope]
    private(set) var peerEnvelope: FatCrabPeerEnvelope?
    
    init(maker: FatCrabSellMaker) {
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
            let peerPubkey = try maker.getPeerPubkey()
            let offerEnvelopes = try maker.queryOffers()
            let peerEnvelope = try maker.queryPeerMsg()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = order.amount
                self.orderPrice = order.price
                self.tradeUuid = UUID(uuidString: order.tradeUuid) ?? UUID.init(uuidString: allZeroUUIDString)!
                self.peerPubkey = peerPubkey
                self.offerEnvelopes = offerEnvelopes
                self.peerEnvelope = peerEnvelope
            }
        }
    }
    
    var peerFcAddr: String? {
        get {
            peerEnvelope?.message().receiveAddress
        }
    }
    
    var peerBtcTxid: String? {
        get {
            peerEnvelope?.message().txid
        }
    }
    
    func postNewOrder() async throws {
        try await Task {
            let state = try self.maker.postNewOrder()
            
            Task { @MainActor in
                self.state = state
            }
        }.value
    }
    
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) async throws {
        try await Task {
            let state = try self.maker.tradeResponse(tradeRspType: tradeRspType, offerEnvelope: offerEnvelope)
            
            Task { @MainActor in
                self.state = state
                
                if tradeRspType == .accept {
                    self.peerPubkey = offerEnvelope.pubkey()
                }
            }
        }.value
    }
    
    func checkBtcTxConfirmation() async throws -> UInt32 {
        try await Task {
            try self.maker.checkBtcTxConfirmation()
        }.value
    }
    
    func notifyPeer(fatcrabTxid: String) async throws {
        try await Task {
            let state = try self.maker.notifyPeer(fatcrabTxid: fatcrabTxid)
            
            Task { @MainActor in
                self.state = state
            }
        }.value
    }
    
    func tradeComplete() async throws {
        try await Task {
            let state = try self.maker.tradeComplete()
            
            Task { @MainActor in
                self.state = state
            }
        }.value
    }
    
    func cancelOrder() async throws {
        try await Task {
            try self.maker.cancelOrder()
        }.value
    }
}

extension FatCrabMakerSellModel: FatCrabMakerNotifDelegate {
    func onMakerOfferNotif(offerNotif: FatCrabMakerNotifOfferStruct) {
        self.offerEnvelopes.append(offerNotif.offerEnvelope)
        self.state = offerNotif.state
    }
    
    func onMakerPeerNotif(peerNotif: FatCrabMakerNotifPeerStruct) {
        self.peerEnvelope = peerNotif.peerEnvelope
        self.state = peerNotif.state
    }
}
