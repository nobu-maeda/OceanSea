//
//  ReceiveView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct ReceiveView<T: FatCrabProtocol>: View {
    @ObservedObject var fatCrabModel: T
    
    @State var receive_address: String = ""
    
    var body: some View {
        Text(receive_address)
            .textSelection(.enabled)
            .onAppear(perform: {
                Task {
                    self.receive_address = try await fatCrabModel.walletGenerateReceiveAddress()
                }
            })
            .navigationTitle("Receive Address")
    }
    
}

#Preview {
    ReceiveView(fatCrabModel: FatCrabMock())
}
