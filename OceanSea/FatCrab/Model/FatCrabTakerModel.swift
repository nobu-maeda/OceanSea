//
//  FatCrabTakerModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
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
    
    init(taker: FatCrabBuyTaker) {
        self.taker = taker
        self.state = FatCrabTakerState.new
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        self.tradeUuid = UUID()
        self.peerPubkey = ""
        
        Task {
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
    
    func takeOrder() throws {
        self.state = try taker.takeOrder()
    }
    
    func notifyPeer(fatcrabTxid: String) throws {
        self.state = try taker.notifyPeer(fatcrabTxid: fatcrabTxid)
    }
    
    func checkBtcTxConfirmation() throws -> UInt32 {
        return try taker.checkBtcTxConfirmation()
    }
    
    func tradeComplete() throws {
        self.state = try taker.tradeComplete()
    }
}

@Observable class FatCrabTakerSellModel: FatCrabTakerSellProtocol {
    private let taker: FatCrabSellTaker
    private(set) var state: FatCrabTakerState
    private(set) var orderAmount: Double
    private(set) var orderPrice: Double
    private(set) var tradeUuid: UUID
    private(set) var peerPubkey: String
    
    init(taker: FatCrabSellTaker) {
        self.taker = taker
        self.state = FatCrabTakerState.new
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        self.tradeUuid = UUID()
        self.peerPubkey = ""
        
        Task {
            let state = try taker.getState()
            let orderEnvelope = try taker.getOrderDetails()
            let order = orderEnvelope.order()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = order.amount
                self.orderPrice = order.price
                self.tradeUuid = UUID(uuidString: order.tradeUuid) ?? UUID.init(uuidString: allZeroUUIDString)!
                self.peerPubkey = orderEnvelope.pubkey()
            }
        }
    }
    
    func takeOrder() throws {
        self.state = try taker.takeOrder()
    }
    
    func tradeComplete() throws {
        self.state = try taker.tradeComplete()
    }
}
