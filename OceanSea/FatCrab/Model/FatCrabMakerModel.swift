//
//  FatCrabMakerModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabMakerBuyModel: FatCrabMakerBuyProtocol {
    private let maker: FatCrabBuyMaker
    private(set) var state: FatCrabMakerState
    private(set) var orderAmount: Double
    private(set) var orderPrice: Double
    private(set) var tradeUuid: UUID
    private(set) var peerPubkey: String?
    private(set) var offers: [FatCrabOfferEnvelope]
    private(set) var peerEnvelope: FatCrabPeerEnvelope?
    
    init(maker: FatCrabBuyMaker) {
        self.maker = maker
        self.state = FatCrabMakerState.new
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        self.tradeUuid = UUID()
        self.offers = []
        
        Task {
            let state = try maker.getState()
            let order = try maker.getOrderDetails()
            let offers = try maker.queryOffers()
            let peerEnvelope = try maker.queryPeerMsg()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = order.amount
                self.orderPrice = order.price
                self.tradeUuid = UUID(uuidString: order.tradeUuid) ?? UUID.init(uuidString: allZeroUUIDString)!
                self.offers = offers
                self.peerEnvelope = peerEnvelope
            }
        }
    }
    
    func postNewOrder() throws {
        self.state = try self.maker.postNewOrder()
    }
    
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) throws {
        self.state = try self.maker.tradeResponse(tradeRspType: tradeRspType, offerEnvelope: offerEnvelope)
        
        if tradeRspType == .accept {
            self.peerPubkey = offerEnvelope.pubkey()
        }
    }
    
    func releaseNotifyPeer() throws {
        self.state = try self.maker.releaseNotifyPeer()
    }
    
    func tradeComplete() throws {
        self.state = try self.maker.tradeComplete()
    }
}

@Observable class FatCrabMakerSellModel: FatCrabMakerSellProtocol {
    private let maker: FatCrabSellMaker
    private(set) var state: FatCrabMakerState
    private(set) var orderAmount: Double
    private(set) var orderPrice: Double
    private(set) var tradeUuid: UUID
    private(set) var peerPubkey: String?
    private(set) var offers: [FatCrabOfferEnvelope]
    private(set) var peerEnvelope: FatCrabPeerEnvelope?
    
    init(maker: FatCrabSellMaker) {
        self.maker = maker
        self.state = FatCrabMakerState.new
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        self.tradeUuid = UUID()
        self.offers = []
        
        Task {
            let state = try maker.getState()
            let order = try maker.getOrderDetails()
            let offers = try maker.queryOffers()
            let peerEnvelope = try maker.queryPeerMsg()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = order.amount
                self.orderPrice = order.price
                self.tradeUuid = UUID(uuidString: order.tradeUuid) ?? UUID.init(uuidString: allZeroUUIDString)!
                self.offers = offers
                self.peerEnvelope = peerEnvelope
            }
        }
    }
    
    func postNewOrder() {
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
    
    func checkBtcTxConfirmation() async throws -> UInt32 {
        let btcTxConfs = try await Task {
            try self.maker.checkBtcTxConfirmation()
        }.value
        return btcTxConfs
    }
    
    func notifyPeer(fatcrabTxid: String) throws {
        Task {
            let state = try self.maker.notifyPeer(fatcrabTxid: fatcrabTxid)
            
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
