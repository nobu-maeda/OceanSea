//
//  EnterSeedsView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct EnterSeedsView: View {
    @Environment(\.fatCrabModel) var model
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    EnterSeedsView().environment(\.fatCrabModel, FatCrabMock())
}
