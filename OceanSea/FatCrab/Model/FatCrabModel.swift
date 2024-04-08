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
        relays = []
        
        queriedOrders = [:]
        trades = [:]
        
        if let storedMnemonic = KeychainWrapper.standard.string(forKey: MNEMONIC_KEYCHAIN_WRAPPER_KEY, withAccessibility: .whenUnlocked) {
            trader = FatCrabTrader.newWithMnemonic(mnemonic: storedMnemonic, info: info, appDirPath: appDir[0])
            
            Task { @MainActor in
                mnemonic = storedMnemonic.components(separatedBy: " ")
            }
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
        
        // Restore relays
        relays = trader.getRelays()
        
        // Restore trades
        updateTrades()
        
        Task {
            try trader.reconnect()
        }
    }
    
    func updateBalances() {
        Task {
            try trader.walletBlockchainSync()
            let walletBalances = try self.trader.walletBalances()
            NSLog("walletBalances: \(walletBalances)")
            
            Task { @MainActor in
                allocatedAmount = Int(walletBalances.allocated)
                spendableBalance = Int(walletBalances.confirmed) - Int(walletBalances.allocated)
                totalBalance = allocatedAmount + spendableBalance + Int(walletBalances.trustedPending)
            }
        }
    }
    
    func addRelays(relayAddrs: [RelayAddr]) throws {
        try trader.addRelays(relayAddrs: relayAddrs)
        relays = trader.getRelays()
    }
    
    func removeRelay(url: String) throws {
        try trader.removeRelay(url: url)
        relays = trader.getRelays()
    }
    
    func updateOrderBook() {
        Task {
            do {
                let envelopes = try trader.queryOrders(orderType: nil)
                queriedOrders = envelopes.reduce(into: [UUID: FatCrabOrderEnvelope]()) {
                    $0[UUID(uuidString: $1.order().tradeUuid)!] = $1
                }
            } catch {
                print(error)
            }
        }
    }
    
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) throws -> any FatCrabMakerBuyProtocol {
        let uuid = UUID()
        let order = FatCrabOrder(orderType: FatCrabOrderType.buy, tradeUuid: uuid.uuidString, amount: amount, price: price)
        let maker = try trader.newBuyMaker(order: order, fatcrabRxAddr: fatcrabRxAddr)
        let makerModel = FatCrabMakerBuyModel(maker: maker)
        let makerTrade = FatCrabMakerTrade.buy(maker: makerModel)
        trades.updateValue(.maker(maker: makerTrade), forKey: uuid)
 
        _ = try maker.postNewOrder()
        return makerModel
    }
    
    func makeSellOrder(price: Double, amount: Double) throws -> any FatCrabMakerSellProtocol {
        let uuid = UUID()
        let order = FatCrabOrder(orderType: FatCrabOrderType.sell, tradeUuid: uuid.uuidString, amount: amount, price: price)
        let maker = try trader.newSellMaker(order: order)
        let makerModel = FatCrabMakerSellModel(maker: maker)
        let makerTrade = FatCrabMakerTrade.sell(maker: makerModel)
        trades.updateValue(.maker(maker: makerTrade), forKey: uuid)
        
        _ = try maker.postNewOrder()
        return makerModel
    }
    
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) throws -> any FatCrabTakerBuyProtocol {
        let uuid = UUID()
        let taker = try trader.newBuyTaker(orderEnvelope: orderEnvelope)
        let takerModel = FatCrabTakerBuyModel(taker: taker)
        let takerTrade = FatCrabTakerTrade.buy(taker: takerModel)
        trades.updateValue(.taker(taker: takerTrade), forKey: uuid)
        
        _ = try taker.takeOrder()
        return takerModel
    }
    
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) throws -> any FatCrabTakerSellProtocol {
        let uuid = UUID()
        let taker = try trader.newSellTaker(orderEnvelope: orderEnvelope, fatcrabRxAddr: fatcrabRxAddr)
        let takerModel = FatCrabTakerSellModel(taker: taker)
        let takerTrade = FatCrabTakerTrade.sell(taker: takerModel)
        trades.updateValue(.taker(taker: takerTrade), forKey: uuid)
        
        _ = try taker.takeOrder()
        return takerModel
    }
    
    func updateTrades() {
        Task {
            var newTrades = [UUID: FatCrabTrade]()
            
            trader.getBuyMakers().forEach { (uuid: String, buyMaker: FatCrabBuyMaker) in
                if !trades.contains(where: { $0.key == UUID(uuidString: uuid) }) {
                    let buyMakerModel = FatCrabMakerBuyModel(maker: buyMaker)
                    let makerTrade = FatCrabMakerTrade.buy(maker: buyMakerModel)
                    newTrades.updateValue(FatCrabTrade.maker(maker: makerTrade), forKey: UUID(uuidString: uuid)!)
                }
            }
            
            trader.getSellMakers().forEach { (uuid: String, sellMaker: FatCrabSellMaker) in
                if !trades.contains(where: { $0.key == UUID(uuidString: uuid) }) {
                    let sellMakerModel = FatCrabMakerSellModel(maker: sellMaker)
                    let makerTrade = FatCrabMakerTrade.sell(maker: sellMakerModel)
                    newTrades.updateValue(FatCrabTrade.maker(maker: makerTrade), forKey: UUID(uuidString: uuid)!)
                }
            }
            
            
            trader.getBuyTakers().forEach { (uuid: String, buyTaker: FatCrabBuyTaker) in
                if !trades.contains(where: { $0.key == UUID(uuidString: uuid) }) {
                    let buyTakerModel = FatCrabTakerBuyModel(taker: buyTaker)
                    let takerTrade = FatCrabTakerTrade.buy(taker: buyTakerModel)
                    newTrades.updateValue(FatCrabTrade.taker(taker: takerTrade), forKey: UUID(uuidString: uuid)!)
                }
            }
            
            trader.getSellTakers().forEach { (uuid: String, sellTaker: FatCrabSellTaker) in
                if !trades.contains(where: { $0.key == UUID(uuidString: uuid) }) {
                    let sellTakerModel = FatCrabTakerSellModel(taker: sellTaker)
                    let takerTrade = FatCrabTakerTrade.sell(taker: sellTakerModel)
                    newTrades.updateValue(FatCrabTrade.taker(taker: takerTrade), forKey: UUID(uuidString: uuid)!)
                }
            }

            Task { @MainActor [newTrades] in
                trades.merge(newTrades) { (current, _) in current }
            }
        }
    }
    
    // Async/Await Task wrappers
    
    func walletGenerateReceiveAddress() async throws -> String {
        let address = try await Task {
            try trader.walletGenerateReceiveAddress()
        }.value
        return address
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
