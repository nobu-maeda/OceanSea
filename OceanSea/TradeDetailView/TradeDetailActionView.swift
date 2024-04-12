//
//  TradeDetailActionView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailActionView: View {
    @Binding var trade: FatCrabTrade
    
    @State private var fatcrabTxId = ""
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    var body: some View {
        VStack {
            switch trade {
            case .maker(let maker):
                switch maker.state {
                case .new:
                    Text("No Actions Available")
                case .waitingForOffers:
                    Text("No Actions Available")
                case .receivedOffer:
                    Text("Click to accept the first valid offer received")
                    Button() {
                        acceptOffer(for: maker)
                    } label: {
                        Text("Accept Offer")
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                case .acceptedOffer:
                    Text("No Actions Available")
                case .inboundBtcNotified:
                    Text("Remit FatCrab to Taker, before clicking to notify")
                    TextField(text: $fatcrabTxId) {
                        Text("FatCrab Transaction ID")
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    Button() {
                        notifyTaker(of: fatcrabTxId, by: maker)
                    } label: {
                        Text("Notify Taker of FatCrab remitted")
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                case .inboundFcNotified:
                    Text("Confirm FatCrab received before releasing BTC and notifying Taker")
                    Button() {
                        releaseBtcNotifyTaker(by: maker)
                    } label: {
                        Text("Release BTC & notify Taker")
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                case .notifiedOutbound:
                    Text("Mark Trade Completed")
                    Button() {
                        tradeComplete(maker: maker)
                    } label: {
                        Text("Trade complete")
                    }.buttonStyle(.borderedProminent)
                case .tradeCompleted:
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
                        case .buy:
                        Text("Remit FatCrab to Maker, before clicking to notify")
                        TextField(text: $fatcrabTxId) {
                            Text("FatCrab Transaction ID")
                        }
                        .padding(.leading)
                        .padding(.trailing)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                        Button() {
                            notifyMaker(of: fatcrabTxId, by: taker)
                        } label: {
                            Text("Notify Maker of FatCrab remitted")
                        }.buttonStyle(.borderedProminent)
                    case .sell:
                        Text("No Actions Available")
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
                    Text("Confirm FatCrab received before marking Trade completed")
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
        .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
    }
    
    private func acceptOffer(for maker: FatCrabMakerTrade) {
        Task {
            do {
                let offer = maker.offers.first!
                try await maker.tradeResponse(tradeRspType: .accept, offerEnvelope: offer)
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
        }
    }
    
    private func notifyTaker(of fatcrabTxId: String, by maker: FatCrabMakerTrade) {
        guard !fatcrabTxId.isEmpty else {
            alertTitleString = "Error"
            alertBodyString = "FatCrab Transaction ID is empty"
            showAlert = true
            return
        }
        
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
        }
    }
    
    private func releaseBtcNotifyTaker(by maker: FatCrabMakerTrade) {
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
        }
    }
    
    private func tradeComplete(maker: FatCrabMakerTrade) {
        Task {
            do {
                try await maker.tradeComplete()
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
    
    private func notifyMaker(of fatcrabTxId: String, by taker: FatCrabTakerTrade) {
        guard !fatcrabTxId.isEmpty else {
            alertTitleString = "Error"
            alertBodyString = "FatCrab Transaction ID is empty"
            showAlert = true
            return
        }
        
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
        }
    }
    
    private func tradeComplete(taker: FatCrabTakerTrade) {
        Task {
            do {
                try await taker.tradeComplete()
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
        }
    }
}

#Preview("Maker Buy - Random") {
    @State var trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Maker Sell - Random") {
    @State var trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Taker Buy - Random") {
    @State var trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Taker Sell - Random") {
    @State var trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Maker - Received Offer") {
    @State var trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.receivedOffer, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Maker - Inbound Btc Notified") {
    @State var trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.inboundBtcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Maker - Inbound FatCrab Notified") {
    @State var trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Taker Buy - Offer Accepted") {
    @State var trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Taker Sell - Offer Accepted") {
    @State var trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}

#Preview("Taker - Inbound FatCrab Notified") {
    @State var trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(trade: $trade)
}
