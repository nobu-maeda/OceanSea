//
//  Common.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import Foundation

let allZeroUUIDString: String = "00000000-0000-0000-0000-000000000000"

enum OceanSeaError: Error {
    case invalidState(String)
}

enum FatCrabTradeType {
    case maker
    case taker
}
