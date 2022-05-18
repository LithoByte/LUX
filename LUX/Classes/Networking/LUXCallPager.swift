//
//  LUXCallPager.swift
//  LUX
//
//  Created by Elliot Schrock on 7/9/20.
//

import FunNet
import Slippers
import Combine
import Foundation

open class LUXCallPager: Pager, NetworkFetcher {
    open var call: CombineNetCall?
    @Published open var isFetching = false
    open var cancelBag = Set<AnyCancellable>()
    
    public init(pageKeyName: String = "page", countKeyName: String = "count", defaultCount: Int = 20, firstPageValue: Int = 0, _ call: CombineNetCall?) {
        self.call = call
        super.init(firstPageValue: firstPageValue, onPageUpdate: nil)
        self.onPageUpdate = { [unowned self] page in
            if var getParams = self.call?.endpoint.getParams.filter({ $0.name != pageKeyName }).filter({ $0.name != countKeyName }) {
                getParams.append(URLQueryItem(name: pageKeyName, value: "\(page)"))
                getParams.append(URLQueryItem(name: countKeyName, value: "\(defaultCount)"))
                self.call?.endpoint.getParams = getParams
            }
            self.call?.fire()
            self.isFetching = true
        }
        self.call?.publisher.$response.sink { [unowned self] _ in self.isFetching = false }.store(in: &cancelBag)
        self.call?.publisher.$data.sink { [unowned self] _ in self.isFetching = false }.store(in: &cancelBag)
        self.call?.publisher.$error.sink { [unowned self] _ in self.isFetching = false }.store(in: &cancelBag)
    }
}
