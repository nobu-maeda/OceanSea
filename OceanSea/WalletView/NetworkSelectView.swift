//
//  NetworkSelectView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/29.
//

import SwiftUI

struct NetworkSelectView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var model: any FatCrabProtocol
    
    @State private var existingNetwork: Network = .signet
    @State private var selectedNetwork: Network = .signet
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    @State private var isBusy = false
    
    init(model: Binding<any FatCrabProtocol>) {
        self._model = model
    }
    
    var body: some View {
        VStack {
            List {
                Picker("Bitcoin Network", selection: $selectedNetwork) {
                    Text("Signet").tag(Network.signet)
                    Text("Testnet").tag(Network.testnet)
                }
                
            }
            Button("Confirm") {
                confirmNetworkSelect(to: selectedNetwork)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(selectedNetwork == existingNetwork)
            .onAppear
            {
                let network = model.network
                selectedNetwork = network
                existingNetwork = network
            }
        }
        .navigationTitle("Network Select")
        .modifier(ActivityIndicatorModifier(isLoading: isBusy))
        .alert(alertTitleString, isPresented: $showAlert) {
            Button("Confirm", role: .destructive) {
                resetWallet(to: selectedNetwork)
            }
            Button("Cancel", role: .cancel) {}
        } message: { Text(alertBodyString) }
    }        
    
    func networkString(for network: Network) -> String {
        switch network {
        case .bitcoin:
            "Mainnet"
        case .regtest:
            "Regtest"
        case .signet:
            "Signet"
        case .testnet:
            "Testnet"
        }
    }
    
    func confirmNetworkSelect(to network: Network) {
        alertTitleString = "Change Network"
        alertBodyString = "Are you sure you want to switch to \(networkString(for: network))!"
        showAlert = true
    }
    
    func resetWallet(to network: Network) {
        isBusy = true
        
        Task {
            let mnemonic = model.mnemonic
            let newWalletModel = type(of: model).resetWallet(with: mnemonic, for: network)
            
            NetworkStorage.write(network: network)
            
            Task { @MainActor in
                model = newWalletModel
                isBusy = false
                dismiss.callAsFunction()
            }
        }
    }
}

#Preview {
    @State var fatCrabModel: any FatCrabProtocol = FatCrabMock(for: .signet)
    return NetworkSelectView(model: $fatCrabModel)
}
