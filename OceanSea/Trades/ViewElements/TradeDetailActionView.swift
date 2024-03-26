//
//  TradeDetailActionView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/21.
//

import SwiftUI

struct TradeDetailActionView: View {
    @State private var fatcrabTxId = ""
    @State private var showAlert = false
    @State private var alertTitleString = ""
    @State private var alertBodyString = ""
    
    let trade: FatCrabTrade
    
    init(for trade: FatCrabTrade) {
        self.trade = trade
    }
    
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
                    Text("Remit Fatcrab to Taker, before clicking to notify")
                    TextField(text: $fatcrabTxId) {
                        Text("Fatcrab Tx ID")
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    Button() {
                        notifyTaker(of: fatcrabTxId, by: maker)
                    } label: {
                        Text("Notify Taker of Fatcrab remitted")
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                case .inboundFcNotified:
                    Text("Confirm Fatcrab received before releasing BTC and notifying Taker")
                    Button() {
                        releaseBtcNotifyTaker(by: maker)
                    } label: {
                        Text("Release BTC & notify Taker")
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                case .notifiedOutbound:
                    Text("No Actions Available")
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
                        Text("Remit Fatcrab to Maker, before clicking to notify")
                        TextField(text: $fatcrabTxId) {
                            Text("Fatcrab Tx ID")
                        }
                        .padding(.leading)
                        .padding(.trailing)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                        Button() {
                            notifyMaker(of: fatcrabTxId, by: taker)
                        } label: {
                            Text("Notify Maker of Fatcrab remitted")
                        }.buttonStyle(.borderedProminent)
                    case .sell:
                        Text("No Actions Available")
                    }
                case .offerRejected:
                    Text("No Actions Available")
                case .notifiedOutbound:
                    Text("No Actions Available")
                case .inboundBtcNotified:
                    Text("No Actions Available")
                case .inboundFcNotified:
                    Text("Confirm Fatcrab received before marking Trade completed")
                    Button() {
                        tradeComplete(for: taker)
                    } label: {
                        Text("Fatcrab receive confirmed")
                    }.buttonStyle(.borderedProminent)
                case .tradeCompleted:
                    Text("No Actions Available")
                }
            }
        }
        .alert(alertTitleString, isPresented: $showAlert, actions: { Button("OK", role: .cancel) {}}, message: { Text(alertBodyString) })
    }
    
    func acceptOffer(for maker: FatCrabMakerTrade) {
        do {
            let offer = maker.offers.first!
            try maker.tradeResponse(tradeRspType: .accept, offerEnvelope: offer)
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
    
    func notifyTaker(of fatcrabTxId: String, by maker: FatCrabMakerTrade) {
        do {
            switch maker {
            case .buy:
                throw OceanSeaError.invalidState("Can only notify Taker of Fatcrab remit for Sell Makers")
            case .sell(let sellMaker):
                try sellMaker.notifyPeer(fatcrabTxid: fatcrabTxId)
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
    
    func releaseBtcNotifyTaker(by maker: FatCrabMakerTrade) {
        do {
            switch maker {
            case .buy(let buyMaker):
                try buyMaker.releaseNotifyPeer()
            case .sell:
                throw OceanSeaError.invalidState("Can only release Btc & notify Taker for Buy Makers")
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
    
    func notifyMaker(of fatcrabTxId: String, by taker: FatCrabTakerTrade) {
        do {
            switch taker {
            case .buy(let buyTaker):
                try buyTaker.notifyPeer(fatcrabTxid: fatcrabTxId)
            case .sell:
                throw OceanSeaError.invalidState("Can only notify Maker of Fatcrab remit for Buy Takers")
                
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
    
    func tradeComplete(for taker: FatCrabTakerTrade) {
        do {
            try taker.tradeComplete()
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

#Preview("Maker Buy - Random") {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Maker Sell - Random") {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Taker Buy - Random") {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Taker Sell - Random") {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Maker - Received Offer") {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.receivedOffer, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Maker - Inbound Btc Notified") {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.inboundBtcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Maker - Inbound Fatcrab Notified") {
    let trade = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Taker Buy - Offer Accepted") {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Taker Sell - Offer Accepted") {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}

#Preview("Taker - Inbound Fatcrab Notified") {
    let trade = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailActionView(for: trade)
}
