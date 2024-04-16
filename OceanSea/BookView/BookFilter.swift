//
//  BookFilter.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/04/16.
//

import Foundation

enum BookFilter: String {
    static var allFilters: [Self] { [.all, .new, .ongoing] }
    
    case all = "All Orders"
    case new = "New Orders"
    case ongoing = "Ongoing Trades"
}
