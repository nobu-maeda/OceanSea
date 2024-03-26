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
    @State var showTradeDetailView = false
    @State var showTradeDetailViewForTrade: FatCrabTrade? = nil
    
    var body: some View {
        NavigationStack {
            List {
                let tradeUuids: [UUID] = model.trades.keys.map({ $0 })
                ForEach(tradeUuids, id: \.self) { tradeUuid in
                    if let trade = model.trades[tradeUuid] {
                        NavigationLink(destination: Text("")) {
                            TradeRowView(trade: trade)
                        }.onTapGesture {
                            showTradeDetailViewForTrade = trade
                            showTradeDetailView = true
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
        .sheet(isPresented: $showTradeDetailView) {
            TradeDetailView(trade: $showTradeDetailViewForTrade)
        }
    }
}

#Preview {
    TradesView().environment(\.fatCrabModel, FatCrabMock())
}
