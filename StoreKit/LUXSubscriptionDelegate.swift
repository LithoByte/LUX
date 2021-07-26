//
//  LUXSubscriptionDelegate.swift
//  LUX
//
//  Created by Calvin Collins on 7/26/21.
//

import Foundation
import StoreKit
import Slippers
import Combine
import Prelude
import LithoOperators
import FunNet



public class LUXSubscriptionDelegate: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, Refreshable {
    
    public var cancelBag: Set<AnyCancellable> = []
    @Published var products: [SKProduct] = []
    public var productsCall: CombineNetCall?
    
    public var onFailed: ((SKPaymentTransaction) -> Void)?
    public var onPurchased: ((SKPaymentTransaction) -> Void)?
    public var onPurchasing: ((SKPaymentTransaction) -> Void)?
    public var onDeferred: ((SKPaymentTransaction) -> Void)?
    public var onRestored: ((SKPaymentTransaction) -> Void)?
    
    public var onRefresh: (() -> Void)?
    
    public init(onFailed: ((SKPaymentTransaction) -> Void)? = nil, onPurchased: ((SKPaymentTransaction) -> Void)? = nil, onPurchasing: ((SKPaymentTransaction) -> Void)? = nil, onDeferred: ((SKPaymentTransaction) -> Void)? = nil, onRestored: ((SKPaymentTransaction) -> Void)? = nil) {
        super.init()
        self.onFailed = onFailed
        self.onPurchased = onPurchased
        self.onPurchasing = onPurchasing
        self.onDeferred = onDeferred
        self.onRestored = onRestored
    }
    
    public func refresh() {
        onRefresh?()
    }
    
    open func fetchProducts(withIdentifiers identifiers: [String]) {
        let request = productIdsToRequest(identifiers)
        request.delegate = self
        request.start()
        onRefresh = identifiers *> fetchProducts
    }
    
    open func fetchProducts<T: Decodable>(from call: CombineNetCall, unwrapper: @escaping (T) -> [String]) {
        self.productsCall = call
        let productPub = unwrappedModelPublisher(from: call.publisher.$data.eraseToAnyPublisher(), unwrapper)
        productPub.sink(receiveValue: fetchProducts).store(in: &cancelBag)
    }
    
    open func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }
    
    open func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach(handleUpdatedTransactions(onFailed: onFailed, onPurchased: onPurchased, onDeferred: onDeferred, onPurchasing: onPurchasing, onRestored: onRestored))
    }
}

public let productIdsToRequest: ([String]) -> SKProductsRequest = Set<String>.init >>> SKProductsRequest.init

public func handleUpdatedTransactions(onFailed: ((SKPaymentTransaction) -> Void)?, onPurchased: ((SKPaymentTransaction) -> Void)?, onDeferred: ((SKPaymentTransaction) -> Void)?, onPurchasing: ((SKPaymentTransaction) -> Void)?, onRestored: ((SKPaymentTransaction) -> Void)?) -> (SKPaymentTransaction) -> Void {
    return { transaction in
        switch transaction.transactionState {
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                onFailed?(transaction)
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                onPurchased?(transaction)
            case .purchasing:
                onPurchasing?(transaction)
            case .deferred:
                onDeferred?(transaction)
            case .restored:
                onRestored?(transaction)
            @unknown default:
                break
        }
    }
}
