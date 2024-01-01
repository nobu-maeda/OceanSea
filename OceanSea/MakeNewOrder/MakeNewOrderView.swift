//
//  MakeNewOrderView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/01.
//

import SwiftUI

struct MakeNewOrderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("MakeNewOrderView!")
            Button("Dismiss", action: dismiss.callAsFunction)
        }
    }
}

#Preview {
    MakeNewOrderView()
}
