//
//  FatCrabMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import Foundation

class FatCrabOrderEnvelopeMock: FatCrabOrderEnvelopeProtocol {
    let innerOrder: FatCrabOrder
    
    init(order: FatCrabOrder) {
        self.innerOrder = order
    }
    
    func order() -> FatCrabOrder { innerOrder }
    func pubkey() -> String { "SomeMockPubkey" }
}

@Observable class FatCrabMock: FatCrabProtocol {
    var mnemonic: [String]
    var trustedPendingAmount: Int
    var untrustedPendingAmount: Int
    var confirmedAmount: Int
    var allocatedAmount: Int
    var blockHeight: UInt
    var relays: [RelayInfo]
    
    var queriedOrders: [UUID: FatCrabOrderEnvelopeProtocol]
    var trades: [UUID : FatCrabTrade]
    
    static func resetWallet(with mnemonic: [String]) -> any FatCrabProtocol {
        FatCrabMock()
    }
    
    init() {
        trustedPendingAmount = 0
        untrustedPendingAmount = 0
        confirmedAmount = 0
        allocatedAmount = 0
        blockHeight = 0
        mnemonic = ["Word1", "Word2", "Word3", "Word4", "Word5", "Word6", "Word7", "Word8", "Word9", "Word10", "Word11", "Word12", "Word13", "Word14", "Word15", "Word16", "Word17", "Word18", "Word19", "Word20", "Word21", "Word22", "Word23", "Word24"]
        
        let relayAddr1 = RelayAddr(url: "https://relay1.fatcrab.nostr", socketAddr: nil)
        let relayAddr2 = RelayAddr(url: "https://relay2.fatcrab.nostr", socketAddr: nil)
        let relayInfo1 = Self.createRelayInfo(relayAddr: relayAddr1)
        let relayInfo2 = Self.createRelayInfo(relayAddr: relayAddr2)
        relays = [relayInfo1, relayInfo2]
        
        trades = [:]
        queriedOrders = [:]
        
        updateBalances()
        
        // This will randomly generate up to 5 orders
        updateOrderBook()
        updateOrderBook()
        updateOrderBook()
        updateOrderBook()
        updateOrderBook()
        
        // This will randomly generate up to 3 trades
        restoreTrades()
        restoreTrades()
        restoreTrades()
    }
    
    func walletGetHeight() async throws -> UInt {
        // Generate random UInt32 between 738755 to 93438755
        let height = UInt.random(in: 738755...93438755)
        blockHeight = height
        return height
    }
    
    func walletSendToAddress(address: String, amount: UInt) async throws -> String {
        return UUID().uuidString
    }
    
    func walletGenerateReceiveAddress() async throws -> String {
        try await Task.sleep(nanoseconds: 10_000_000)
        return "bc1q3048unvsjhdfgpvw9ehmyvp0ijgmcwhergvmw0eirjgcm"
    }
    
    func updateBalances() {
        Task {
            try await Task.sleep(nanoseconds: 10_000_000)
            
            Task { @MainActor in
                trustedPendingAmount = 123456
                untrustedPendingAmount = 234567
                confirmedAmount = 2309465
                allocatedAmount = 345678
                blockHeight = 738755
            }
        }
    }
    
    private static func createRelayInfo(relayAddr: RelayAddr) -> RelayInfo {
        let relayStatus = RelayStatus.connected
        let relayInfoDocument = RelayInformationDocument(name: relayAddr.url, description: nil, pubkey: nil, contact: nil, supportedNips: nil, software: nil, version: nil, relayCountries: [], languageTags: [], tags: [], postingPolicy: nil, paymentsUrl: nil, icon: nil)
        return RelayInfo(url: relayAddr.url, status: relayStatus, document: relayInfoDocument)
    }
    
    func addRelays(relayAddrs: [RelayAddr]) throws {
        relayAddrs.forEach { relayAddr in
            let relayInfo = Self.createRelayInfo(relayAddr: relayAddr)
            relays.append(relayInfo)
        }
    }
    
    func removeRelay(url: String) throws {
        relays.removeAll { relayInfo in
            relayInfo.url == url
        }
    }
    
    func generateOrderEnvelope() -> FatCrabOrderEnvelopeProtocol {
        let orderType: FatCrabOrderType = Bool.random() ? .buy : .sell
        let tradeUuid = UUID()
        let amount = Double.random(in: 1...1000000)
        let price = Double.random(in: 1...1000000)
        
        let queriedOrder = FatCrabOrder(orderType: orderType, tradeUuid: tradeUuid.uuidString, amount: amount, price: price)
        queriedOrders.updateValue(FatCrabOrderEnvelopeMock(order: queriedOrder), forKey: tradeUuid)
        
        return FatCrabOrderEnvelopeMock(order: queriedOrder)
    }
    
    func addToOrderBook() {
        let orderEnvelope = generateOrderEnvelope()
        let uuid = UUID(uuidString: orderEnvelope.order().tradeUuid)!
        self.queriedOrders.updateValue(orderEnvelope, forKey: uuid)
    }
    
    func updateOrderBook() {
        if Bool.random() {
            addToOrderBook()
        } else if queriedOrders.count > 0 {
            let index = Int.random(in: 0..<queriedOrders.count)
            self.queriedOrders.removeValue(forKey: Array(queriedOrders.keys)[index])
        }
    }
    
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) throws -> any FatCrabMakerBuyProtocol {
        FatCrabMakerBuyMock(state: .new, amount: amount, price: price, tradeUuid: UUID())
    }
    
    func makeSellOrder(price: Double, amount: Double) throws -> any FatCrabMakerSellProtocol {
        FatCrabMakerSellMock(state: .new, amount: amount, price: price, tradeUuid: UUID())
    }
    
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) throws -> any FatCrabTakerBuyProtocol {
        let order = orderEnvelope.order()
        return FatCrabTakerBuyMock(state: .new, amount: order.amount, price: order.price, tradeUuid: UUID(), peerPubkey: "SomePubKey-000-0026")
    }
    
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) throws -> any FatCrabTakerSellProtocol {
        let order = orderEnvelope.order()
        return FatCrabTakerSellMock(state: .new, amount: order.amount, price: order.price, tradeUuid: UUID(), peerPubkey: "SomePubKey-004-0033")
    }
    
    func getRandomOrderUuid() -> UUID {
        let index = Int.random(in: 0..<queriedOrders.count)
        return Array(queriedOrders.keys)[index]
    }
    
    func generateTrade() -> FatCrabTrade {
        let orderType: FatCrabOrderType = Bool.random() ? .buy : .sell
        let amount = Double.random(in: 1...1000000)
        let price = Double.random(in: 1...1000000)
        let isMaker = Bool.random()
        
        if isMaker {
            let state = FatCrabMakerState.random(for: orderType)
            switch orderType {
            case .buy:
                let maker = FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: state, amount: amount, price: price, tradeUuid: UUID()))
                return FatCrabTrade.maker(maker: maker)
                
            case .sell:
                let maker =  FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: state, amount: amount, price: price, tradeUuid: UUID()))
                return FatCrabTrade.maker(maker: maker)
            }
        } else {
            let state = FatCrabTakerState.random(for: orderType)
            switch orderType {
            case .buy:
                let taker = FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: state, amount: amount, price: price, tradeUuid: UUID(), peerPubkey: "SomePubKey-002-3443"))
                return FatCrabTrade.taker(taker: taker)
                
            case .sell:
                let taker = FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: state, amount: amount, price: price, tradeUuid: UUID(), peerPubkey: "SomePubKey-934-3850"))
                return FatCrabTrade.taker(taker: taker)
            }
        }
    }
    
    func addToCurrentTrades() {
        let trade = generateTrade()
        let uuid = UUID()
        trades.updateValue(trade, forKey: uuid)
    }
    
    func cancelTrade(for maker: FatCrabMakerTrade) async throws {
        trades.removeValue(forKey: maker.tradeUuid)
    }
        
    func restoreTrades() {
        if Bool.random() {
            addToCurrentTrades()
        } else if trades.count > 0 {
            let index = Int.random(in: 0..<trades.count)
            self.trades.removeValue(forKey: Array(trades.keys)[index])
        }
    }
    
    func getRandomTradeUuid() -> UUID {
        let index = Int.random(in: 0..<trades.count)
        return Array(trades.keys)[index]
    }
}

extension FatCrabMakerState: CaseIterable {
    public static var allCases: [FatCrabMakerState] {
        return [.new, .waitingForOffers, .receivedOffer, .acceptedOffer, .inboundBtcNotified, .inboundFcNotified, .notifiedOutbound, .tradeCompleted]
    }
}

extension FatCrabMakerState {
    static func random(for orderType: FatCrabOrderType) -> FatCrabMakerState {
        switch orderType {
        case .buy:
            return Self.random(except: .inboundBtcNotified)
        case .sell:
            return Self.random(except: .inboundFcNotified)
        }
    }
    
    static func random(except: FatCrabMakerState) -> FatCrabMakerState {
        var randomState: FatCrabMakerState
        repeat {
            let randomIndex = Int.random(in: 0..<FatCrabMakerState.allCases.count)
            randomState = FatCrabMakerState.allCases[randomIndex]
        } while randomState == except
        return randomState
    }
}

extension FatCrabTakerState: CaseIterable {
    public static var allCases: [FatCrabTakerState] {
        return [.new, .submittedOffer, .offerAccepted, .offerRejected, .notifiedOutbound, .inboundBtcNotified, .inboundFcNotified, .tradeCompleted]
    }
}

extension FatCrabTakerState {
    static func random(for orderType: FatCrabOrderType) -> FatCrabTakerState {
        switch orderType {
        case .buy:
            return Self.random(except: .inboundFcNotified)
        case .sell:
            return Self.random(except: .inboundBtcNotified)
        }
    }
    
    static func random(except: FatCrabTakerState) -> FatCrabTakerState {
        var randomState: FatCrabTakerState
        repeat {
            let randomIndex = Int.random(in: 0..<FatCrabTakerState.allCases.count)
            randomState = FatCrabTakerState.allCases[randomIndex]
        } while randomState == except
        return randomState
    }
}
