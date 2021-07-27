//
//  SubscriptionViewController.swift
//  LUX
//
//  Created by Calvin Collins on 7/26/21.
//

import UIKit
import fuikit
import StoreKit
import Combine
import LithoOperators


public func subscriptionViewModel<C: LUXSubscriptionTableViewCell>(configureCell: @escaping (SKProduct, C) -> Void = configureSubscriptionCell, onTap: @escaping (SKProduct) -> Void = productToPayment >?> addPayment, delegate: LUXSubscriptionDelegate = LUXSubscriptionDelegate()) -> LUXItemsTableViewModel {
    let modelToItem = tappableModelItem(configureCell, onTap: onTap) -*> map
    return LUXItemsTableViewModel(delegate, itemsPublisher: delegate.$products.map(modelToItem).eraseToAnyPublisher())
}

public class LUXSubscriptionViewController: FUITableViewViewController {
    @IBOutlet weak var termsButton: UIButton!
    
    open var subscriptionsDelegate = LUXSubscriptionDelegate()
    
    public var onTermsPressed: (() -> Void)?
    
    @IBAction func termsPressed(_ sender: UIButton!) {
        onTermsPressed?()
    }
}

public func productToPayment(product: SKProduct) -> (SKPayment?) {
    return SKPaymentQueue.canMakePayments() ? SKPayment.init(product: product) : nil
}
public let addPayment: (SKPayment) -> Void = SKPaymentQueue.default().add

public func configureSubscriptionCell(product: SKProduct, cell: LUXSubscriptionTableViewCell) {
    cell.subscriptionNameLabel.text = "\(product.localizedTitle)"
    cell.subscriptionDescriptionLabel.text = "\(product.localizedDescription)"
}

public func productToPriceString(_ product: SKProduct) -> String {
    let currency = product.priceLocale.currencySymbol ?? ""
    let price = product.price
    let period = product.subscriptionPeriod?.numberOfUnits
    var unit: String?
    switch product.subscriptionPeriod?.unit {
    case .month:
        if (period != nil && period != 1) {
            unit = "\(period!) Months"
        } else {
            unit = "Month"
        }
    case .year:
        unit = "Year"
    case .none:
        unit = ""
    default:
        unit = ""
    }
    return "\(currency)\(price)/\(unit ?? "")"
}
