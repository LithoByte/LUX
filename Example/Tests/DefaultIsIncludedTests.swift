//
//  DefaultIsIncludedTests.swift
//  LUX_Tests
//
//  Created by Elliot Schrock on 12/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import LUX
import LithoOperators

class DefaultIsIncludedTests: XCTestCase {
    func testUsesNilMatcher() throws {
        var wasNilCalled = false
        let nilMatcher: () -> Bool = {
            wasNilCalled = true
            return true
        }
        
        var wasEmptyCalled = false
        let emptyMatcher: () -> Bool = {
            wasEmptyCalled = true
            return true
        }
        
        var wasMatcherCalled = false
        let matcher: (String, String) -> Bool = { _, _ in
            wasMatcherCalled = true
            return true
        }
        
        XCTAssert(defaultMatchesString(nil, "Neo Anderson", nilMatcher, emptyMatcher, matcher))
        XCTAssert(wasNilCalled)
        XCTAssertFalse(wasEmptyCalled)
        XCTAssertFalse(wasMatcherCalled)
    }
    
    func testUsesEmptyMatcher() throws {
        var wasNilCalled = false
        let nilMatcher: () -> Bool = {
            wasNilCalled = true
            return true
        }
        
        var wasEmptyCalled = false
        let emptyMatcher: () -> Bool = {
            wasEmptyCalled = true
            return true
        }
        
        var wasMatcherCalled = false
        let matcher: (String, String) -> Bool = { _, _ in
            wasMatcherCalled = true
            return true
        }
        
        XCTAssert(defaultMatchesString("", "Neo Anderson", nilMatcher, emptyMatcher, matcher))
        XCTAssertFalse(wasNilCalled)
        XCTAssert(wasEmptyCalled)
        XCTAssertFalse(wasMatcherCalled)
        
        wasEmptyCalled = false
    }
    
    func testUsesMatcher() throws {
        var wasNilCalled = false
        let nilMatcher: () -> Bool = {
            wasNilCalled = true
            return true
        }
        
        var wasEmptyCalled = false
        let emptyMatcher: () -> Bool = {
            wasEmptyCalled = true
            return true
        }
        
        var wasMatcherCalled = false
        let matcher: (String, String) -> Bool = { _, _ in
            wasMatcherCalled = true
            return true
        }
        
        XCTAssert(defaultMatchesString("Neo", "Neo Anderson", nilMatcher, emptyMatcher, matcher))
        XCTAssertFalse(wasNilCalled)
        XCTAssertFalse(wasEmptyCalled)
        XCTAssert(wasMatcherCalled)
    }
    
    func testUsesNilMatcherWhenKeyPathNil() throws {
        var wasNilCalled = false
        let nilMatcher: () -> Bool = {
            wasNilCalled = true
            return true
        }
        
        var wasEmptyCalled = false
        let emptyMatcher: () -> Bool = {
            wasEmptyCalled = true
            return true
        }
        
        var wasMatcherCalled = false
        let matcher: (String, String) -> Bool = { _, _ in
            wasMatcherCalled = true
            return true
        }
        
        XCTAssert(defaultIsIncluded("test", Human(id: 1, name: nil), ^\.name, nilMatcher, emptyMatcher, matcher))
        XCTAssert(wasNilCalled)
        XCTAssertFalse(wasEmptyCalled)
        XCTAssertFalse(wasMatcherCalled)
    }
}
