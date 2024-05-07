//
//  FatCrabModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import Foundation
import OSLog

@Observable class FatCrabModel: FatCrabProtocol {
    private let trader: FatCrabTrader  // Should we inject this? Or is this good?
    
    static let MNEMONIC_KEYCHAIN_WRAPPER_KEY: String = "mnemonic"
    
    var mnemonic: [String]
    var trustedPendingAmount: Int
    var untrustedPendingAmount: Int
    var confirmedAmount: Int
    var allocatedAmount: Int
    var blockHeight: UInt
    var relays: [RelayInfo]
    
    var queriedOrders: [UUID: FatCrabOrderEnvelopeProtocol]
    var trades: [UUID: FatCrabTrade]
    
    static func resetWallet(with mnemonic: [String]) -> any FatCrabProtocol {
        let walletMnemonic = mnemonic.joined(separator: " ")
        KeychainWrapper.standard.removeObject(forKey: MNEMONIC_KEYCHAIN_WRAPPER_KEY)
        KeychainWrapper.standard.set(walletMnemonic, forKey: MNEMONIC_KEYCHAIN_WRAPPER_KEY, withAccessibility: .whenUnlocked)
        return FatCrabModel()
    }
    
    init() {
        let url = "ssl://electrum.blockstream.info:60002"
        let network = Network.testnet
        let info = BlockchainInfo.electrum(url: url, network: network)
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        
        mnemonic = []
        trustedPendingAmount = 0
        untrustedPendingAmount = 0
        confirmedAmount = 0
        allocatedAmount = 0
        blockHeight = 0
        relays = []
        
        queriedOrders = [:]
        trades = [:]
        
        if let storedMnemonic = KeychainWrapper.standard.string(forKey: Self.MNEMONIC_KEYCHAIN_WRAPPER_KEY, withAccessibility: .whenUnlocked) {
            trader = FatCrabTrader.newWithMnemonic(prodLvl: .debug, mnemonic: storedMnemonic, info: info, appDirPath: appDir[0])
            mnemonic = storedMnemonic.components(separatedBy: " ")
        } else {
            trader = FatCrabTrader(prodLvl: .debug, info: info, appDirPath: appDir[0])
            
            Task {
                // Update initial values asynchronously
                let walletMnemonic = try trader.walletBip39Mnemonic()
                KeychainWrapper.standard.set(walletMnemonic, forKey: Self.MNEMONIC_KEYCHAIN_WRAPPER_KEY, withAccessibility: .whenUnlocked)
                
                Task { @MainActor in
                    mnemonic = walletMnemonic.components(separatedBy: " ")
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            Task {
                do {
                    let blockchainHeight = try self.trader.walletBlockchainHeight()
                    
                    Task { @MainActor in
                        if blockchainHeight > self.blockHeight {
                            self.blockHeight = UInt(blockchainHeight)
                        }
                        try await self.updateBalances()
                    }
                } catch {
                    Logger.appInterface.error("Error getting block height: \(error)")
                }
            }
        }
        
        Task {
            // Restore relays
            let restoredRelays = trader.getRelays()
            
            // Restore trades
            await restoreTrades()
        
            // Everything restored - Reconnect relays
            try trader.reconnect()
            
            Task { @MainActor in
                relays = restoredRelays
            }
        }
    }
    
    func updateBalances() async throws {
        try await Task {
            try trader.walletBlockchainSync()
            let walletBalances = try self.trader.walletBalances()
            
            Task { @MainActor in
                trustedPendingAmount = Int(walletBalances.trustedPending)
                untrustedPendingAmount = Int(walletBalances.untrustedPending)
                confirmedAmount = Int(walletBalances.confirmed)
                allocatedAmount = Int(walletBalances.allocated)
            }
        }.value
    }
    
    func addRelays(relayAddrs: [RelayAddr]) async throws {
        try await Task {
            try trader.addRelays(relayAddrs: relayAddrs)
            
            Task { @MainActor in
                relays = trader.getRelays()
            }
        }.value
    }
    
    func removeRelay(url: String) async throws {
        try await Task {
            try trader.removeRelay(url: url)
            
            Task { @MainActor in
                relays = trader.getRelays()
            }
        }.value
    }
    
    func updateOrderBook() async throws {
        try await Task {
            let envelopes = try trader.queryOrders(orderType: nil)
            let orders = envelopes.reduce(into: [UUID: FatCrabOrderEnvelope]()) {
                $0[UUID(uuidString: $1.order().tradeUuid)!] = $1
            }

            Task { @MainActor in
                queriedOrders = orders
            }
        }.value
    }
    
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) async throws -> any FatCrabMakerBuyProtocol {
        try await Task {
            let uuid = UUID()
            let order = FatCrabOrder(orderType: FatCrabOrderType.buy, tradeUuid: uuid.uuidString, amount: amount, price: price)
            let maker = try trader.newBuyMaker(order: order, fatcrabRxAddr: fatcrabRxAddr)
            let makerModel = FatCrabMakerBuyModel(maker: maker)
            let makerTrade = FatCrabMakerTrade.buy(maker: makerModel)
            
            Task { @MainActor in
                trades.updateValue(.maker(maker: makerTrade), forKey: uuid)
            }
            
            _ = try maker.postNewOrder()
            return makerModel
        }.value
    }
    
    func makeSellOrder(price: Double, amount: Double) async throws -> any FatCrabMakerSellProtocol {
        try await Task {
            let uuid = UUID()
            let order = FatCrabOrder(orderType: FatCrabOrderType.sell, tradeUuid: uuid.uuidString, amount: amount, price: price)
            let maker = try trader.newSellMaker(order: order)
            let makerModel = FatCrabMakerSellModel(maker: maker)
            let makerTrade = FatCrabMakerTrade.sell(maker: makerModel)
            
            Task { @MainActor in
                trades.updateValue(.maker(maker: makerTrade), forKey: uuid)
            }
            
            _ = try maker.postNewOrder()
            return makerModel
        }.value
    }
    
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) async throws -> any FatCrabTakerBuyProtocol {
        try await Task {
            let tradeUuid = UUID(uuidString: orderEnvelope.order().tradeUuid)!
            let taker = try trader.newBuyTaker(orderEnvelope: orderEnvelope)
            let takerModel = FatCrabTakerBuyModel(taker: taker)
            let takerTrade = FatCrabTakerTrade.buy(taker: takerModel)
            
            Task { @MainActor in
                trades.updateValue(.taker(taker: takerTrade), forKey: tradeUuid)
            }
            
            _ = try taker.takeOrder()
            return takerModel
        }.value
    }
    
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) async throws -> any FatCrabTakerSellProtocol {
        try await Task {
            let tradeUuid = UUID(uuidString: orderEnvelope.order().tradeUuid)!
            let taker = try trader.newSellTaker(orderEnvelope: orderEnvelope, fatcrabRxAddr: fatcrabRxAddr)
            let takerModel = FatCrabTakerSellModel(taker: taker)
            let takerTrade = FatCrabTakerTrade.sell(taker: takerModel)
            
            Task { @MainActor in
                trades.updateValue(.taker(taker: takerTrade), forKey: tradeUuid)
            }
            
            _ = try taker.takeOrder()
            return takerModel
        }.value
    }
    
    func restoreTrades() async {
        await Task {
            let buyMakers = trader.getBuyMakers();
            let sellMakers = trader.getSellMakers();
            let buyTakers = trader.getBuyTakers();
            let sellTakers = trader.getSellTakers();
                
            Task { @MainActor [buyMakers, sellMakers, buyTakers, sellTakers] in
                buyMakers.forEach { (uuid: String, buyMaker: FatCrabBuyMaker) in
                    if !trades.contains(where: { $0.key == UUID(uuidString: uuid) }) {
                        let buyMakerModel = FatCrabMakerBuyModel(maker: buyMaker)
                        let makerTrade = FatCrabMakerTrade.buy(maker: buyMakerModel)
                        trades.updateValue(FatCrabTrade.maker(maker: makerTrade), forKey: UUID(uuidString: uuid)!)
                    }
                }
                
                sellMakers.forEach { (uuid: String, sellMaker: FatCrabSellMaker) in
                    if !trades.contains(where: { $0.key == UUID(uuidString: uuid) }) {
                        let sellMakerModel = FatCrabMakerSellModel(maker: sellMaker)
                        let makerTrade = FatCrabMakerTrade.sell(maker: sellMakerModel)
                        trades.updateValue(FatCrabTrade.maker(maker: makerTrade), forKey: UUID(uuidString: uuid)!)
                    }
                }
                
                buyTakers.forEach { (uuid: String, buyTaker: FatCrabBuyTaker) in
                    if !trades.contains(where: { $0.key == UUID(uuidString: uuid) }) {
                        let buyTakerModel = FatCrabTakerBuyModel(taker: buyTaker)
                        let takerTrade = FatCrabTakerTrade.buy(taker: buyTakerModel)
                        trades.updateValue(FatCrabTrade.taker(taker: takerTrade), forKey: UUID(uuidString: uuid)!)
                    }
                }
                
                sellTakers.forEach { (uuid: String, sellTaker: FatCrabSellTaker) in
                    if !trades.contains(where: { $0.key == UUID(uuidString: uuid) }) {
                        let sellTakerModel = FatCrabTakerSellModel(taker: sellTaker)
                        let takerTrade = FatCrabTakerTrade.sell(taker: sellTakerModel)
                        trades.updateValue(FatCrabTrade.taker(taker: takerTrade), forKey: UUID(uuidString: uuid)!)
                    }
                }
            }
        }.value
    }
    
    func cancelTrade(for maker: FatCrabMakerTrade) async throws {
        try await maker.cancelOrder()
    }
    
    // Async/Await Task wrappers
    
    func walletGetHeight() async throws -> UInt {
        try await Task {
            let blockchainHeight = UInt(try trader.walletBlockchainHeight())
            Task { @MainActor in
                self.blockHeight = blockchainHeight
            }
            return blockchainHeight
        }.value
    }
    
    func walletSendToAddress(address: String, amount: UInt) async throws -> String {
        try await Task {
            try trader.walletSendToAddress(address: address, amount: UInt64(amount))
        }.value
    }
    
    func walletGenerateReceiveAddress() async throws -> String {
        try await Task {
            try trader.walletGenerateReceiveAddress()
        }.value
    }
}

extension FatCrabError {
    func description() -> String {
        switch self {
        case .TxNotFound:
            return "FatCrab-Error | Transaction not found"
        case .TxUnconfirmed:
            return "FatCrab-Error | Transaction unconfirmed"
        case .Simple(let description):
            return description
        case .N3xb(let description):
            return description
        case .BdkBip39(let description):
            return description
        case .Bdk(let description):
            return description
        case .Io(let description):
            return description
        case .JoinError(let description):
            return description
        case .SerdesJson(let description):
            return description
        case .UrlParse(let description):
            return description
        case .MpscSend(let description):
            return description
        case .OneshotRecv(let description):
            return description
        }
    }
}
