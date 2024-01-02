//
//  FatCrabMock.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import Foundation

@Observable class FatCrabMock: FatCrabProtocol {
    var totalBalance: Int
    var spendableBalance: Int
    var allocatedAmount: Int
    var mnemonic: [String]
    
    init() {
        totalBalance = 0
        spendableBalance = 0
        allocatedAmount = 0
        mnemonic = ["Word1", "Word2", "Word3", "Word4", "Word5", "Word6", "Word7", "Word8", "Word9", "Word10", "Word11", "Word12", "Word13", "Word14", "Word15", "Word16", "Word17", "Word18", "Word19", "Word20", "Word21", "Word22", "Word23", "Word24"]
        updateBalances()
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
}
