//
//  BookView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct BookView<T: FatCrabProtocol>: View {
    @ObservedObject var fatCrabModel: T
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
    BookView(fatCrabModel: FatCrabMock())
}
