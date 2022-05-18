//
//  CallRefresherTests.swift
//  LUX_Tests
//
//  Created by Calvin Collins on 12/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FlexDataSource
import LithoOperators
@testable import LUX
import XCTest
import Prelude
import FunNet

let humans: [Human] = [Human(id: 123, name: "Calvin Collins"), Human(id: 123, name: "Elliot Schrock")]
let parseHuman: (Data) -> [Human]? = {
    return try? JSONDecoder().decode([Human].self, from: $0)
}
let encodeHuman: ([Human]) -> Data? = {
    return try? JSONEncoder().encode($0)
}
let encodeHumanHolder: (HumanHolder) -> Data? = {
    return try? JSONEncoder().encode($0)
}
let json:String = String(data: encodeHuman(humans)!, encoding: .utf8)!
let jsonHolder: String = String(data: encodeHumanHolder(HumanHolder(humans: humans))!, encoding: .utf8)!
struct HumanHolder: Codable {
    var humans: [Human]
}


class CallRefresherTests: XCTestCase {
    func testRefresh() {
        let call: CombineNetCall = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        call.firingFunc = ~>{ (call: CombineNetCall) in call.publisher.data = json.data(using: .utf8) }
        let refresher = LUXCallRefresher(call)
        XCTAssert(!refresher.isFetching)
        refresher.onRefresh = {
            XCTAssert(refresher.isFetching)
        }
    }
    
    func testNetCallsRefresher() {
        var firstCalled: Bool = false
        var secondCalled: Bool = false
        let call1: CombineNetCall = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        let call2: CombineNetCall = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        call1.firingFunc = { _ in firstCalled = true }
        call2.firingFunc = { _ in secondCalled = true }
        
        let callRefresher = LUXNetCallsRefresher(call1, call2)
        callRefresher.refresh()
        
        XCTAssertTrue(firstCalled && secondCalled)
    }
}
