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
        Task {
            let state = try taker.takeOrder()
            
            Task { @MainActor in
                self.state = state
            }
        }
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
