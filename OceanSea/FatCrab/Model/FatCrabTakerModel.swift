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
    private(set) var tradeRspEnvelope: FatCrabTradeRspEnvelope?
    
    init(taker: FatCrabBuyTaker) {
        self.taker = taker
        self.state = FatCrabTakerState.new
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        
        Task {
            let state = try taker.getState()
            let orderEnvelope = try taker.getOrderDetails()
            let tradeRspEnvelope = try taker.queryTradeRsp()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = orderEnvelope.order().amount
                self.orderPrice = orderEnvelope.order().price
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
    
    init(taker: FatCrabSellTaker) {
        self.taker = taker
        self.state = FatCrabTakerState.new
        self.orderAmount = 0.0
        self.orderPrice = 0.0
        
        Task {
            let state = try taker.getState()
            let orderEnvelope = try taker.getOrderDetails()
            
            Task { @MainActor in
                self.state = state
                self.orderAmount = orderEnvelope.order().amount
                self.orderPrice = orderEnvelope.order().price
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
