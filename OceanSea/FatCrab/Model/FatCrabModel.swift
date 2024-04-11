//
//  FatCrabModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import Foundation

@Observable class FatCrabModel: FatCrabProtocol {
    private let trader: FatCrabTrader  // Should we inject this? Or is this good?
    
    let MNEMONIC_KEYCHAIN_WRAPPER_KEY: String = "mnemonic"
    
    var mnemonic: [String]
    var totalBalance: Int
    var spendableBalance: Int
    var allocatedAmount: Int
    var blockHeight: UInt
    var relays: [RelayInfo]
    
    var queriedOrders: [UUID: FatCrabOrderEnvelopeProtocol]
    var trades: [UUID: FatCrabTrade]
    
    init() {
        let url = "ssl://electrum.blockstream.info:60002"
        let network = Network.testnet
        let info = BlockchainInfo.electrum(url: url, network: network)
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        
        mnemonic = []
        totalBalance = 0
        spendableBalance = 0
        allocatedAmount = 0
        blockHeight = 0
        relays = []
        
        queriedOrders = [:]
        trades = [:]
        
        if let storedMnemonic = KeychainWrapper.standard.string(forKey: MNEMONIC_KEYCHAIN_WRAPPER_KEY, withAccessibility: .whenUnlocked) {
            trader = FatCrabTrader.newWithMnemonic(mnemonic: storedMnemonic, info: info, appDirPath: appDir[0])
            
            mnemonic = storedMnemonic.components(separatedBy: " ")
        } else {
            trader = FatCrabTrader(info: info, appDirPath: appDir[0])
            
            Task {
                // Update initial values asynchronously
                let walletMnemonic = try trader.walletBip39Mnemonic()
                KeychainWrapper.standard.set(walletMnemonic, forKey: MNEMONIC_KEYCHAIN_WRAPPER_KEY, withAccessibility: .whenUnlocked)
                
                Task { @MainActor in
                    mnemonic = walletMnemonic.components(separatedBy: " ")
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            do {
                let blockchainHeight = try self.trader.walletBlockchainHeight()
                
                Task { @MainActor in
                    if blockchainHeight > self.blockHeight {
                        self.blockHeight = UInt(blockchainHeight)
                        try await self.updateBalances()
                    }
                }
            } catch {
                NSLog("Error getting block height: \(error)")
            }
        }
        
        Task {
            // Restore relays
            let restoredRelays = trader.getRelays()
            
            // Restore trades
            await updateTrades()
        
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
                allocatedAmount = Int(walletBalances.allocated)
                spendableBalance = Int(walletBalances.confirmed) - Int(walletBalances.allocated)
                totalBalance = allocatedAmount + spendableBalance + Int(walletBalances.trustedPending)
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
            let uuid = UUID()
            let taker = try trader.newBuyTaker(orderEnvelope: orderEnvelope)
            let takerModel = FatCrabTakerBuyModel(taker: taker)
            let takerTrade = FatCrabTakerTrade.buy(taker: takerModel)
            
            Task { @MainActor in
                trades.updateValue(.taker(taker: takerTrade), forKey: uuid)
            }
            
            _ = try taker.takeOrder()
            return takerModel
        }.value
    }
    
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) async throws -> any FatCrabTakerSellProtocol {
        try await Task {
            let uuid = UUID()
            let taker = try trader.newSellTaker(orderEnvelope: orderEnvelope, fatcrabRxAddr: fatcrabRxAddr)
            let takerModel = FatCrabTakerSellModel(taker: taker)
            let takerTrade = FatCrabTakerTrade.sell(taker: takerModel)
            
            Task { @MainActor in
                trades.updateValue(.taker(taker: takerTrade), forKey: uuid)
            }
            
            _ = try taker.takeOrder()
            return takerModel
        }.value
    }
    
    func updateTrades() async {
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
    
    // Async/Await Task wrappers
    
    func walletGetHeight() async throws -> UInt32 {
        try await Task {
            try trader.walletBlockchainHeight()
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
