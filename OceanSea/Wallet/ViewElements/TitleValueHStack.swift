//
//  TitleValueHStack.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct TitleValueHStack: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    TitleValueHStack(title: "Some Ttile", value: "some-value")
}
