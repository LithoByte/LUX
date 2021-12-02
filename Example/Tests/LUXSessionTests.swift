//
//  LUXSessionTests.swift
//  LUX_Tests
//
//  Created by Calvin Collins on 12/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import LUX
import FunNet

class LUXSessionTests: XCTestCase {

    func testServerAuth() {
        let session = LUXAppGroupUserDefaultsSession(host: "lithobyte.co", authHeaderKey: "Authorization")
        session.setAuthValue(authString: "abcdefg")
        LUXSessionManager.primarySession = session
        
        XCTAssert(session.isAuthenticated())
        
        var endpoint = Endpoint()
        authorize(&endpoint)
        
        XCTAssert(endpoint.httpHeaders["Authorization"] == "abcdefg")
        
        session.clearAuth()
        
        XCTAssertTrue(session.authHeaders()?["Authorization"] == "")
    }
    
    func testLUXMultiHeaderSession() {
        let session = LUXMultiHeaderDefaultsSession(host: "host", authHeaders: [:])
        session.setAuthHeaders(dict: ["Authorization": "abcdefg"])
        LUXSessionManager.primarySession = session
        
        XCTAssertEqual(session.authHeaders(), ["Authorization": "abcdefg"])
        XCTAssertTrue(session.isAuthenticated())
        
        session.clearAuth()
        XCTAssertNil(session.authHeaders())
    }
    
    func testKeyChainSession() {
        let session = LUXKeyChainSession(host: "host", authHeaderKey: "Authorization")
        session.setAuthValue(authString: "abcdefg")
        LUXSessionManager.primarySession = session
        
        XCTAssertEqual(session.authHeaders(), ["Authorization": "abcdefg"])
        XCTAssertTrue(session.isAuthenticated())
        
        session.clearAuth()
        XCTAssertNil(session.authHeaders())
    }

}
