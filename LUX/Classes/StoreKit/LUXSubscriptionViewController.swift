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

public let productToPriceString: (SKProduct) -> String = fzip(currency, price, productTimeFrame) >>> combinePriceString

public func productTimeFrame(_ product: SKProduct) -> String {
    let period = product.subscriptionPeriod?.numberOfUnits
    switch product.subscriptionPeriod?.unit {
    case .month:
        if (period != nil && period != 1) {
            return "\(period!) Months"
        } else {
            return "Month"
        }
    case .year:
        return "Year"
    case .none:
        return ""
    default:
        return ""
    }
}


let currency: (SKProduct) -> String = ^\SKProduct.priceLocale.currencySymbol >>> coalesceNil(with: "")
let price = ^\SKProduct.price
let combinePriceString: ((String, NSDecimalNumber, String)) -> String = { "\($0.0)\($0.1)/\($0.2)" }
