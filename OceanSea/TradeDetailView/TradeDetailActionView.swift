//
//  TradeDetailActionView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailActionView: View {
    @Environment(\.fatCrabModel) var model
    
    @Binding var trade: FatCrabTrade?
    @Binding var isBusy: Bool
    @Binding var showAlert: Bool
    @Binding var alertTitleString: String
    @Binding var alertBodyString: String
    @Binding var alertType: TradeDetailViewAlertType
    
    @State private var fatcrabTxId = ""
    
    
    var body: some View {
        VStack {
            if let trade = trade {
                switch trade {
                case .maker(let maker):
                    switch maker.state {
                    case .new:
                        Text("You can cancel the order if you no longer want to wait for offers")
                        Button() {
                            cancelOrder(for: maker)
                        } label: {
                            Text("Cancel Order")
                        }.buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(.red)
                    case .waitingForOffers:
                        Text("You can cancel the order if you no longer want to wait for offers")
                        Button() {
                            cancelOrder(for: maker)
                        } label: {
                            Text("Cancel Order")
                        }.buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(.red)
                    case .receivedOffer:
                        Text("Click to accept the first valid offer received. You will no longer be able to cancel this order once you have accepted the offer")
                        HStack {
                            Button() {
                                acceptOffer(for: maker)
                            } label: {
                                Text("Accept Offer")
                            }.buttonStyle(.borderedProminent)
                                .controlSize(.large)
                            Button() {
                                cancelOrder(for: maker)
                            } label: {
                                Text("Cancel Order")
                            }.buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .tint(.red)
                        }
                    case .acceptedOffer:
                        Text("No Actions Available")
                    case .inboundBtcNotified:
                        switch maker {
                        case .buy:
                            Text("No Actions Available")
                        case .sell(let sellMaker):
                            Text("Remit FatCrab to Webank Account ID \(sellMaker.peerFcAddr ?? "??") for Taker, before clicking to notify")
                            
                            TextField(text: $fatcrabTxId) {
                                Text("FatCrab Webank Transaction ID")
                            }
                            .padding(.leading)
                            .padding(.trailing)
                            .autocorrectionDisabled()
#if os(iOS)
                            .textInputAutocapitalization(.never)
                            .textFieldStyle(.roundedBorder)
#endif
                                
                            Button() {
                                notifyTaker(of: fatcrabTxId, by: maker)
                            } label: {
                                Text("Notify Taker of FatCrab remitted")
                            }.buttonStyle(.borderedProminent)
                                .controlSize(.large)
                        }
                    case .inboundFcNotified:
                        Text("Confirm FatCrab received in Webank before releasing BTC and notifying Taker")
                        Button() {
                            releaseBtcNotifyTaker(by: maker)
                        } label: {
                            Text("Release BTC & notify Taker")
                        }.buttonStyle(.borderedProminent)
                            .controlSize(.large)
                    case .notifiedOutbound:
                        Text("Mark Trade Completed")
                        Button() {
                            tradeComplete(maker: maker)
                        } label: {
                            Text("Trade complete")
                        }.buttonStyle(.borderedProminent)
                    case .tradeCompleted:
                        Text("No Actions Available")
                    case .tradeCancelled:
                        Text("No Actions Available")
                    }
                case .taker(let taker):
                    switch taker.state {
                    case .new:
                        Text("No Actions Available")
                    case .submittedOffer:
                        Text("No Actions Available")
                    case .offerAccepted:
                        switch taker {
                        case .buy(let buyTaker):
                            Text("Remit FatCrab to Webank Account ID \(buyTaker.peerFcAddr ?? "??") for Maker, before clicking to notify")
                            
                            TextField(text: $fatcrabTxId) {
                                Text("FatCrab Webank Transaction ID")
                            }
                            .padding(.leading)
                            .padding(.trailing)
                            .autocorrectionDisabled()
#if os(iOS)
                            .textInputAutocapitalization(.never)
                            .textFieldStyle(.roundedBorder)
#endif
                            
                            Button() {
                                notifyMaker(of: fatcrabTxId, by: taker)
                            } label: {
                                Text("Notify Maker of FatCrab remitted")
                            }.buttonStyle(.borderedProminent)
                        case .sell:
                            Text("Offer Accepted. Send BTC and notifying Maker")
                            Button() {
                                releaseBtcNotifyMaker(by: taker)
                            } label: {
                                Text("Release BTC & notify Taker")
                            }.buttonStyle(.borderedProminent)
                                .controlSize(.large)
                        }
                    case .offerRejected:
                        Text("No Actions Available")
                    case .notifiedOutbound:
                        Text("No Actions Available")
                    case .inboundBtcNotified:
                        Text("Confirm BTC received before marking Trade completed")
                        Button() {
                            tradeComplete(taker: taker)
                        } label: {
                            Text("BTC receive confirmed")
                        }.buttonStyle(.borderedProminent)
                    case .inboundFcNotified:
                        Text("Confirm FatCrab received in Webank before marking Trade completed")
                        Button() {
                            tradeComplete(taker: taker)
                        } label: {
                            Text("FatCrab receive confirmed")
                        }.buttonStyle(.borderedProminent)
                    case .tradeCompleted:
                        Text("No Actions Available")
                    }
                }
            }
        }
    }
    
    private func acceptOffer(for maker: FatCrabMakerTrade) {
        isBusy = true
        
        Task {
            do {
                let offer = maker.offers.first!
                try await maker.tradeResponse(tradeRspType: .accept, offerEnvelope: offer)
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
    
    private func notifyTaker(of fatcrabTxId: String, by maker: FatCrabMakerTrade) {
        guard !fatcrabTxId.isEmpty else {
            alertTitleString = "Error"
            alertBodyString = "FatCrab Transaction ID is empty"
            alertType = .okAlert
            showAlert = true
            return
        }
        
        isBusy = true
        
        Task {
            do {
                switch maker {
                case .buy:
                    throw OceanSeaError.invalidState("Can only notify Taker of FatCrab remit for Sell Makers")
                case .sell(let sellMaker):
                    try await sellMaker.notifyPeer(fatcrabTxid: fatcrabTxId)
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
    
    private func releaseBtcNotifyTaker(by maker: FatCrabMakerTrade) {
        isBusy = true
        
        Task {
            do {
                switch maker {
                case .buy(let buyMaker):
                    try await buyMaker.releaseNotifyPeer()
                case .sell:
                    throw OceanSeaError.invalidState("Can only release Btc & notify Taker for Buy Makers")
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
    
    private func tradeComplete(maker: FatCrabMakerTrade) {
        isBusy = true
        Task {
            do {
                try await maker.tradeComplete()
            } catch let fatCrabError as FatCrabError {
                alertTitleString = "Error"
                alertBodyString = fatCrabError.description()
                alertType = .okAlert
                showAlert = true
            }
            catch {
                alertTitleString = "Error"
                alertBodyString = error.localizedDescription
                alertType = .okAlert
                showAlert = true
            }
            isBusy = false
        }
    }
    
    private func notifyMaker(of fatcrabTxId: String, by taker: FatCrabTakerTrade) {
        guard !fatcrabTxId.isEmpty else {
            alertTitleString = "Error"
            alertBodyString = "FatCrab Transaction ID is empty"
            alertType = .okAlert
            showAlert = true
            return
        }
        
        isBusy = true
        
        Task {
            do {
                switch taker {
                case .buy(let buyTaker):
                    try await buyTaker.notifyPeer(fatcrabTxid: fatcrabTxId)
                case .sell:
                    throw OceanSeaError.invalidState("Can only notify Maker of FatCrab remit for Buy Takers")
                    
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
    
    private func releaseBtcNotifyMaker(by taker: FatCrabTakerTrade) {
        isBusy = true
        
        Task {
            do {
                switch taker {
                case .buy:
                    throw OceanSeaError.invalidState("Can only release Btc & notify Maker for Sell Takers")
                    
                case .sell(let sellTaker):
                    try await sellTaker.releaseNotifyPeer()
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
    
    private func tradeComplete(taker: FatCrabTakerTrade) {
        isBusy = true
        Task {
            do {
                try await taker.tradeComplete()
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
    
    private func cancelOrder(for maker: FatCrabMakerTrade) {
        alertTitleString = "Cancel Order"
        alertBodyString = "Are you sure you want to cancel and remove the order from all Nostr nodes?"
        alertType = .cancelOrder
        showAlert = true
    }
}

#Preview("Maker Buy - Random") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Maker Sell - Random") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Taker Buy - Random") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Taker Sell - Random") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Maker - Waiting for Offers") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.waitingForOffers, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Maker - Received Offer") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.receivedOffer, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Maker - Inbound Btc Notified") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.inboundBtcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Maker - Inbound FatCrab Notified") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Taker Buy - Offer Accepted") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Taker Sell - Offer Accepted") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}

#Preview("Taker - Inbound FatCrab Notified") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade, isBusy: .constant(false), showAlert: .constant(false), alertTitleString: .constant(""), alertBodyString: .constant(""), alertType: .constant(.okAlert))
}
