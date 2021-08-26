//
//  PagingDelegateTests.swift
//  LithoUXComponents_Tests
//
//  Created by Elliot Schrock on 10/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import fuikit
@testable import LUX
@testable import FunNet

class PagingDelegateTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testSecondPage() {
        var wasCalled = false
        let pageManager = MockPageManager({
            wasCalled = true
        })
        
        let delegate = FPUITableViewDelegate()
        delegate.onWillDisplay = pageManager.willDisplayFunction()
        
        let tv = MockTableView()
        tv.numberOfRows = 20
        tv.previousRow = 14
        let cell = UITableViewCell()
        let indexPath = IndexPath.init(row: 15, section: 0)
        delegate.tableView(tv, willDisplay: cell, forRowAt: indexPath)
        
        XCTAssert(wasCalled)
    }

    func testNextPage() {
        var wasCalled = false
        let pageManager = MockPageManager({
            wasCalled = true
        })
        
        let delegate = FPUITableViewDelegate()
        delegate.onWillDisplay = pageManager.willDisplayFunction()
        
        let tv = MockTableView()
        tv.numberOfRows = 40
        tv.previousRow = 34
        let cell = UITableViewCell()
        let indexPath = IndexPath.init(row: 35, section: 0)
        delegate.tableView(tv, willDisplay: cell, forRowAt: indexPath)
        
        XCTAssert(wasCalled)
    }

    func testNotNextPage() {
        var wasCalled = false
        let pageManager = MockPageManager({
            wasCalled = true
        })
        
        let delegate = FPUITableViewDelegate()
        delegate.onWillDisplay = pageManager.willDisplayFunction()
        
        let tv = MockTableView()
        tv.numberOfRows = 40
        tv.previousRow = 14
        let cell = UITableViewCell()
        let indexPath = IndexPath.init(row: 15, section: 0)
        delegate.tableView(tv, willDisplay: cell, forRowAt: indexPath)
        
        XCTAssertFalse(wasCalled)
    }

    func testNotNextWhenPageSizeWrong() {
        var wasCalled = false
        let pageManager = MockPageManager({
            wasCalled = true
        })
        
        let delegate = FPUITableViewDelegate()
        delegate.onWillDisplay = pageManager.willDisplayFunction()
        
        let tv = MockTableView()
        tv.numberOfRows = 42
        tv.previousRow = 36
        let cell = UITableViewCell()
        let indexPath = IndexPath.init(row: 37, section: 0)
        delegate.tableView(tv, willDisplay: cell, forRowAt: indexPath)
        
        XCTAssertFalse(wasCalled)
    }
}

class MockPageManager: LUXCallPager {
    var nextPageCalled: () -> Void
    
    init(_ nextPageCalled: @escaping () -> Void) {
        self.nextPageCalled = nextPageCalled
        super.init(CombineNetCall(configuration: ServerConfiguration(host: "lithobyte.co", apiRoute: "api/v1"), Endpoint()))
    }
    
    override func nextPage() {
        nextPageCalled()
    }
}

class MockTableView: UITableView {
    var previousRow: Int?
    var numberOfRows: Int?
    override var indexPathsForVisibleRows: [IndexPath]? { return [IndexPath(row: previousRow!, section: 0)] }
    
    override func numberOfRows(inSection section: Int) -> Int {
        return numberOfRows ?? 0
    }
}
