//
//  FatCrabTakerMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/02.
//

import Foundation

@Observable class FatCrabTakerBuyMock: FatCrabTakerBuyProtocol {
    var state: FatCrabTakerState
    var orderAmount: Double
    var orderPrice: Double
    var tradeRspEnvelope: FatCrabTradeRspEnvelope?
    
    init(amount: Double, price: Double, tradeRspEnvelope: FatCrabTradeRspEnvelope? = nil) {
        self.state = FatCrabTakerState.new
        self.orderAmount = amount
        self.orderPrice = price
        self.tradeRspEnvelope = tradeRspEnvelope
    }
    
    func takeOrder() throws {
        self.state = FatCrabTakerState.submittedOffer
    }
    
    func notifyPeer(fatcrabTxid: String) throws {
        self.state = FatCrabTakerState.notifiedOutbound
    }
    
    func checkBtcTxConfirmation() throws -> UInt32 {
        return 6
    }
    
    func tradeComplete() throws {
        self.state = FatCrabTakerState.tradeCompleted
    }
}

@Observable class FatCrabTakerSellMock: FatCrabTakerSellProtocol {
    var state: FatCrabTakerState
    var orderAmount: Double
    var orderPrice: Double
    
    init(amount: Double, price: Double) {
        self.state = FatCrabTakerState.new
        self.orderAmount = amount
        self.orderPrice = price
    }
    
    func takeOrder() throws {
        self.state = FatCrabTakerState.submittedOffer
    }
    
    func tradeComplete() throws {
        self.state = FatCrabTakerState.tradeCompleted
    }
}
