//
//  TradesView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct TradesView: View {
    @Environment(\.fatCrabModel) var model
    
    @State var showMakeNewOrderView = false
    
    var body: some View {
        NavigationStack {
            List {
                let tradeUuids: [UUID] = model.trades.keys.map({ $0 })
                ForEach(tradeUuids, id: \.self) { tradeUuid in
                    if let trade = model.trades[tradeUuid] {
                        NavigationLink(destination: TradeDetailView(trade: trade)) {
                            TradeRowView(trade: trade)
                        }
                    }
                }
            }
            .refreshable {
                model.updateTrades()
            }
            .onAppear() {
                model.updateTrades()
            }
            .toolbar(content: {
                MakeNewOrderToolbarItem(showMakeNewOrderView: $showMakeNewOrderView)
            })
            .navigationTitle("Trade Status")
        }
        .sheet(isPresented: $showMakeNewOrderView) {
            MakeNewOrderView()
        }
    }
}

#Preview {
    TradesView().environment(\.fatCrabModel, FatCrabMock())
}
