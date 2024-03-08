//
//  TitleValueHStack.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct TitleValueHStack: View {
    enum Formatting {
        case ends
        case around
    }
    
    let format: Formatting
    let title: String
    let value: String
    
    init(title: String, value: String, format: Formatting = .ends) {
        self.format = format
        self.title = title
        self.value = value
    }
    
    var body: some View {
        HStack {
            switch format {
            case .ends:
                Text(title)
                Spacer()
                Text(value)
            case .around:
                Spacer()
                Text(title)
                Spacer()
                Spacer()
                Text(value)
                Spacer()
            }
        }
    }
}

#Preview {
    TitleValueHStack(title: "Some Ttile", value: "some-value", format: .around)
}
