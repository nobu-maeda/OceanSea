//
//  FatCrabModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import Foundation

class FatCrabModel: FatCrabProtocol {
    let MNEMONIC_KEYCHAIN_WRAPPER_KEY: String = "mnemonic"
    
    private let trader: FatCrabTrader  // Should we inject this? Or is this good?
    
    @Published var mnemonic: [String]
    @Published var totalBalance: Int
    @Published var spendableBalance: Int
    @Published var allocatedAmount: Int
    @Published var orders: [FatCrabOrder]
    
    init() {
        let url = "ssl://electrum.blockstream.info:60002"
        let network = Network.regtest
        let info = BlockchainInfo.electrum(url: url, network: network)
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        
        mnemonic = []
        totalBalance = 0
        spendableBalance = 0
        allocatedAmount = 0
        orders = []
        
        if let mnemonic = KeychainWrapper.standard.string(forKey: MNEMONIC_KEYCHAIN_WRAPPER_KEY, withAccessibility: .whenUnlocked) {
            trader = FatCrabTrader.newWithMnemonic(mnemonic: mnemonic, info: info, appDirPath: appDir[0])
            self.mnemonic = mnemonic.components(separatedBy: " ")
        } else {
            trader = FatCrabTrader(info: info, appDirPath: appDir[0])
            
            Task {
                // Update initial values asynchronously
                let mnemonic = try trader.walletBip39Mnemonic()
                KeychainWrapper.standard.set(mnemonic, forKey: MNEMONIC_KEYCHAIN_WRAPPER_KEY, withAccessibility: .whenUnlocked)
                self.mnemonic = mnemonic.components(separatedBy: " ")
            }
        }
    }
    
    func updateBalances() async throws {
        async let allocatedAmount = self.walletAllocatedAmount()
        async let spendableBalance = self.walletSpendableBalance()
        await (self.spendableBalance, self.allocatedAmount) = try (spendableBalance, allocatedAmount)
        self.totalBalance = self.spendableBalance + self.allocatedAmount
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
