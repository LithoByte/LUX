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

public protocol CombineProductsProvider {
    var products: [SKProduct] { get set }
}

public class LUXSubscriptionDelegate: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    public var onReceiveProducts: (([SKProduct]) -> Void)?
    
    public var onFailed: ((SKPaymentTransaction) -> Void)?
    public var onPurchased: ((SKPaymentTransaction) -> Void)?
    public var onPurchasing: ((SKPaymentTransaction) -> Void)?
    public var onDeferred: ((SKPaymentTransaction) -> Void)?
    public var onRestored: ((SKPaymentTransaction) -> Void)?
    
    public init(onFailed: ((SKPaymentTransaction) -> Void)? = nil, onPurchased: ((SKPaymentTransaction) -> Void)? = nil, onPurchasing: ((SKPaymentTransaction) -> Void)? = nil, onDeferred: ((SKPaymentTransaction) -> Void)? = nil, onRestored: ((SKPaymentTransaction) -> Void)? = nil, onReceiveProducts: (([SKProduct]) -> Void)?) {
        super.init()
        self.onFailed = onFailed
        self.onPurchased = onPurchased
        self.onPurchasing = onPurchasing
        self.onDeferred = onDeferred
        self.onRestored = onRestored
        self.onReceiveProducts = onReceiveProducts
        SKPaymentQueue.default().add(self)
    }
    
    open func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { [weak self] in
            self?.onReceiveProducts?(response.products)
        }
    }
    
    open func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach(handleUpdatedTransactions(onFailed: onFailed, onPurchased: onPurchased, onDeferred: onDeferred, onPurchasing: onPurchasing, onRestored: onRestored))
    }
}

public class LUXIdSubscriptionDelegate: LUXSubscriptionDelegate, Refreshable {
    var onRefresh: (() -> Void)?
    
    public func refresh() {
        onRefresh?()
    }
    
    public override init(onFailed: ((SKPaymentTransaction) -> Void)? = SKPaymentQueue.default().finishTransaction, onPurchased: ((SKPaymentTransaction) -> Void)? = SKPaymentQueue.default().finishTransaction, onPurchasing: ((SKPaymentTransaction) -> Void)? = nil, onDeferred: ((SKPaymentTransaction) -> Void)? = nil, onRestored: ((SKPaymentTransaction) -> Void)? = nil, onReceiveProducts: (([SKProduct]) -> Void)?) {
        super.init(onFailed: onFailed, onPurchased: onPurchased, onPurchasing: onPurchasing, onDeferred: onDeferred, onRestored: onRestored, onReceiveProducts: onReceiveProducts)
    }
    
    open func fetchProducts(withIdentifiers identifiers: [String]) {
        let request = productIdsToRequest(identifiers)
        request.delegate = self
        request.start()
        onRefresh = identifiers *> fetchProducts
    }
}

public class LUXLocalIdSubscriptionDelegate: LUXIdSubscriptionDelegate, CombineProductsProvider {
    @Published public var products: [SKProduct] = []
    
    public init(onFailed: ((SKPaymentTransaction) -> Void)? = SKPaymentQueue.default().finishTransaction, onPurchased: ((SKPaymentTransaction) -> Void)? = SKPaymentQueue.default().finishTransaction, onPurchasing: ((SKPaymentTransaction) -> Void)? = nil, onDeferred: ((SKPaymentTransaction) -> Void)? = nil, onRestored: ((SKPaymentTransaction) -> Void)? = nil, onReceiveProducts: @escaping (LUXLocalIdSubscriptionDelegate, [SKProduct]) -> Void = setter(\.products)) {
        super.init(onFailed: onFailed, onPurchased: onPurchased, onPurchasing: onPurchasing, onDeferred: onDeferred, onRestored: onRestored, onReceiveProducts: nil)
        self.onReceiveProducts = self *-> onReceiveProducts
    }
    
}

public class LUXNetCallSubscriptionDelegate<T: NetworkCall & Fireable>: LUXIdSubscriptionDelegate {
    var call: T?
    public init(call: T, onFailed: ((SKPaymentTransaction) -> Void)? = SKPaymentQueue.default().finishTransaction,
                onPurchased: ((SKPaymentTransaction) -> Void)? = SKPaymentQueue.default().finishTransaction,
                onPurchasing: ((SKPaymentTransaction) -> Void)? = nil,
                onDeferred: ((SKPaymentTransaction) -> Void)? = nil,
                onRestored: ((SKPaymentTransaction) -> Void)? = nil,
                onReceiveProducts: (([SKProduct]) -> Void)?) {
        super.init(onFailed: onFailed, onPurchased: onPurchased, onPurchasing: onPurchasing, onDeferred: onDeferred, onRestored: onRestored, onReceiveProducts: onReceiveProducts)
        self.call = call
    }
    
    public override func refresh() {
        call?.fire()
    }
    
    open func fetchProducts<U: Codable>(unwrapper: @escaping (U) -> [String]) {
        call?.responder?.dataHandler = ((U.self *-> JsonProvider.decode) -*> ifExecute) >?> (unwrapper >>> fetchProducts)
        call?.fire()
    }
}

public class LUXCombineSubscriptionDelegate: LUXNetCallSubscriptionDelegate<CombineNetCall> {
    var cancelBag: Set<AnyCancellable> = []
    
    @Published public var products: [SKProduct] = []
    
    public init(call: CombineNetCall, onFailed: ((SKPaymentTransaction) -> Void)? = SKPaymentQueue.default().finishTransaction, onPurchased: ((SKPaymentTransaction) -> Void)? = SKPaymentQueue.default().finishTransaction, onPurchasing: ((SKPaymentTransaction) -> Void)? = nil, onDeferred: ((SKPaymentTransaction) -> Void)? = nil, onRestored: ((SKPaymentTransaction) -> Void)? = nil, onReceiveProducts: @escaping (LUXCombineSubscriptionDelegate, [SKProduct]) -> Void = setter(\.products)) {
        super.init(call: call, onFailed: onFailed, onPurchased: onPurchased, onPurchasing: onPurchasing, onDeferred: onDeferred, onRestored: onRestored, onReceiveProducts: nil)
        self.onReceiveProducts = self *-> onReceiveProducts
    }
    
    public override func fetchProducts<U: Codable>(unwrapper: @escaping (U) -> [String]){
        unwrappedModelPublisher(from: call?.publisher.$data.eraseToAnyPublisher(), unwrapper)?.sink(receiveValue: fetchProducts).store(in: &cancelBag)
    }
}

public let productIdsToRequest: ([String]) -> SKProductsRequest = Set<String>.init >>> SKProductsRequest.init

public func handleUpdatedTransactions(onFailed: ((SKPaymentTransaction) -> Void)?, onPurchased: ((SKPaymentTransaction) -> Void)?, onDeferred: ((SKPaymentTransaction) -> Void)?, onPurchasing: ((SKPaymentTransaction) -> Void)?, onRestored: ((SKPaymentTransaction) -> Void)?) -> (SKPaymentTransaction) -> Void {
    return { transaction in
        switch transaction.transactionState {
            case .failed:
                onFailed?(transaction)
            case .purchased:
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
