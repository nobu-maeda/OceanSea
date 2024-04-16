//
//  BookView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct BookView: View {
    @Environment(\.fatCrabModel) var model
    
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    @State var showMakeNewOrderView = false
    @State var showOrderDetailView = false
    @State var showOrderDetailViewForTrade: FatCrabTrade? = nil
    @State var showOrderDetailViewForOrder: FatCrabOrderEnvelopeProtocol? = nil
    @State var bookFilter = BookFilter.new
    @State var buySellFilter = BuySellFilter.both
    
    var body: some View {
        NavigationStack {
            List() {
                ForEach(filteredOrderUuids(), id: \.self) { orderUuid in
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
            .refreshable {
                await updateBookView()
            }
            .onAppear() {
                Task {
                    await updateBookView()
                }
            }
            .toolbar {
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
                        ForEach (BookFilter.allFilters, id: \.self) { filter in
                            Button {
                                bookFilter = filter
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
    
    func filteredOrderUuids() -> [UUID] {
        var filteredOrderUuids: [UUID]
        
        switch bookFilter {
        case .all:
            filteredOrderUuids = model.queriedOrders.keys.map({ $0 })
        case .new:
            filteredOrderUuids = model.queriedOrders.filter({ model.trades.index(forKey: $0.key) == nil }).keys.map({ $0 })
        case .ongoing:
            filteredOrderUuids = model.queriedOrders.filter({ model.trades.index(forKey: $0.key) != nil }).keys.map({ $0 })
        }
        
        switch buySellFilter {
        case .both:
            break
        case .buy:
            filteredOrderUuids = filteredOrderUuids.filter({ model.queriedOrders[$0]?.order().orderType == .buy })
        case .sell:
            filteredOrderUuids = filteredOrderUuids.filter({ model.queriedOrders[$0]?.order().orderType == .sell })
        }
        
        return filteredOrderUuids
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
    BookView().environment(\.fatCrabModel, FatCrabMock())
}
