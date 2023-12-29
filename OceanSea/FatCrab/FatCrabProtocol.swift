//
//  FatCrabProtocol.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct FatCrabModelKey: EnvironmentKey {
    static let defaultValue: any FatCrabProtocol = FatCrabMock()
}

extension EnvironmentValues {
    var fatCrabModel: any FatCrabProtocol {
        get { self[FatCrabModelKey.self] }
        set { self[FatCrabModelKey.self] = newValue }
    }
}

protocol FatCrabProtocol: ObservableObject {
    var totalBalance: Int { get }
    var spendableBalance: Int { get }
    var allocatedAmount: Int { get }
    var mnemonic: [String] { get }
    
    func walletGenerateReceiveAddress() async throws -> String
}
