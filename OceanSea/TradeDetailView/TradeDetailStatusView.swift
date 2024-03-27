//
//  TradeDetailStatusView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailStatusView: View {
    @State var btcConfs = 0
    
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    let trade: FatCrabTrade
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
    }
    
    var body: some View {
        switch trade {
        case .maker(let maker):
            switch maker.state {
            case .new:
                Text("New")
            case .waitingForOffers:
                Text("Waiting for Offers from potential Takers")
            case .receivedOffer:
                Text("Received \(maker.offers.count) offers from Takers")
            case .acceptedOffer:
                switch maker {
                case .buy:
                    Text("Accepted Offer. Waiting for FatCrab from Taker")
                case .sell:
                    Text("Accepted Offer. Waiting for BTC from Taker")
                }
            case .inboundBtcNotified:
                Text("Taker claims BTC sent. \(btcConfs) confirmations detected")
                    .refreshable {
                        await updateBtcConfs()
                    }
                    .task {
                        await updateBtcConfs()
                    }
                    .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
            case .inboundFcNotified:
                Text("Taker claims FatCrab sent. Confirm receipt before BTC release")
            case .notifiedOutbound:
                switch maker {
                case .buy:
                    Text("Notified Taker of BTC release")
                case .sell:
                    Text("Notified Taker of FatCrab release")
                }
            case .tradeCompleted:
                Text("Trade Completed")
            }
            
        case .taker(let taker):
            switch taker.state {
            case .new:
                Text("New")
            case .submittedOffer:
                Text("Submitted Offer. Waiting for Trade Response from Maker")
            case .offerAccepted:
                Text("Offer Accepted by Maker")
            case .offerRejected:
                Text("Offer Rejected by Maker")
            case .notifiedOutbound:
                switch taker {
                case .buy:
                    Text("Maker notified of FatCrab sent. Awaiting for BTC payment")
                case .sell:
                    Text("Maker notified of BTC sent. Awaiting notification of FatCrab")
                }
            case .inboundBtcNotified:
                Text("Maker claims BTC sent. \(btcConfs) confirmations detected")
                    .refreshable {
                        await updateBtcConfs()
                    }
                    .task {
                        await updateBtcConfs()
                    }
                    .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
            case .inboundFcNotified:
                Text("Maker claims FatCrab sent. Confirm receipt to complete trade")
            case .tradeCompleted:
                Text("Trade Completed")
            }
        }
    }
    
    private func updateBtcConfs() async {
        do {
            switch trade {
            case .maker(let maker):
                switch maker {
                case .buy:
                    return
                case .sell(let sellMaker):
                    let uIntBtcConfs = try await sellMaker.checkBtcTxConfirmation()
                    btcConfs = Int(uIntBtcConfs)
                }
            case .taker(let taker):
                switch taker {
                case .buy(let buyTaker):
                    let uIntBtcConfs = try await buyTaker.checkBtcTxConfirmation()
                    btcConfs = Int(uIntBtcConfs)
                case .sell:
                    return
                }
            }
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

#Preview {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID())))
    return TradeDetailStatusView(for: trade)
}
