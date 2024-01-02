//
//  FatCrabModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import Foundation

@Observable class FatCrabModel: FatCrabProtocol {
    let MNEMONIC_KEYCHAIN_WRAPPER_KEY: String = "mnemonic"
    
    private let trader: FatCrabTrader  // Should we inject this? Or is this good?
    
    var mnemonic: [String]
    var totalBalance: Int
    var spendableBalance: Int
    var allocatedAmount: Int
    var orders: [FatCrabOrder]
    
    init() {
        let url = "ssl://electrum.blockstream.info:60002"
        let network = Network.testnet
        let info = BlockchainInfo.electrum(url: url, network: network)
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        
        mnemonic = []
        totalBalance = 0
        spendableBalance = 0
        allocatedAmount = 0
        orders = []
        
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
            orders = envelopes.map { $0.order() }
        } catch {
            print(error)
        }
    }
    
    // Async/Await Task wrappers
    
    func walletGenerateReceiveAddress() async throws -> String {
        let address = try await Task {
            try trader.walletGenerateReceiveAddress()
        }.value
        return address
    }
    
    func walletSpendableBalance() async throws -> Int {
        let balance = try await Task {
            try trader.walletSpendableBalance()
        }.value
        return Int(balance)
    }
    
    func walletAllocatedAmount() async throws -> Int {
        let amount = try await Task {
            try trader.walletAllocatedAmount()
        }.value
        return Int(amount)
    }
}
