//
//  TakeOrderActionView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/27.
//

import SwiftUI

struct TakeOrderActionView: View {
    @Environment(\.fatCrabModel) var model
    
    @Binding var orderEnvelope: FatCrabOrderEnvelopeProtocol?
    @Binding var trade: FatCrabTrade?
    @Binding var isBusy: Bool
    
    @Binding var showAlert: Bool
    @Binding var alertTitleString: String
    @Binding var alertBodyString: String
    @Binding var alertType: TradeDetailViewAlertType
    
    @State private var fatcrabRxAddr = ""
    
    var body: some View {
        VStack {
            switch orderEnvelope!.order().orderType {
            case .buy:
                Button() {
                    takeBuyOrder()
                } label: {
                    Text("Take Buy Order to Sell FatCrab")
                }.buttonStyle(.borderedProminent)
                    .controlSize(.regular)
            case .sell:
                TextField(text: $fatcrabRxAddr) {
                    Text("FatCrab Receive Address")
                }
                .padding(.leading)
                .padding(.trailing)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                Button() {
                    takeSellOrder()
                } label: {
                    Text("Take Sell Order to Buy FatCrab")
                }.buttonStyle(.borderedProminent)
                    .controlSize(.regular)
            }
        }
    }
    
    func takeBuyOrder() {
        isBusy = true
        
        Task {
            do {
                let buyTaker = try await model.takeBuyOrder(orderEnvelope: orderEnvelope as! FatCrabOrderEnvelope)
                
                Task { @MainActor in
                    trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: buyTaker))
                }
            } catch let fatCrabError as FatCrabError {
                Task { @MainActor in
                    alertTitleString = "Error"
                    alertBodyString = fatCrabError.description()
                    alertType = .okAlert
                    showAlert = true
                }
            }
            catch {
                Task { @MainActor in
                    alertTitleString = "Error"
                    alertBodyString = error.localizedDescription
                    alertType = .okAlert
                    showAlert = true
                }
            }
            isBusy = false
        }
    }
    
    func takeSellOrder() {
        guard !fatcrabRxAddr.isEmpty else {
            alertTitleString = "Error"
            alertBodyString = "FatCrab Receive Address is empty"
            alertType = .okAlert
            showAlert = true
            return
        }
        
        isBusy = true
        
        Task {
            do {
                let sellTaker = try await model.takeSellOrder(orderEnvelope: orderEnvelope as! FatCrabOrderEnvelope, fatcrabRxAddr: fatcrabRxAddr)
                
                Task { @MainActor in
                    trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: sellTaker))
                }
            } catch let fatCrabError as FatCrabError {
                Task { @MainActor in
                    alertTitleString = "Error"
                    alertBodyString = fatCrabError.description()
                    alertType = .okAlert
                    showAlert = true
                }
            }
            catch {
                Task { @MainActor in
                    alertTitleString = "Error"
                    alertBodyString = error.localizedDescription
                    alertType = .okAlert
                    showAlert = true
                }
            }
            isBusy = false
        }
    }
}

#Preview("Buy") {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    @State var trade: FatCrabTrade? = nil
    return TakeOrderActionView(orderEnvelope: $orderEnvelope, trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Sell") {
    let order = FatCrabOrder(orderType: .sell, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    @State var trade: FatCrabTrade? = nil
    return TakeOrderActionView(orderEnvelope: $orderEnvelope, trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}
