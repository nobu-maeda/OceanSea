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
    @State var sortOption = SortOption.priceAscending
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Sort By", selection: $sortOption) {
                    Text("Amount △").tag(SortOption.amountAscending)
                    Text("Amount ▽").tag(SortOption.amountDescending)
                    Text("Price △").tag(SortOption.priceAscending)
                    Text("Price ▽").tag(SortOption.priceDescending)
                }.pickerStyle(SegmentedPickerStyle())
                
                List {
                    ForEach(processTradeUuids(), id: \.self) { tradeUuid in
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
                                if tradesFilter == filter {
                                    Text("\(filter.rawValue) ✓")
                                } else {
                                    Text(filter.rawValue)
                                }
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
                                if buySellFilter == filter {
                                    Text("\(filter.rawValue) ✓")
                                } else {
                                    Text(filter.rawValue)
                                }
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
    
    func processTradeUuids() -> [UUID] {
        var processTradeUuids: [UUID]
        
        switch tradesFilter {
        case .all:
            processTradeUuids = model.trades.keys.map({ $0 })
        case .ongoing:
            processTradeUuids = model.trades.keys.filter({ model.trades[$0]?.isCompleted == false })
        case .completed:
            processTradeUuids = model.trades.keys.filter({ model.trades[$0]?.isCompleted == true })
        }
        
        switch buySellFilter {
        case .both:
            break
        case .buy:
            processTradeUuids = processTradeUuids.filter({ model.trades[$0]?.orderType == .buy })
        case .sell:
            processTradeUuids = processTradeUuids.filter({ model.trades[$0]?.orderType == .sell })
        }
        
        switch sortOption {
        case .priceAscending:
            processTradeUuids.sort(by: { model.trades[$0]?.orderPrice ?? 0 < model.trades[$1]?.orderPrice ?? 0 })
        case .priceDescending:
            processTradeUuids.sort(by: { model.trades[$0]?.orderPrice ?? 0 > model.trades[$1]?.orderPrice ?? 0 })
        case .amountAscending:
            processTradeUuids.sort(by: { model.trades[$0]?.orderAmount ?? 0 < model.trades[$1]?.orderAmount ?? 0 })
        case .amountDescending:
            processTradeUuids.sort(by: { model.trades[$0]?.orderAmount ?? 0 > model.trades[$1]?.orderAmount ?? 0 })
        }
        
        return processTradeUuids
    }
}

#Preview {
    TradesView().environment(\.fatCrabModel, FatCrabMock())
}
