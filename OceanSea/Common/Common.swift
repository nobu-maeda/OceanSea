//
//  Common.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import Foundation
import OSLog

let allZeroUUIDString: String = "00000000-0000-0000-0000-000000000000"

enum OceanSeaError: Error {
    case invalidState(String)
}

enum FatCrabTradeType {
    case maker
    case taker
}

enum BuySellFilter: String {
    static var allFilters: [Self] { [.both, .buy, .sell] }
    
    case both = "Both"
    case buy = "Buy Only"
    case sell = "Sell Only"
}

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like a view that appeared.
    static let appInterface = Logger(subsystem: subsystem, category: "appInterface")
}
