//
//  FatCrabModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import Foundation

@Observable class FatCrabModel: FatCrabProtocol {
    enum FatCrabTrade {
        case buyMaker(maker: FatCrabBuyMaker)
        case sellMaker(maker: FatCrabSellMaker)
        case buyTaker(taker: FatCrabBuyTaker)
        case sellTaker(taker: FatCrabSellTaker)
    }
    
    private let trader: FatCrabTrader  // Should we inject this? Or is this good?
    
    let MNEMONIC_KEYCHAIN_WRAPPER_KEY: String = "mnemonic"
    
    var mnemonic: [String]
    var totalBalance: Int
    var spendableBalance: Int
    var allocatedAmount: Int
    
    var queriedOrders: [FatCrabOrder]
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
        
        queriedOrders = []
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
        updateBalances()
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
    
    func updateOrders() {
        do {
            let envelopes = try trader.queryOrders(orderType: nil)
            queriedOrders = envelopes.map { $0.order() }
        } catch {
            print(error)
        }
    }
    
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) -> any FatCrabMakerBuyProtocol {
        let uuid = UUID()
        let order = FatCrabOrder(orderType: FatCrabOrderType.buy, tradeUuid: uuid.uuidString, amount: amount, price: price)
        let maker = trader.newBuyMaker(order: order, fatcrabRxAddr: fatcrabRxAddr)
        trades.updateValue(.buyMaker(maker: maker), forKey: uuid)
        
        // TODO: How to hook-up Maker events?
        
        // TODO: Do we just go-ahead and post the order here?
        
        let makerModel = FatCrabMakerBuyModel(maker: maker)
        return makerModel
    }
    
    func makeSellOrder(price: Double, amount: Double) -> any FatCrabMakerSellProtocol {
        let uuid = UUID()
        let order = FatCrabOrder(orderType: FatCrabOrderType.sell, tradeUuid: uuid.uuidString, amount: amount, price: price)
        let maker = trader.newSellMaker(order: order)
        trades.updateValue(.sellMaker(maker: maker), forKey: uuid)
        
        // TODO: How to hook-up Maker events?
        
        // TODO: Do we just go-ahead and post the order here?
        
        let makerModel = FatCrabMakerSellModel(maker: maker)
        return makerModel
    }
    
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) -> any FatCrabTakerBuyProtocol {
        let uuid = UUID()
        let taker = trader.newBuyTaker(orderEnvelope: orderEnvelope)
        trades.updateValue(.buyTaker(taker: taker), forKey: uuid)
        
        // TODO: How to hook-up Taker events?
        
        // TODO: Do we just go-ahead and take the order here?
        
        let takerModel = FatCrabTakerBuyModel(taker: taker)
        return takerModel
    }
    
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) -> any FatCrabTakerSellProtocol {
        let uuid = UUID()
        let taker = trader.newSellTaker(orderEnvelope: orderEnvelope, fatcrabRxAddr: fatcrabRxAddr)
        trades.updateValue(.sellTaker(taker: taker), forKey: uuid)
        
        // TODO: How to hook-up Taker events?
        
        // TODO: Do we just go-ahead and take the order here?
        
        let takerModel = FatCrabTakerSellModel(taker: taker)
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
