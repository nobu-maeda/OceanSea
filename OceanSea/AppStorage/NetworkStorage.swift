//
//  NetworkStorage.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/05/10.
//

import SwiftUI

public struct NetworkStorage {
    @AppStorage("network") var bitcoinNetwork: String?
    
    public static func read() -> Network? {
        if let networkString = NetworkStorage().bitcoinNetwork {
            return Network.fromString(networkString)
        } else {
            return nil
        }
    }
    
    public static func write(network: Network) {
        let networkString = network.toString()
        NetworkStorage().bitcoinNetwork = networkString
    }
    
}

extension Network {
    static let MAINNET_STRING = "Mainnet"
    static let TESTNET_STRING = "Testnet"
    static let SIGNET_STRING = "Signet"
    static let REGTEST_STRING = "Regtest"
    
    static func fromString(_ string: String) -> Self {
        switch string {
        case MAINNET_STRING:
            return Network.bitcoin
        case TESTNET_STRING:
            return Network.testnet
        case SIGNET_STRING:
            return Network.signet
        case REGTEST_STRING:
            return Network.signet
        default:
            fatalError()
        }
    }
    
    func toString() -> String {
        switch self {
        case .bitcoin:
            return Self.MAINNET_STRING
        case .testnet:
            return Self.TESTNET_STRING
        case .signet:
            return Self.SIGNET_STRING
        case .regtest:
            return Self.REGTEST_STRING
        }
    }
}
