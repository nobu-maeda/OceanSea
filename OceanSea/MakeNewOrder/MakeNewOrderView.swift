//
//  MakeNewOrderView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/01.
//

import SwiftUI

struct MakeNewOrderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.fatCrabModel) var model
    
    @State var priceInputString = ""
    @State var amountInputString = ""
    @State var fatcrabRxAddrInputString = ""
    @State var orderType: FatCrabOrderType = .buy
    
    var body: some View {
        NavigationStack {
            List {
                Picker("OrderType", selection: $orderType) {
                    Text("Buy").tag(FatCrabOrderType.buy)
                    Text("Sell").tag(FatCrabOrderType.sell)
                }.pickerStyle(SegmentedPickerStyle())
                TextField("Price (Sats / Fatcrab)", text: $priceInputString)
                TextField("Amount (# of Fatcrabs)", text: $amountInputString)
                
                if orderType == .buy {
                    TextField("Fatcrab Receive Address", text: $fatcrabRxAddrInputString)
                }
            }
            .navigationTitle("Make New Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            }
        }
    }
    
    func createNewOrder() {
        guard let price = Double(priceInputString) else {
            // TODO: Alert user for invalid price
            return
        }
        
        guard let amount = Double(amountInputString) else {
            // TODO: Alert user for invalid amount
            return
        }
        
        // Is there a way to validate the input string against valid Fatcrab address?
        
        switch orderType {
        case .buy:
            _ = model.makeBuyOrder(price: price, amount: amount, fatcrabRxAddr: fatcrabRxAddrInputString)
            
        case .sell:
            _ = model.makeSellOrder(price: price, amount: amount)
        }
    }
}

#Preview {
    MakeNewOrderView().environment(\.fatCrabModel, FatCrabMock())
}
