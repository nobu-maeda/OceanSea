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
    
    var body: some View {
        Text(receive_address)
            .textSelection(.enabled)
            .onAppear(perform: {
                Task {
                    receive_address = try await model.walletGenerateReceiveAddress()
                }
            })
            .navigationTitle("Receive Address")
    }
    
}

#Preview {
    ReceiveView().environment(\.fatCrabModel, FatCrabMock())
}
