//
//  BookView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct BookView: View {
    @Environment(\.fatCrabModel) var model
    
    var body: some View {
        NavigationStack {
            Text("Hello, World!")
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            Text("Make new Order")
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                })
                .navigationTitle("Order Book")
        }
    }
}

#Preview {
    BookView().environment(\.fatCrabModel, FatCrabMock())
}
