//
//  FatCrabModel.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import Foundation

@Observable class FatCrabModel {
    private let trader: FatCrabTrader  // Should we inject this? Or is this good?
    var orders = [FatCrabOrder]()
    
    init() {
        let url = "ssl://electrum.blockstream.info:60002"
        let network = Network.regtest
        let info = BlockchainInfo.electrum(url: url, network: network)
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)

        trader = FatCrabTrader(info: info, appDirPath: appDir[0])
    }
    
    func updateOrders() {
        do {
            let envelopes = try trader.queryOrders(orderType: nil)
            orders = envelopes.map { $0.order() }
        } catch {
            print(error)
        }
    }
}
