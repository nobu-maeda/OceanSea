//
//  SendView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct SendView<T: FatCrabProtocol>: View {
    @ObservedObject var fatCrabModel: T
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SendView(fatCrabModel: FatCrabMock())
}
