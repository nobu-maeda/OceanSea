//
//  SendView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct SendView: View {
    @Environment(\.fatCrabModel) var model
    
    @State private var bitcoinAddressString: String = ""
    @State private var satsAmountString: String = ""
    @State private var isBusy = false
    
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    var body: some View {
        VStack {
            TextField("Bitcoin Address to send to", text: $bitcoinAddressString)
                .textFieldStyle(.roundedBorder)
            Spacer()
            TextField("Number of sats to send", text: $satsAmountString)
                .textFieldStyle(.roundedBorder)
            Spacer()
            Spacer()
            Button {
                sendFunds()
            } label: {
                Text("Send")
            }
        }
        .padding()
        .frame(maxWidth: 500, maxHeight: 128)
        .navigationTitle("Send Funds")
        .modifier(ActivityIndicatorModifier(isLoading: isBusy))
        .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
    }
                                          
    func sendFunds() {
        isBusy = true
        
        Task {
            do {
                guard let satsAmount = UInt(satsAmountString) else {
                    throw OceanSeaError.invalidAmount
                }
                
                if satsAmount == 0 {
                    throw OceanSeaError.invalidAmount
                }
                
                if bitcoinAddressString.isEmpty {
                    throw OceanSeaError.invalidAddress
                }
                
                let txid = try await model.walletSendToAddress(address: bitcoinAddressString, amount: satsAmount)
                
                alertTitleString = "Bitcoin Sent"
                alertBodyString = "Transaction ID: \(txid)"
                showAlert = true
                
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
            
            isBusy = false
        }
    }
}

#Preview {
    SendView().environment(\.fatCrabModel, FatCrabMock())
}
