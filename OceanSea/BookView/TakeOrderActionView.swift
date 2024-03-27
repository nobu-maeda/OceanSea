//
//  TakeOrderActionView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/27.
//

import SwiftUI

struct TakeOrderActionView: View {
    @Environment(\.fatCrabModel) var model
    @State private var fatcrabRxAddr = ""
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    let orderEnvelope: FatCrabOrderEnvelopeProtocol
    
    init(for orderEnvelope: FatCrabOrderEnvelopeProtocol) {
        self.orderEnvelope = orderEnvelope
    }
    
    var body: some View {
        VStack {
            switch orderEnvelope.order().orderType {
            case .buy:
                Button() {
                    takeBuyOrder()
                } label: {
                    Text("Take Buy Order to Sell Fatcrab")
                }.buttonStyle(.borderedProminent)
                    .controlSize(.regular)
            case .sell:
                TextField(text: $fatcrabRxAddr) {
                    Text("Fatcrab Receive Address")
                }
                .padding(.leading)
                .padding(.trailing)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                Button() {
                    takeSellOrder()
                } label: {
                    Text("Take Sell Order to Buy Fatcrab")
                }.buttonStyle(.borderedProminent)
                    .controlSize(.regular)
            }
        }
        .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
    }
    
    func takeBuyOrder() {
        do {
            _ = try model.takeBuyOrder(orderEnvelope: orderEnvelope as! FatCrabOrderEnvelope)
        } catch let fatCrabError as FatCrabError {
            alertTitleString = "Error"
            alertBodyString = fatCrabError.description()
            showAlert = true
        }
        catch {
            alertTitleString = "Error"
            alertBodyString = error.localizedDescription
            showAlert = true
        }
    }
    
    func takeSellOrder() {
        do {
            _ = try model.takeSellOrder(orderEnvelope: orderEnvelope as! FatCrabOrderEnvelope, fatcrabRxAddr: fatcrabRxAddr)
        } catch let fatCrabError as FatCrabError {
            alertTitleString = "Error"
            alertBodyString = fatCrabError.description()
            showAlert = true
        }
        catch {
            alertTitleString = "Error"
            alertBodyString = error.localizedDescription
            showAlert = true
        }
    }
}

#Preview("Buy") {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    let orderEnvelope = FatCrabOrderEnvelopeMock(order: order)
    return TakeOrderActionView(for: orderEnvelope)
}

#Preview("Sell") {
    let order = FatCrabOrder(orderType: .sell, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    let orderEnvelope = FatCrabOrderEnvelopeMock(order: order)
    return TakeOrderActionView(for: orderEnvelope)
}
