//
//  ReceiveView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct ReceiveView: View {
    @Environment(\.fatCrabModel) var model
    @State var receive_address: String = ""
    @State var isBusy = true
    
    var body: some View {
        VStack {
            Text(receive_address)
            .textSelection(.enabled)
        }
        .onAppear(perform: {
            Task {
                let address = try await model.walletGenerateReceiveAddress()
                
                Task { @MainActor in
                    receive_address = address
                    isBusy = false
                }
            }
        })
        .navigationTitle("Receive Address")
        .modifier(ActivityIndicatorModifier(isLoading: isBusy))
    }
}

#Preview {
    ReceiveView().environment(\.fatCrabModel, FatCrabMock())
}
