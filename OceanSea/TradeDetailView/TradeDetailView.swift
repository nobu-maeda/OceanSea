//
//  TradeDetailView.swift
//  OceanSea
//
//  Created by Nobu Maeda on 2024/03/04.
//

import SwiftUI

struct TradeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var orderEnvelope: FatCrabOrderEnvelopeProtocol?
    @Binding var trade: FatCrabTrade?
    
    var body: some View {
        let tradeType = tradeType()
        let orderType = orderType()
        let orderAmount = orderAmount()
        let orderPrice = orderPrice()
        let pubkeyString = peerPubkey()
        
        return NavigationStack {
            List {
                Section {
                    OrderDetailSummaryView(orderAmount: orderAmount, orderPrice: orderPrice, pubkeyString: pubkeyString)
                } header: {
                    Text("Order Summary")
                }
                
                Section {
                    TradeDetailExplainView(tradeType: tradeType, orderType: orderType, orderAmount: orderAmount, orderPrice: orderPrice)
                } header: {
                    Text("Explaination")
                }
                
                if let trade = trade, shouldShowStatus() {
                    Section {
                        TradeDetailStatusView(for: trade)
                    } header: {
                        Text("Status")
                    }
                }
                
                if let trade = trade {
                    if shouldShowAction() {
                        Section {
                            TradeDetailActionView(for: trade)
                        } header: {
                            Text("Action")
                        }
                    }
                } else if orderEnvelope != nil {
                    Section {
                        TakeOrderActionView(orderEnvelope: $orderEnvelope, trade: $trade)
                    } header: {
                        Text("Action")
                    }
                }
            }
            .navigationTitle(navigationTitleString())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            }
        }
    }
    
    func navigationTitleString() -> String {
        switch orderType() {
        case .buy:
            return "Order to buy FatCrabs with BTC"
        case .sell:
            return "Order to sell FatCrabs for BTC"
        }
    }
    
    func tradeType() -> FatCrabTradeType {
        guard let trade = trade else {
            return .taker
        }
        return trade.tradeType
    }
    
    func orderType() -> FatCrabOrderType {
        if let trade = trade {
            return trade.orderType
        } else if let orderEnvelope = orderEnvelope {
            return orderEnvelope.order().orderType
        } else {
            fatalError("TradeDetailView does not have either Trade nor Order to determine Order Type")
        }
    }
    
    func orderAmount() -> Double {
        if let trade = trade {
            return trade.orderAmount
        } else if let orderEnvelope = orderEnvelope {
            return orderEnvelope.order().amount
        } else {
            fatalError("TradeDetailView does not have either Trade nor Order to determine Order Amount")
        }
    }
    
    func orderPrice() -> Double {
        if let trade = trade {
            return trade.orderPrice
        } else if let orderEnvelope = orderEnvelope {
            return orderEnvelope.order().price
        } else {
            fatalError("TradeDetailView does not have either Trade nor Order to determine Order Price")
        }
    }
    
    func peerPubkey() -> String? {
        if let trade = trade {
            return trade.peerPubkey
        } else if let orderEnvelope = orderEnvelope {
            return orderEnvelope.pubkey()
        } else {
            fatalError("TradeDetailView does not have either Trade nor Order to determine Peer Pubkey")
        }
    }
    
    func shouldShowStatus() -> Bool {
        guard let trade = trade else {
            return false
        }
        
        switch trade {
        case .maker(let maker):
            if maker.state == .new {
                return false
            } else {
                return true
            }
        case .taker(let taker):
            if taker.state == .new {
                return false
            } else {
                return true
            }
        }
    }
    
    func shouldShowAction() -> Bool {
        guard let trade = trade else {
            return false
        }
        switch trade {
        case .maker(let maker):
            switch maker.state {
            case .new:
                return false
            case .waitingForOffers:
                return false
            case .receivedOffer:
                return true
            case .acceptedOffer:
                return false
            case .inboundBtcNotified:
                return true
            case .inboundFcNotified:
                return true
            case .notifiedOutbound:
                return false
            case .tradeCompleted:
                return false
            }
        case .taker(let taker):
            switch taker.state {
            case .new:
                return false
            case .submittedOffer:
                return false
            case .offerAccepted:
                return true
            case .offerRejected:
                return false
            case .notifiedOutbound:
                return false
            case .inboundBtcNotified:
                return false
            case .inboundFcNotified:
                return true
            case .tradeCompleted:
                return false
            }
        }
    }
}

#Preview("Order Details - Buy") {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    @State var trade: FatCrabTrade? = nil
    return TradeDetailView(orderEnvelope: $orderEnvelope, trade: $trade)
}

#Preview("Order Details - Sell") {
    let order = FatCrabOrder(orderType: .sell, tradeUuid: UUID().uuidString, amount: 32498.99, price: 4)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    @State var trade: FatCrabTrade? = nil
    return TradeDetailView(orderEnvelope: $orderEnvelope, trade: $trade)
}

#Preview("Maker - Received Offer") {
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = nil
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.receivedOffer, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(orderEnvelope: $orderEnvelope, trade: $trade)
}

#Preview("Maker - Inbound Btc Notified") {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.sell(maker: FatCrabMakerSellMock(state: FatCrabMakerState.inboundBtcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(orderEnvelope: $orderEnvelope, trade: $trade)
}

#Preview("Maker - Inbound FatCrab Notified") {
    let order = FatCrabOrder(orderType: .sell, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    @State var trade: FatCrabTrade? = FatCrabTrade.maker(maker: FatCrabMakerTrade.buy(maker: FatCrabMakerBuyMock(state: FatCrabMakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(orderEnvelope: $orderEnvelope, trade: $trade)
}

#Preview("Taker Buy - Offer Accepted") {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.buy(taker: FatCrabTakerBuyMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(orderEnvelope: $orderEnvelope, trade: $trade)
}

#Preview("Taker Sell - Offer Accepted") {
    let order = FatCrabOrder(orderType: .buy, tradeUuid: UUID().uuidString, amount: 1234.56, price: 5678.9)
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = FatCrabOrderEnvelopeMock(order: order)
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.offerAccepted, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(orderEnvelope: $orderEnvelope, trade: $trade)
}

#Preview("Taker - Inbound FatCrab Notified") {
    @State var orderEnvelope: FatCrabOrderEnvelopeProtocol? = nil
    @State var trade: FatCrabTrade? = FatCrabTrade.taker(taker: FatCrabTakerTrade.sell(taker: FatCrabTakerSellMock(state: FatCrabTakerState.inboundFcNotified, amount: 1234.56, price: 5678.9, tradeUuid: UUID(), peerPubkey: "SomePubKey000-0014")))
    return TradeDetailView(orderEnvelope: $orderEnvelope, trade: $trade)
}
