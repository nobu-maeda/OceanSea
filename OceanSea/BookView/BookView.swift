//
//  BookView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct BookView: View {
    @Binding var selection: HomeView.Tab
    @Environment(\.fatCrabModel) var model
    
    @State private var showMakeNewOrderView = false
    @State private var showOrderDetailView = false
    @State private var showOrderDetailViewForTrade: FatCrabTrade? = nil
    @State private var showOrderDetailViewForOrder: FatCrabOrderEnvelopeProtocol? = nil
    
    @State private var bookFilter = BookFilter.new
    @State private var buySellFilter = BuySellFilter.both
    @State private var sortOption = SortOption.priceAscending
    
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
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
                    ForEach(processOrderUuids(), id: \.self) { orderUuid in
                        if let orderEnvelope = model.queriedOrders[orderUuid] {
                            TradeRowView(orderUuid: orderUuid)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    showOrderDetailViewForOrder = orderEnvelope
                                    showOrderDetailViewForTrade = model.trades[orderUuid]
                                    showOrderDetailView = true
                                }
                        }
                    }
                }
            }
            .refreshable {
                await updateBookView()
            }
            .onAppear() {
                Task {
                    await updateBookView()
                }
            }
            .toolbar {
                switch selection {
                case .book:
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button(action: {
                            showMakeNewOrderView.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundColor(.blue)
                        })
                        Menu(content: {
                            ForEach (BookFilter.allFilters, id: \.self) { filter in
                                Button {
                                    bookFilter = filter
                                } label: {
                                    if bookFilter == filter {
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
                default:
                    ToolbarItem(placement: .primaryAction) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Order Book")
            .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
        }
        .sheet(isPresented: $showMakeNewOrderView) {
            Task {
                await updateBookView()
            }
        } content: {
            MakeNewOrderView()
        }
        .sheet(isPresented: $showOrderDetailView) {
            Task {
                await updateBookView()
            }
        } content: {
            TradeDetailView(orderEnvelope: $showOrderDetailViewForOrder, trade: $showOrderDetailViewForTrade)
        }
    }
    
    func processOrderUuids() -> [UUID] {
        var processOrderUuids: [UUID]
        
        switch bookFilter {
        case .all:
            processOrderUuids = model.queriedOrders.keys.map({ $0 })
        case .new:
            processOrderUuids = model.queriedOrders.filter({ model.trades.index(forKey: $0.key) == nil }).keys.map({ $0 })
        case .ongoing:
            processOrderUuids = model.queriedOrders.filter({ model.trades.index(forKey: $0.key) != nil }).keys.map({ $0 })
        }
        
        switch buySellFilter {
        case .both:
            break
        case .buy:
            processOrderUuids = processOrderUuids.filter({ model.queriedOrders[$0]?.order().orderType == .buy })
        case .sell:
            processOrderUuids = processOrderUuids.filter({ model.queriedOrders[$0]?.order().orderType == .sell })
        }
        
        switch sortOption {
        case .priceAscending:
            processOrderUuids.sort(by: { model.queriedOrders[$0]?.order().price ?? 0 < model.queriedOrders[$1]?.order().price ?? 0 })
        case .priceDescending:
            processOrderUuids.sort(by: { model.queriedOrders[$0]?.order().price ?? 0 > model.queriedOrders[$1]?.order().price ?? 0 })
        case .amountAscending:
            processOrderUuids.sort(by: { model.queriedOrders[$0]?.order().amount ?? 0 < model.queriedOrders[$1]?.order().amount ?? 0 })
        case .amountDescending:
            processOrderUuids.sort(by: { model.queriedOrders[$0]?.order().amount ?? 0 > model.queriedOrders[$1]?.order().amount ?? 0 })
        }
        
        return processOrderUuids
    }
    
    func updateBookView() async {
        do {
            try await model.updateOrderBook()
        } catch let fatCrabError as FatCrabError {
            Task { @MainActor in
                alertTitleString = "Error"
                alertBodyString = fatCrabError.description()
                showAlert = true
            }
        }
        catch {
            Task { @MainActor in
                alertTitleString = "Error"
                alertBodyString = error.localizedDescription
                showAlert = true
            }
        }
    }
}

#Preview {
    @State var selectedTab = HomeView.Tab.book
    return BookView(selection: $selectedTab).environment(\.fatCrabModel, FatCrabMock())
}
