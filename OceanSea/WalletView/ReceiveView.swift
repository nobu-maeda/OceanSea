//
//  ReceiveView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct ReceiveView: View {
    @Environment(\.fatCrabModel) var model
    
    @State private var receiveAddress: String = ""
    @State private var isBusy = true
    
    var body: some View {
        List {
            Text("Bitcoin address to receive with:").bold()
            Text(receiveAddress).textSelection(.enabled)
            Text("Network:").bold()
            Text(model.network.toString())
        }
        .onAppear(perform: {
            Task {
                let address = try await model.walletGenerateReceiveAddress()
                
                Task { @MainActor in
                    receiveAddress = address
                    isBusy = false
                }
            }
        })
        .navigationTitle("Receive Funds")
        .modifier(ActivityIndicatorModifier(isLoading: isBusy))
    }
}

#Preview {
    ReceiveView().environment(\.fatCrabModel, FatCrabMock(for: .signet))
}
