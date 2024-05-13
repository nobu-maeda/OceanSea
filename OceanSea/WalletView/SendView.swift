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
            List {
                Text("Bitcoin address to send to:").bold()
                TextField("tb1.....", text: $bitcoinAddressString)
                    .textFieldStyle(.roundedBorder)
                Text("Bitcoin amount in sats:").bold()
                TextField("546 sats dust limit minimum", text: $satsAmountString)
                    .textFieldStyle(.roundedBorder)
            }
            Button {
                sendFunds()
            } label: {
                Text("Send")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(bitcoinAddressString.isEmpty || satsAmountString.isEmpty)
        }
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
                
                if satsAmount <= 546 {
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
    SendView().environment(\.fatCrabModel, FatCrabMock(for: .signet))
}
