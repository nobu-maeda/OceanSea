//
//  TradesView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct TradesView: View {
    @Environment(\.fatCrabModel) var model
    
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = nil
    @State var showMakeNewOrderView = false
    @State var showTradeDetailView = false
    @State var showTradeDetailViewForTrade: FatCrabTrade? = nil
    
    var body: some View {
        NavigationStack {
            List {
                let tradeUuids: [UUID] = model.trades.keys.map({ $0 })
                ForEach(tradeUuids, id: \.self) { tradeUuid in
                    if let trade = model.trades[tradeUuid] {
                        TradeRowView(orderUuid: tradeUuid)
                        .contentShape(Rectangle())
                        .onTapGesture {
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
            .toolbar() {
                MakeNewOrderToolbarItem(showMakeNewOrderView: $showMakeNewOrderView)
            }
            .navigationTitle("Trade Status")
        }
        .sheet(isPresented: $showMakeNewOrderView) {
            MakeNewOrderView()
        }
        .sheet(isPresented: $showTradeDetailView) {
            TradeDetailView(orderEnvelope: $orderEnvelope, trade: $showTradeDetailViewForTrade)
        }
    }
}

#Preview {
    TradesView().environment(\.fatCrabModel, FatCrabMock())
}
