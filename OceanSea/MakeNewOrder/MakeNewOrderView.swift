//
//  MakeNewOrderView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/01/01.
//

import SwiftUI

struct MakeNewOrderView: View {
    private enum FocusedField: Hashable {
        case price
        case amount
        case fatcrabAddr
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.fatCrabModel) var model
    
    @State private var orderType: FatCrabOrderType = .buy
    @State private var priceInputString = ""
    @State private var amountInputString = ""
    @State private var fatcrabRxAddrInputString = ""
    @State private var isBusy = false
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    var body: some View {
        NavigationStack {
            List {
                Picker("OrderType", selection: $orderType) {
                    Text("Buy").tag(FatCrabOrderType.buy)
                    Text("Sell").tag(FatCrabOrderType.sell)
                }.pickerStyle(SegmentedPickerStyle())
                
                TextField("Price (Sats / FatCrab)", text: $priceInputString)
                    .focused($focusedField, equals: .price)
                    .onSubmit {
                        if validatePriceField() != nil {
                            focusedField = .amount
                        } else {
                            focusedField = .price
                        }
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                
                TextField("Amount (# of FatCrabs)", text: $amountInputString)
                    .focused($focusedField, equals: .amount)
                    .onSubmit {
                        if validateAmountField() != nil {
                            if orderType == .buy {
                                focusedField = .fatcrabAddr
                            } else {
                                createNewOrder()
                            }
                        } else {
                            focusedField = .amount
                        }
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                
                if orderType == .buy {
                    TextField("FatCrab Receive Address", text: $fatcrabRxAddrInputString)
                        .focused($focusedField, equals: .fatcrabAddr)
                        .onSubmit {
                            if validateFatCrabAddrField() != nil {
                                createNewOrder()
                            } else {
                                focusedField = .fatcrabAddr
                            }
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Make New Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        self.createNewOrder()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            }
            .modifier(ActivityIndicatorModifier(isLoading: isBusy))
            .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
        }
        .onAppear(perform: { focusedField = .price })
    }
    
    private func createNewOrder() {
        guard let price = validatePriceField() else { return }
        guard let amount = validateAmountField() else { return }
        
        // Is there a way to validate the input string against valid FatCrab address?
        
        isBusy = true
        
        Task {
            do {
                switch orderType {
                case .buy:
                    _ = try await model.makeBuyOrder(price: price, amount: amount, fatcrabRxAddr: fatcrabRxAddrInputString)
                case .sell:
                    _ = try await model.makeSellOrder(price: price, amount: amount)
                }
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

            isBusy = false
            dismiss.callAsFunction()
        }
    }
    
    func validatePriceField() -> Double? {
        guard let price = Double(priceInputString) else {
            alertTitleString = "Error"
            alertBodyString = "Input price not of decimal numerical value"
            showAlert = true
            return nil
        }
        return price
    }
    
    func validateAmountField() -> Double? {
        guard let amount = Double(amountInputString) else {
            alertTitleString = "Error"
            alertBodyString = "Input amount not of demical numerical value"
            showAlert = true
            return nil
        }
        return amount
    }
    
    func validateFatCrabAddrField() -> String? {
        return fatcrabRxAddrInputString
    }
}

#Preview {
    MakeNewOrderView().environment(\.fatCrabModel, FatCrabMock())
}
