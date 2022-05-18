//
//  LUXSearchable.swift
//  LUX
//
//  Created by Elliot Schrock on 11/11/20.
//

import FunNet
import Slippers

public protocol LUXSearchable {
    func updateIncrementalSearch(text: String?)
    func updateSearch(text: String?)
}

public func defaultOnSearch<T>(_ searcher: LUXSearchable, _ call: T, _ refresher: Refreshable? = nil, paramName: String = "query") -> (String) -> Void where T: NetworkCall {
    return { text in
        searcher.updateSearch(text: text)
        var getParams = call.endpoint.getParams.filter { $0.name != paramName }
        if !text.isEmpty {
            getParams.append(URLQueryItem(name: paramName, value: text))
        }
        call.endpoint.getParams = getParams
        if let refresher = refresher {
            refresher.refresh()
        } else {
            call.fire()
        }
    }
}
