//
//  FatCrabTakerBuyModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/26.
//

import Foundation

@Observable class FatCrabTakerBuyModel: FatCrabTakerBuyProtocol {
    private let taker: FatCrabBuyTaker
    private(set) var state: FatCrabTakerState
    private(set) var orderAmount: Double
    private(set) var orderPrice: Double
    private(set) var tradeUuid: UUID
    private(set) var peerPubkey: String
    private(set) var tradeRspEnvelope: FatCrabTradeRspEnvelope?
    private(set) var peerEnvelope: FatCrabPeerEnvelope?
    
    init(taker: FatCrabBuyTaker) {
        self.taker = taker
        self.state = FatCrabTakerState.new
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        self.tradeUuid = UUID()
        self.peerPubkey = ""
        
        Task {
            try taker.registerNotifDelegate(delegate: self)
            
            let state = try taker.getState()
            let orderEnvelope = try taker.getOrderDetails()
            let tradeRspEnvelope = try taker.queryTradeRsp()
            let order = orderEnvelope.order()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = order.amount
                self.orderPrice = order.price
                self.tradeUuid = UUID(uuidString: order.tradeUuid) ?? UUID.init(uuidString: allZeroUUIDString)!
                self.peerPubkey = orderEnvelope.pubkey()
                self.tradeRspEnvelope = tradeRspEnvelope
            }
        }
    }
    
    var peerBtcTxid: String? {
        get {
            peerEnvelope?.message().txid
        }
    }
    
    func takeOrder() throws {
        Task {
            let state = try taker.takeOrder()
            
            Task { @MainActor in
                self.state = state
            }
        }
    }
    
    func notifyPeer(fatcrabTxid: String) throws {
        Task {
            let state = try taker.notifyPeer(fatcrabTxid: fatcrabTxid)
            
            Task { @MainActor in
                self.state = state
            }
        }
    }
    
    func checkBtcTxConfirmation() async throws -> UInt32 {
        let btcTxConfs = try await Task {
            try self.taker.checkBtcTxConfirmation()
        }.value
        return btcTxConfs
    }
    
    func tradeComplete() throws {
        Task {
            let state = try taker.tradeComplete()
            
            Task { @MainActor in
                self.state = state
            }
        }
    }
}

extension FatCrabTakerBuyModel: FatCrabTakerNotifDelegate {
    func onTakerTradeRspNotif(tradeRspNotif: FatCrabTakerNotifTradeRspStruct) {
        self.tradeRspEnvelope = tradeRspNotif.tradeRspEnvelope
        self.state = tradeRspNotif.state
    }
    
    func onTakerPeerNotif(peerNotif: FatCrabTakerNotifPeerStruct) {
        self.peerEnvelope = peerNotif.peerEnvelope
        self.state = peerNotif.state
    }
}
