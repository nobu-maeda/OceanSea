//
//  TradeDetailStatusView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI
import OSLog

struct TradeDetailStatusView: View {
    @Environment(\.fatCrabModel) var model
    
    @Binding var trade: FatCrabTrade?
    @Binding var showAlert: Bool
    @Binding var alertTitleString: String
    @Binding var alertBodyString: String
    @Binding var alertType: TradeDetailViewAlertType
    
    @State private var btcConfs = 0
    
    var body: some View {
        if let trade = trade {
            switch trade {
            case .maker(let maker):
                let txID = switch maker {
                case .buy(let buyMaker):
                    buyMaker.peerFcTxid
                case .sell(let sellMaker):
                    sellMaker.peerBtcTxid
                }
                
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
                    Text("Taker claims BTC sent. \(btcConfs) confirmations detected for TxID: \(txID ?? "")")
                        .task(id: model.blockHeight) {
                            await updateBtcConfs(trade: trade)
                        }
                case .inboundFcNotified:
                    Text("Taker claims FatCrab sent with TxID \(txID ?? "")")
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
                let txID = switch taker {
                case .buy(let buyTaker):
                    buyTaker.peerBtcTxid
                case .sell(let sellTaker):
                    sellTaker.peerFcTxid
                }
                
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
                        Text("Maker notified of FatCrab sent. Waiting for BTC from Maker")
                    case .sell:
                        Text("Maker notified of BTC sent. Waiting for FatCrab from Maker")
                    }
                case .inboundBtcNotified:
                    Text("Maker claims BTC sent. \(btcConfs) confirmations detected for TxID: \(txID ?? "")")
                        .task(id: model.blockHeight) {
                            await updateBtcConfs(trade: trade)
                        }
                case .inboundFcNotified:
                    Text("Maker claims FatCrab sent with TxID \(txID ?? "")")
                case .tradeCompleted:
                    Text("Trade Completed")
                }
            }
        }
    }
    
    private func updateBtcConfs(trade: FatCrabTrade) async {
        do {
            let uIntBtcConfs: UInt32
            
            switch trade {
            case .maker(let maker):
                switch maker {
                case .buy:
                    return
                case .sell(let sellMaker):
                    uIntBtcConfs = try await sellMaker.checkBtcTxConfirmation()
                    
                }
            case .taker(let taker):
                switch taker {
                case .buy(let buyTaker):
                    uIntBtcConfs = try await buyTaker.checkBtcTxConfirmation()
                case .sell:
                    return
                }
            }
            
            Task { @MainActor in
                btcConfs = Int(uIntBtcConfs)
            }
        } catch let fatCrabError as FatCrabError {
            Logger.appInterface.warning("Warning: \(fatCrabError.localizedDescription)")
        }
        catch {
            Task { @MainActor in
                alertTitleString = "Error"
                alertBodyString = error.localizedDescription
                alertType = .okAlert
                showAlert = true
            }
        }
    }
}

#Preview("BuyMaker") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID())))
    return TradeDetailStatusView(trade: $trade, showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("SellMaker") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.inboundBtcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerBtcTxid: "SomeTxID000-0057")))
    return TradeDetailStatusView(trade: $trade, showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("BuyTaker") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.inboundBtcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0057", peerBtcTxid: "SomeTxID000-0057")))
    return TradeDetailStatusView(trade: $trade, showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}
