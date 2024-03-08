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
}

@Observable class FatCrabMock: FatCrabProtocol {
    var totalBalance: Int
    var spendableBalance: Int
    var allocatedAmount: Int
    var mnemonic: [String]
    var relays: [RelayInfo]
    
    var queriedOrders: [UUID: FatCrabOrderEnvelopeProtocol]
    var trades: [UUID : FatCrabTrade]
    
    init() {
        totalBalance = 0
        spendableBalance = 0
        allocatedAmount = 0
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
        updateTrades()
        updateTrades()
        updateTrades()
    }
    
    func walletGenerateReceiveAddress() async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "bc1q3048unvsjhdfgpvw9ehmyvp0ijgmcwhergvmw0eirjgcm"
    }
    
    func updateBalances() {
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            Task { @MainActor in
                totalBalance = 123456
                spendableBalance = 234567
                allocatedAmount = 345678
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
        FatCrabMakerBuyMock(amount: amount, price: price)
    }
    
    func makeSellOrder(price: Double, amount: Double) throws -> any FatCrabMakerSellProtocol {
        FatCrabMakerSellMock(amount: amount, price: price)
    }
    
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) throws -> any FatCrabTakerBuyProtocol {
        let order = orderEnvelope.order()
        return FatCrabTakerBuyMock(amount: order.amount, price: order.price)
    }
    
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) throws -> any FatCrabTakerSellProtocol {
        let order = orderEnvelope.order()
        return FatCrabTakerSellMock(amount: order.amount, price: order.price)
    }
    
    func generateTrade() -> FatCrabTrade {
        let orderType: FatCrabOrderType = Bool.random() ? .buy : .sell
        let amount = Double.random(in: 1...1000000)
        let price = Double.random(in: 1...1000000)
        let isMaker = Bool.random()
        
        if isMaker {
            switch orderType {
            case .buy:
                let maker = FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(amount: amount, price: price))
                return FatCrabTrade.maker(maker: maker)
                
            case .sell:
                let maker =  FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(amount: amount, price: price))
                return FatCrabTrade.maker(maker: maker)
            }
        } else {
            switch orderType {
            case .buy:
                let taker = FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(amount: amount, price: price))
                return FatCrabTrade.taker(taker: taker)
                
            case .sell:
                let taker = FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(amount: amount, price: price))
                return FatCrabTrade.taker(taker: taker)
            }
        }
    }
    
    func addToCurrentTrades() {
        let trade = generateTrade()
        let uuid = UUID()
        trades.updateValue(trade, forKey: uuid)
    }
    
    func updateTrades() {
        if Bool.random() {
            addToCurrentTrades()
        } else if trades.count > 0 {
            let index = Int.random(in: 0..<trades.count)
            self.trades.removeValue(forKey: Array(trades.keys)[index])
        }
    }
}
