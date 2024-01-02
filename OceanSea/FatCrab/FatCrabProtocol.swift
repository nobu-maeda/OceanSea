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
    
    func updateBalances()
    func walletGenerateReceiveAddress() async throws -> String
    
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) -> any FatCrabMakerBuyProtocol
    func makeSellOrder(price: Double, amount: Double) -> any FatCrabMakerSellProtocol
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) -> any FatCrabTakerBuyProtocol
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) -> any FatCrabTakerSellProtocol
}

protocol FatCrabMakerBuyProtocol: ObservableObject {
    
}

protocol FatCrabMakerSellProtocol: ObservableObject {
    
}

protocol FatCrabTakerBuyProtocol: ObservableObject {
    
}

protocol FatCrabTakerSellProtocol: ObservableObject {
    
}
