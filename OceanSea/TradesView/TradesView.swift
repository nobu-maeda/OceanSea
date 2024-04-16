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
    @State var tradesFilter = TradesFilter.ongoing
    @State var buySellFilter = BuySellFilter.both
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTradeUuids(), id: \.self) { tradeUuid in
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
            .toolbar() {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showMakeNewOrderView.toggle()
                    }, label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.blue)
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu(content: {
                        ForEach(TradesFilter.allFilters, id: \.self) { filter in
                            Button {
                                tradesFilter = filter
                            } label: {
                                Text(filter.rawValue)
                            }
                        }
                    }, label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.headline)
                            .foregroundColor(.blue)
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu(content: {
                        ForEach (BuySellFilter.allFilters, id: \.self) { filter in
                            Button {
                                buySellFilter = filter
                            } label: {
                                Text(filter.rawValue)
                            }
                        }
                    }, label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.headline)
                            .foregroundColor(.blue)
                    })
                }
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
    
    func filteredTradeUuids() -> [UUID] {
        var filteredTradeUuids: [UUID]
        
        switch tradesFilter {
        case .all:
            filteredTradeUuids = model.trades.keys.map({ $0 })
        case .ongoing:
            filteredTradeUuids = model.trades.keys.filter({ model.trades[$0]?.isCompleted == false })
        case .completed:
            filteredTradeUuids = model.trades.keys.filter({ model.trades[$0]?.isCompleted == true })
        }
        
        switch buySellFilter {
        case .both:
            break
        case .buy:
            filteredTradeUuids = filteredTradeUuids.filter({ model.trades[$0]?.orderType == .buy })
        case .sell:
            filteredTradeUuids = filteredTradeUuids.filter({ model.trades[$0]?.orderType == .sell })
        }
        
        return filteredTradeUuids
    }
}

#Preview {
    TradesView().environment(\.fatCrabModel, FatCrabMock())
}
