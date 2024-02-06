//
//  RelaysView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct RelaysView: View {
    @Environment(\.fatCrabModel) var model
    
    @State var showAddRelayToolbarView = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.relays, id: \.self) { relay in
                    HStack {
                        Text(relay.url)
                        Spacer()
                        Button {
                            removeRelay(url: relay.url)
                        } label: {
                            Image(systemName: "multiply").foregroundColor(.black)
                        }
                    }
                }
            }
            .toolbar(content: {
                AddRelayToolbarItem(showAddRelayToolbarView: $showAddRelayToolbarView)
            })
            .navigationTitle("Nostr Relays")
        }
        .sheet(isPresented: $showAddRelayToolbarView) {
            AddRelayView()
        }
    }
    
    func removeRelay(url: String) {
        do {
            try model.removeRelay(url: url)
        } catch {
            print("Error removing relay: \(error)")
        }
    }
}

#Preview {
    RelaysView().environment(\.fatCrabModel, FatCrabMock())
}
