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
    
    var body: some View {
        NavigationStack {
            List {
                let orderUuids: [UUID] = model.queriedOrders.keys.map({ $0 })
                ForEach(orderUuids, id: \.self) { orderUuid in
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
            .toolbar(content: {
                MakeNewOrderToolbarItem(showMakeNewOrderView: $showMakeNewOrderView)
            })
            .navigationTitle("Order Book")
            .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
        }
        .sheet(isPresented: $showMakeNewOrderView) {
            MakeNewOrderView()
        }
        .sheet(isPresented: $showOrderDetailView) {
            TradeDetailView(orderEnvelope: $showOrderDetailViewForOrder, trade: $showOrderDetailViewForTrade)
        }
    }
    
    func updateBookView() async {
        do {
            await model.updateTrades()
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
