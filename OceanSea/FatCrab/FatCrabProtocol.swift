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
}

enum FatCrabTakerTrade {
    case buy(taker: any FatCrabTakerBuyProtocol)
    case sell(taker: any FatCrabTakerSellProtocol)
}

enum FatCrabTrade {
    case maker(maker: FatCrabMakerTrade)
    case taker(taker: FatCrabTakerTrade)
    
    // TODO: Function to get status to assist in sorting
    // TODO: Function to get last updated to assit in sorting
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
    var offers: [FatCrabOfferEnvelope] { get }
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
    var offers: [FatCrabOfferEnvelope] { get }
    var peerEnvelope: FatCrabPeerEnvelope? { get }
    
    func postNewOrder() throws
    func tradeResponse(tradeRspType: FatCrabTradeRspType, offerEnvelope: FatCrabOfferEnvelope) throws
    func checkBtcTxConfirmation() throws -> UInt32
    func notifyPeer(fatcrabTxid: String) throws
    func tradeComplete() throws
}

protocol FatCrabTakerBuyProtocol: ObservableObject {
    var state: FatCrabTakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    var tradeRspEnvelope: FatCrabTradeRspEnvelope? { get }
    
    func takeOrder() throws
    func notifyPeer(fatcrabTxid: String) throws
    func checkBtcTxConfirmation() throws -> UInt32
    func tradeComplete() throws
}

protocol FatCrabTakerSellProtocol: ObservableObject {
    var state: FatCrabTakerState { get }
    var orderAmount: Double { get }
    var orderPrice: Double { get }
    
    func takeOrder() throws
    func tradeComplete() throws
}
