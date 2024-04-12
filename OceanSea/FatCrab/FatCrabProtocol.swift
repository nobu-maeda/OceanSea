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
    
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) async throws {
        switch self {
        case .buy(let maker):
            try await maker.tradeResponse(tradeRspType: tradeRspType, offerEnvelope: offerEnvelope)
        case .sell(let maker):
            try await maker.tradeResponse(tradeRspType: tradeRspType, offerEnvelope: offerEnvelope)
        }
    }
    
    func tradeComplete() async throws {
        switch self {
        case .buy(let maker):
            try await maker.tradeComplete()
        case .sell(let maker):
            try await maker.tradeComplete()
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
    
    func tradeComplete() async throws {
        switch self {
        case .buy(let taker):
            try await taker.tradeComplete()
        case .sell(let taker):
            try await taker.tradeComplete()
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

extension FatCrabMakerState {
    var string: String {
        switch self {
        case .new:
            return "New"
        case .waitingForOffers:
            return "Waiting For Offers"
        case .receivedOffer:
            return "Received Offer"
        case .acceptedOffer:
            return "Accepted Offer"
        case .inboundBtcNotified:
            return "Inbound BTC Notified"
        case .inboundFcNotified:
            return "Inbound FC Notified"
        case .notifiedOutbound:
            return "Notified Outbound"
        case .tradeCompleted:
            return "Trade Completed"
        }
    }
}

extension FatCrabTakerState {
    var string: String {
        switch self {
        case .new:
            return "New"
        case .submittedOffer:
            return "Submitted Offers"
        case .offerAccepted:
            return "Offer Accepted"
        case .offerRejected:
            return "Offer Rejected"
        case .notifiedOutbound:
            return "Notified Outbound"
        case .inboundBtcNotified:
            return "Inbound BTC Notified"
        case .inboundFcNotified:
            return "Inbound FC Notified"
        case .tradeCompleted:
            return "Trade Completed"
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
    var mnemonic: [String] { get }
    var trustedPendingAmount: Int { get }
    var untrustedPendingAmount: Int { get }
    var confirmedAmount: Int { get }
    var allocatedAmount: Int { get }
    var blockHeight: UInt { get }
    
    func updateBalances() async throws
    func walletGetHeight() async throws -> UInt32
    func walletGenerateReceiveAddress() async throws -> String
    
    var relays: [RelayInfo] { get }
    func addRelays(relayAddrs: [RelayAddr]) async throws
    func removeRelay(url: String) async throws
    
    var queriedOrders: [UUID: FatCrabOrderEnvelopeProtocol] { get }
    func updateOrderBook() async throws
    
    var trades: [UUID: FatCrabTrade] { get }
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) async throws -> any FatCrabMakerBuyProtocol
    func makeSellOrder(price: Double, amount: Double) async throws -> any FatCrabMakerSellProtocol
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) async throws -> any FatCrabTakerBuyProtocol
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) async throws -> any FatCrabTakerSellProtocol
    func restoreTrades() async
}

protocol FatCrabMakerBuyProtocol: ObservableObject {
    var state: FatCrabMakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeUuid: UUID { get }
    var peerPubkey: String? { get }
    var peerFcTxid: String? { get }
    var offerEnvelopes: [FatCrabOfferEnvelope] { get }
    var peerEnvelope: FatCrabPeerEnvelope? { get }
    
    func postNewOrder() async throws
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) async throws
    func releaseNotifyPeer() async throws
    func tradeComplete() async throws
}

protocol FatCrabMakerSellProtocol: ObservableObject {
    var state: FatCrabMakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeUuid: UUID { get }
    var peerPubkey: String? { get }
    var peerFcAddr: String? { get }
    var peerBtcTxid: String? { get }
    var offerEnvelopes: [FatCrabOfferEnvelope] { get }
    var peerEnvelope: FatCrabPeerEnvelope? { get }
    
    func postNewOrder() async throws
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) async throws
    func checkBtcTxConfirmation() async throws -> UInt32
    func notifyPeer(fatcrabTxid: String) async throws
    func tradeComplete() async throws
}

protocol FatCrabTakerBuyProtocol: ObservableObject {
    var state: FatCrabTakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeUuid: UUID { get }
    var peerPubkey: String { get }
    var peerFcAddr: String? { get }
    var peerBtcTxid: String? { get }
    var tradeRspEnvelope: FatCrabTradeRspEnvelope? { get }
    
    func takeOrder() async throws
    func notifyPeer(fatcrabTxid: String) async throws
    func checkBtcTxConfirmation() async throws -> UInt32
    func tradeComplete() async throws
}

protocol FatCrabTakerSellProtocol: ObservableObject {
    var state: FatCrabTakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeUuid: UUID { get }
    var peerPubkey: String { get }
    var peerFcTxid: String? { get }
    
    func takeOrder() async throws
    func tradeComplete() async throws
}
