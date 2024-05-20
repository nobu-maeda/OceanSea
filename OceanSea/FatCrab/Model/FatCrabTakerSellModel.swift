//
//  FatCrabTakerSellModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/26.
//

import Foundation

@Observable class FatCrabTakerSellModel: FatCrabTakerSellProtocol {
    private let taker: FatCrabSellTaker
    private(set) var state: FatCrabTakerState
    private(set) var orderAmount: Double
    private(set) var orderPrice: Double
    private(set) var tradeUuid: UUID
    private(set) var peerPubkey: String
    private(set) var tradeRspEnvelope: FatCrabTradeRspEnvelope?
    private(set) var peerEnvelope: FatCrabPeerEnvelope?
    
    init(taker: FatCrabSellTaker) {
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
            let peerEnvelope = try taker.queryPeerMsg()
            let order = orderEnvelope.order()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = order.amount
                self.orderPrice = order.price
                self.tradeUuid = UUID(uuidString: order.tradeUuid) ?? UUID.init(uuidString: allZeroUUIDString)!
                self.peerEnvelope = peerEnvelope
                self.peerPubkey = orderEnvelope.pubkey()
            }
        }
    }
    
    var peerFcTxid: String? {
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
    
    func releaseNotifyPeer() async throws {
        try await Task {
            let state = try taker.releaseNotifyPeer()
            
            Task { @MainActor in
                self.state = state
            }
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

extension FatCrabTakerSellModel: FatCrabTakerNotifDelegate {
    func onTakerTradeRspNotif(tradeRspNotif: FatCrabTakerNotifTradeRspStruct) {
        Task { @MainActor in
            self.tradeRspEnvelope = tradeRspNotif.tradeRspEnvelope
            self.state = tradeRspNotif.state
        }
    }
    
    func onTakerPeerNotif(peerNotif: FatCrabTakerNotifPeerStruct) {
        Task { @MainActor in
            self.peerEnvelope = peerNotif.peerEnvelope
            self.state = peerNotif.state
        }
    }
}
