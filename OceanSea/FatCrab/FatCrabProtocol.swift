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
    
    var relays: [RelayInfo] { get }
    func addRelays(relayAddrs: [RelayAddr]) throws
    func removeRelay(url: String) throws
    
    func makeBuyOrder(price: Double, amount: Double, fatcrabRxAddr: String) throws -> any FatCrabMakerBuyProtocol
    func makeSellOrder(price: Double, amount: Double) throws -> any FatCrabMakerSellProtocol
    func takeBuyOrder(orderEnvelope: FatCrabOrderEnvelope) throws -> any FatCrabTakerBuyProtocol
    func takeSellOrder(orderEnvelope: FatCrabOrderEnvelope, fatcrabRxAddr: String) throws -> any FatCrabTakerSellProtocol
}

protocol FatCrabMakerBuyProtocol: ObservableObject {
    
}

protocol FatCrabMakerSellProtocol: ObservableObject {
    
}

protocol FatCrabTakerBuyProtocol: ObservableObject {
    
}

protocol FatCrabTakerSellProtocol: ObservableObject {
    
}
