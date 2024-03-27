//
//  TradeDetailView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/04.
//

import SwiftUI

struct TradeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var trade: FatCrabTrade?
    
    @State var shouldShowStatus = false
    @State var shouldShowAction = false
    
    var body: some View {
        guard let trade = trade else {
            fatalError("Trade should not be nil for TradeDetailView")
        }
        
        return NavigationStack {
            List {
                Section {
                    OrderDetailSummaryView(orderAmount: trade.orderAmount, orderPrice: trade.orderPrice, pubkeyString: trade.peerPubkey)
                } header: {
                    Text("Order Summary")
                }
                
                Section {
                    TradeDetailExplainView(tradeType: trade.tradeType, orderType: trade.orderType, orderAmount: trade.orderAmount, orderPrice: trade.orderPrice)
                } header: {
                    Text("Explaination")
                }
                
                if shouldShowStatus {
                    Section {
                        TradeDetailStatusView(for: trade)
                    } header: {
                        Text("Status")
                    }
                }
                
                if shouldShowAction {
                    Section {
                        TradeDetailActionView(for: trade)
                    } header: {
                        Text("Action")
                    }
                }
            }
            .refreshable {
                updateViews()
            }
            .onAppear() {
                updateViews()
            }
            .navigationTitle(navigationTitleString(for: trade))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            }
        }
    }
    
    func navigationTitleString(for trade: FatCrabTrade) -> String {
        let buyString = "Order to buy Fatcrabs with BTC"
        let sellString = "Order to sell Fatcrabs for BTC"
        
        switch trade {
        case .maker(let maker):
            switch maker {
            case .buy:
                return buyString
            case .sell:
                return sellString
            }
                
        case .taker(let taker):
            switch taker {
            case .buy:
                return buyString
            case .sell:
                return sellString
            }
        }
    }
    
    func updateViews() {
        updateShouldShowStatus()
        updateShouldShowAction()
    }
    
    func updateShouldShowStatus() {
        switch trade! {
        case .maker(let maker):
            if maker.state == .new {
                shouldShowStatus = false
            } else {
                shouldShowStatus = true
            }
        case .taker(let taker):
            if taker.state == .new {
                shouldShowStatus = false
            } else {
                shouldShowStatus = true
            }
        }
    }
    
    func updateShouldShowAction() {
        switch trade! {
        case .maker(let maker):
            switch maker.state {
            case .new:
                shouldShowAction = false
            case .waitingForOffers:
                shouldShowAction = false
            case .receivedOffer:
                shouldShowAction = true
            case .acceptedOffer:
                shouldShowAction = false
            case .inboundBtcNotified:
                shouldShowAction = true
            case .inboundFcNotified:
                shouldShowAction = true
            case .notifiedOutbound:
                shouldShowAction = false
            case .tradeCompleted:
                shouldShowAction = false
            }
        case .taker(let taker):
            switch taker.state {
            case .new:
                shouldShowAction = false
            case .submittedOffer:
                shouldShowAction = false
            case .offerAccepted:
                shouldShowAction = true
            case .offerRejected:
                shouldShowAction = false
            case .notifiedOutbound:
                shouldShowAction = false
            case .inboundBtcNotified:
                shouldShowAction = false
            case .inboundFcNotified:
                shouldShowAction = true
            case .tradeCompleted:
                shouldShowAction = false
            }
        }
    }
}

#Preview("Maker Buy - Random") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Maker Sell - Random") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Taker Buy - Random") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.random(for: .buy), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Taker Sell - Random") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.random(for: .sell), amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Maker - Received Offer") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.receivedOffer, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Maker - Inbound Btc Notified") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.inboundBtcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Maker - Inbound Fatcrab Notified") {
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Taker Buy - Offer Accepted") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Taker Sell - Offer Accepted") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}

#Preview("Taker - Inbound Fatcrab Notified") {
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(trade: $trade)
}
