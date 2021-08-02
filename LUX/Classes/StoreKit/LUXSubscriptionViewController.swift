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
import PlaygroundVCHelpers
import Prelude

public func subscriptionViewController<T: CombineProductsProvider & LUXSubscriptionDelegate, C: UITableViewCell>(styleVC: @escaping (LUXSubscriptionViewController<T>) -> Void, configureCell: @escaping (SKProduct, C) -> Void = ~second(optionalCast) >>> ~configureSubscriptionCell, onTap: @escaping (SKProduct) -> Void = productToPayment >?> addPayment, termsPressed: (() -> Void)? = nil, delegate: LUXCombineSubscriptionDelegate) -> LUXSubscriptionViewController<T> {
    let vc = LUXSubscriptionViewController<T>.makeFromXIB()
    let vm = subscriptionViewModel(configureCell: configureCell, onTap: onTap, delegate: delegate)
    vc.onViewDidLoad = {
        vm.tableView = $0.tableView
        vm.tableView?.reloadData()
        vm.refresh()
    }
    vc.onTermsPressed = termsPressed
    return vc
}

public func subscriptionViewModel<C: UITableViewCell>(configureCell: @escaping (SKProduct, C) -> Void = ~second(optionalCast) >>> ~configureSubscriptionCell, onTap: @escaping (SKProduct) -> Void = productToPayment >?> addPayment, delegate: LUXCombineSubscriptionDelegate) -> LUXItemsTableViewModel {
    let modelToItem = tappableModelItem(configureCell, onTap: onTap) -*> map
    return LUXItemsTableViewModel(delegate, itemsPublisher: delegate.$products.map(modelToItem).eraseToAnyPublisher())
}

public class LUXSubscriptionViewController<T: LUXIdSubscriptionDelegate>: FUITableViewViewController {
    @IBOutlet weak var termsButton: UIButton!
    
    open var subscriptionsDelegate: T?
    
    public var onTermsPressed: (() -> Void)?
    
    @IBAction func termsPressed(_ sender: UIButton!) {
        onTermsPressed?()
    }
}

public func productToPayment(product: SKProduct) -> (SKPayment?) {
    return SKPaymentQueue.canMakePayments() ? SKPayment.init(product: product) : nil
}
public let addPayment: (SKPayment) -> Void = SKPaymentQueue.default().add

public func configureSubscriptionCell(product: SKProduct, cell: LUXSubscriptionTableViewCell?) {
    cell?.subscriptionNameLabel.text = "\(product.localizedTitle)"
    cell?.subscriptionDescriptionLabel.text = "\(product.localizedDescription)"
    cell?.priceButton.setTitle(productToPriceString(product), for: .normal)
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
