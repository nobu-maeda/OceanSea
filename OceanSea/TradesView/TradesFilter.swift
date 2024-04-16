//
//  TradesFilter.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/04/16.
//

import Foundation

enum TradesFilter: String {
    static var allFilters: [Self] { [.all, .ongoing, .completed] }
    
    case all = "All Trades"
    case ongoing = "Ongoing Trades"
    case completed = "Completed Trades"
}
