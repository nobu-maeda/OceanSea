//
//  EnterSeedsView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2023/12/28.
//

import SwiftUI

struct EnterSeedsView: View {
    enum EnterSeedsViewAlertType {
        case resetWalletConfirm
        case resetWalletError
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var model: any FatCrabProtocol
    
    @State private var mnemonic: [String] = Array(repeating: "", count: 24)
    @State private var isBusy = false
    
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    @State private var alertType = EnterSeedsViewAlertType.resetWalletConfirm
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                HStack(spacing: 0) {
                    List {
                        ForEach(0..<(mnemonic.count/2), id:\.self) { i in
                            TextField("Word #\(i+1)", text: $mnemonic[i])
                                .disableAutocorrection(true)
#if os(iOS)
                                .textInputAutocapitalization(.never)
#endif
                        }
                    }.scrollDisabled(true)
                    List {
                        ForEach(mnemonic.count/2..<(mnemonic.count), id:\.self) { i in
                            TextField("Word #\(i+1)", text: $mnemonic[i])
                            
                                .disableAutocorrection(true)
#if os(iOS)
                                .textInputAutocapitalization(.never)
#endif
                        }
                    }.scrollDisabled(true)
                }.frame(height: 600)
            }
            Spacer()
            Button("Reset Wallet with Seed Words") {
                checkSeedsAndConfirmResetWallet()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!checkMnemonicComplete())
            Spacer()
        }
        .navigationTitle("Reset Wallet")
        .modifier(ActivityIndicatorModifier(isLoading: isBusy))
        .alert(alertTitleString, isPresented: $showAlert) {
            switch alertType {
            case .resetWalletConfirm:
                Button("Proceed", role: .destructive) {
                    resetWallet()
                }
                Button("Cancel", role: .cancel) {}
            case .resetWalletError:
                Button("OK", role: .cancel) {}
            }
        } message: { Text(alertBodyString) }
    }
    
    func checkMnemonicComplete() -> Bool {
        for word in mnemonic {
            if word.isEmpty {
                return false
            }
        }
        return true
    }
    
    func checkSeedsAndConfirmResetWallet() {
        for word in mnemonic {
            if word.isEmpty {
                showMnemonicError()
                return
            }
        }
        showResetWalletConfirm()
    }
    
    func showMnemonicError() {
        alertTitleString = "Error"
        alertBodyString = "All 24 seed words must be entered."
        alertType = .resetWalletError
        showAlert = true
    }
    
    func showResetWalletConfirm() {
        alertTitleString = "Reset Wallet"
        alertBodyString = "The entered seeds will be used to create a wallet. If any matching trade data is locally found related to the entered seeds, it will be restored. Please ensure the current wallet seeds is backed up before proceeding, as the seeds will be destroyed."
        alertType = .resetWalletConfirm
        showAlert = true
    }
    
    func resetWallet() {
        isBusy = true
        
        Task {
            let newWalletModel = type(of: model).resetWallet(with: mnemonic, for: model.network)
            
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
    return EnterSeedsView(model: $fatCrabModel)
}
