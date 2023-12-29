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
    
    init() {
        totalBalance = 0
        spendableBalance = 0
        allocatedAmount = 0
    }
}
