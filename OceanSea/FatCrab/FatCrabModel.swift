//
//  FatCrabModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import Foundation

@Observable class FatCrabModel: FatCrabProtocol {
    private let trader: FatCrabTrader  // Should we inject this? Or is this good?
    
    var totalBalance: Int
    var spendableBalance: Int
    var allocatedAmount: Int
    var orders: [FatCrabOrder]
    
    init() {
        let url = "ssl://electrum.blockstream.info:60002"
        let network = Network.regtest
        let info = BlockchainInfo.electrum(url: url, network: network)
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        
        trader = FatCrabTrader(info: info, appDirPath: appDir[0])
        totalBalance = 0
        spendableBalance = 0
        allocatedAmount = 0
        orders = [FatCrabOrder]()
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
