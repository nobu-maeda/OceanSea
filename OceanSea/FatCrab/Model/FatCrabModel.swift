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
    var makerTrades: [UUID: FatCrabMakerTrade]
    var takerTrades: [UUID: FatCrabTakerTrade]
    
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
        makerTrades = [:]
        takerTrades = [:]
        
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
        updateBalances()
        
        relays = trader.getRelays()

        Task { @MainActor in
            // Should make sure all Maker & Taker notif is hooked up before reconnecting
            try trader.reconnect()
        }
    }
    
    func updateBalances() {
        Task {
            try trader.walletBlockchainSync()
            let walletAllocatedAmount = Int(try trader.walletAllocatedAmount())
            let walletSpendableBalance = Int(try trader.walletSpendableBalance())
            
            Task { @MainActor in
                allocatedAmount = walletAllocatedAmount
                spendableBalance = walletSpendableBalance
                totalBalance = walletAllocatedAmount + walletSpendableBalance
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
        do {
            let envelopes = try trader.queryOrders(orderType: nil)
            queriedOrders = envelopes.reduce(into: [UUID: FatCrabOrderEnvelope]()) {
                $0[UUID(uuidString: $1.order().tradeUuid)!] = $1
            }
        } catch {
            print(error)
        }
    }
    
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) throws -> any FatCrabMakerBuyProtocol {
        let uuid = UUID()
        let order = FatCrabOrder(orderType: FatCrabOrderType.buy, tradeUuid: uuid.uuidString, amount: amount, price: price)
        let maker = try trader.newBuyMaker(order: order, fatcrabRxAddr: fatcrabRxAddr)
        let makerModel = FatCrabMakerBuyModel(maker: maker)
        makerTrades.updateValue(.buy(maker: makerModel), forKey: uuid)
        
        // TODO: How to hook-up Maker events?
        
        // TODO: Do we just go-ahead and post the order here?
        
        return makerModel
    }
    
    func makeSellOrder(price: Double, amount: Double) throws -> any FatCrabMakerSellProtocol {
        let uuid = UUID()
        let order = FatCrabOrder(orderType: FatCrabOrderType.sell, tradeUuid: uuid.uuidString, amount: amount, price: price)
        let maker = try trader.newSellMaker(order: order)
        let makerModel = FatCrabMakerSellModel(maker: maker)
        makerTrades.updateValue(.sell(maker: makerModel), forKey: uuid)
        
        // TODO: How to hook-up Maker events?
        
        // TODO: Do we just go-ahead and post the order here?
        try maker.postNewOrder()
        
        return makerModel
    }
    
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) throws -> any FatCrabTakerBuyProtocol {
        let uuid = UUID()
        let taker = try trader.newBuyTaker(orderEnvelope: orderEnvelope)
        let takerModel = FatCrabTakerBuyModel(taker: taker)
        takerTrades.updateValue(.buy(taker: takerModel), forKey: uuid)
        
        // TODO: How to hook-up Taker events?
        
        // TODO: Do we just go-ahead and take the order here?
        
        return takerModel
    }
    
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) throws -> any FatCrabTakerSellProtocol {
        let uuid = UUID()
        let taker = try trader.newSellTaker(orderEnvelope: orderEnvelope, fatcrabRxAddr: fatcrabRxAddr)
        let takerModel = FatCrabTakerSellModel(taker: taker)
        takerTrades.updateValue(.sell(taker: takerModel), forKey: uuid)
        
        // TODO: How to hook-up Taker events?
        
        // TODO: Do we just go-ahead and take the order here?
        
        return takerModel
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
