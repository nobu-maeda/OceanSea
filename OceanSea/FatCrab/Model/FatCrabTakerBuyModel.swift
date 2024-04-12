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
    
    var peerFcAddr: String? {
        get {
            if let tradeRsp = tradeRspEnvelope?.tradeRsp() {
                switch tradeRsp {
                case .accept(let receiveAddress):
                    return receiveAddress
                case .reject:
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    var peerBtcTxid: String? {
        get {
            peerEnvelope?.message().txid
        }
    }
    
    func takeOrder() async throws {
        try await Task {
            let state = try taker.takeOrder()
            
            Task { @MainActor in
                self.state = state
            }
        }.value
    }
    
    func notifyPeer(fatcrabTxid: String) async throws {
        try await Task {
            let state = try taker.notifyPeer(fatcrabTxid: fatcrabTxid)
            
            Task { @MainActor in
                self.state = state
            }
        }.value
    }
    
    func checkBtcTxConfirmation() async throws -> UInt32 {
        try await Task {
            try self.taker.checkBtcTxConfirmation()
        }.value
    }
    
    func tradeComplete() async throws {
        try await Task {
            let state = try taker.tradeComplete()
            
            Task { @MainActor in
                self.state = state
            }
        }.value
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
