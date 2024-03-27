//
//  FatCrabProtocol.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

enum FatCrabMakerTrade {
    case buy(maker: any FatCrabMakerBuyProtocol)
    case sell(maker: any FatCrabMakerSellProtocol)
    
    var state: FatCrabMakerState {
        switch self {
        case .buy(let maker):
            return maker.state
        case .sell(let maker):
            return maker.state
        }
    }
    
    var orderType: FatCrabOrderType {
        switch self {
        case .buy:
            return .buy
        case .sell:
            return .sell
        }
    }
    
    var orderPrice: Double {
        switch self {
        case .buy(let maker):
            return maker.orderPrice
        case .sell(let maker):
            return maker.orderPrice
        }
    }
    
    var orderAmount: Double {
        switch self {
        case .buy(let maker):
            return maker.orderAmount
        case .sell(let maker):
            return maker.orderAmount
        }
    }
    
    var tradeUuid: UUID {
        switch self {
        case .buy(let maker):
            return maker.tradeUuid
        case .sell(let maker):
            return maker.tradeUuid
        }
    }
    
    var peerPubkey: String? {
        switch self {
        case .buy(let maker):
            return maker.peerPubkey
        case .sell(let maker):
            return maker.peerPubkey
        }
    }
    
    var offers: [FatCrabOfferEnvelope] {
        switch self {
        case .buy(let maker):
            return maker.offerEnvelopes
        case .sell(let maker):
            return maker.offerEnvelopes
        }
    }
    
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) throws {
        switch self {
        case .buy(let maker):
            try maker.tradeResponse(tradeRspType: tradeRspType, offerEnvelope: offerEnvelope)
        case .sell(let maker):
            try maker.tradeResponse(tradeRspType: tradeRspType, offerEnvelope: offerEnvelope)
        }
    }
}

enum FatCrabTakerTrade {
    case buy(taker: any FatCrabTakerBuyProtocol)
    case sell(taker: any FatCrabTakerSellProtocol)
    
    var state : FatCrabTakerState {
        switch self {
        case .buy(let taker):
            return taker.state
        case .sell(let taker):
            return taker.state
        }
    }
    
    var orderType: FatCrabOrderType {
        switch self {
        case .buy:
            return .buy
        case .sell:
            return .sell
        }
    }
    
    var orderPrice: Double {
        switch self {
        case .buy(let taker):
            return taker.orderPrice
        case .sell(let taker):
            return taker.orderPrice
        }
    }
    
    var orderAmount: Double {
        switch self {
        case .buy(let taker):
            return taker.orderAmount
        case .sell(let taker):
            return taker.orderAmount
        }
    }
    
    var tradeUuid: UUID {
        switch self {
        case .buy(let taker):
            return taker.tradeUuid
        case .sell(let taker):
            return taker.tradeUuid
        }
    }
    
    var peerPubkey: String {
        switch self {
        case .buy(let taker):
            return taker.peerPubkey
        case .sell(let taker):
            return taker.peerPubkey
        }
    }
    
    func tradeComplete() throws {
        switch self {
        case .buy(let taker):
            try taker.tradeComplete()
        case .sell(let taker):
            try taker.tradeComplete()
        }
    }
}

enum FatCrabTrade {
    case maker(maker: FatCrabMakerTrade)
    case taker(taker: FatCrabTakerTrade)
    
    var tradeType: FatCrabTradeType {
        switch self {
        case .maker:
            return .maker
        case .taker:
            return .taker
        }
    }
    
    var orderType: FatCrabOrderType {
        switch self {
        case .maker(let maker):
            return maker.orderType
        case .taker(let taker):
            return taker.orderType
        }
    }
    
    var orderPrice: Double {
        switch self {
        case .maker(let maker):
            return maker.orderPrice
        case .taker(let taker):
            return taker.orderPrice
        }
    }
    
    var orderAmount: Double {
        switch self {
        case .maker(let maker):
            return maker.orderAmount
        case .taker(let taker):
            return taker.orderAmount
        }
    }
    
    var tradeUuid: UUID {
        switch self {
        case .maker(let maker):
            return maker.tradeUuid
        case .taker(let taker):
            return taker.tradeUuid
        }
    }
    
    var peerPubkey: String? {
        switch self {
        case .maker(let maker):
            maker.peerPubkey
        case .taker(let taker):
            taker.peerPubkey
        }
    }
}

struct FatCrabModelKey: EnvironmentKey {
    static let defaultValue: any FatCrabProtocol = FatCrabMock()
}

extension EnvironmentValues {
    var fatCrabModel: any FatCrabProtocol {
        get { self[FatCrabModelKey.self] }
        set { self[FatCrabModelKey.self] = newValue }
    }
}

protocol FatCrabProtocol: ObservableObject {
    var totalBalance: Int { get }
    var spendableBalance: Int { get }
    var allocatedAmount: Int { get }
    var mnemonic: [String] { get }
    
    func updateBalances()
    func walletGenerateReceiveAddress() async throws -> String
    
    var relays: [RelayInfo] { get }
    func addRelays(relayAddrs: [RelayAddr]) throws
    func removeRelay(url: String) throws
    
    var queriedOrders: [UUID: FatCrabOrderEnvelopeProtocol] { get }
    func updateOrderBook()
    
    var trades: [UUID: FatCrabTrade] { get }
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) throws -> any FatCrabMakerBuyProtocol
    func makeSellOrder(price: Double, amount: Double) throws -> any FatCrabMakerSellProtocol
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) throws -> any FatCrabTakerBuyProtocol
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) throws -> any FatCrabTakerSellProtocol
    func updateTrades()
}

protocol FatCrabMakerBuyProtocol: ObservableObject {
    var state: FatCrabMakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeUuid: UUID { get }
    var peerPubkey: String? { get }
    var offerEnvelopes: [FatCrabOfferEnvelope] { get }
    var peerEnvelope: FatCrabPeerEnvelope? { get }
    
    func postNewOrder() throws
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) throws
    func releaseNotifyPeer() throws
    func tradeComplete() throws
}

protocol FatCrabMakerSellProtocol: ObservableObject {
    var state: FatCrabMakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeUuid: UUID { get }
    var peerPubkey: String? { get }
    var offerEnvelopes: [FatCrabOfferEnvelope] { get }
    var peerEnvelope: FatCrabPeerEnvelope? { get }
    
    func postNewOrder() throws
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) throws
    func checkBtcTxConfirmation() async throws -> UInt32
    func notifyPeer(fatcrabTxid: String) throws
    func tradeComplete() throws
}

protocol FatCrabTakerBuyProtocol: ObservableObject {
    var state: FatCrabTakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeUuid: UUID { get }
    var peerPubkey: String { get }
    var tradeRspEnvelope: FatCrabTradeRspEnvelope? { get }
    
    func takeOrder() throws
    func notifyPeer(fatcrabTxid: String) throws
    func checkBtcTxConfirmation() async throws -> UInt32
    func tradeComplete() throws
}

protocol FatCrabTakerSellProtocol: ObservableObject {
    var state: FatCrabTakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeUuid: UUID { get }
    var peerPubkey: String { get }
    
    func takeOrder() throws
    func tradeComplete() throws
}
