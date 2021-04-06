//
//  TableViewModelTests.swift
//  LUX_Tests
//
//  Created by Elliot Schrock on 12/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import LUX
import Combine
import Prelude
import LithoOperators
import FlexDataSource
import Slippers
import FunNet

class TableModelViewModelTests: XCTestCase {
    func testModels() {
        var wasCalled = false
        let subject = PassthroughSubject<[Human], Never>()
        let vm = LUXModelTableViewModel(modelsPublisher: subject.eraseToAnyPublisher(), modelToItem: humanConfigurer >>> configurerToItem)
        let cancel = vm.$models.sinkThrough { _ in
            wasCalled = true
        }
        subject.send([Human(id: 123, name: "Calvin Collins")])
        XCTAssert(wasCalled)
        cancel.cancel()
    }
    
    func testSections() {
        var wasCalled = false
        let subject = PassthroughSubject<[Human], Never>()
        let vm = LUXModelTableViewModel(modelsPublisher: subject.eraseToAnyPublisher(), modelToItem: humanConfigurer >>> configurerToItem)
        let cancel = vm.sectionsPublisher.sinkThrough { _ in
            wasCalled = true
        }
        subject.send([neo])
        XCTAssert(wasCalled)
        cancel.cancel()
    }
}

class TableViewModelTests: XCTestCase {
    func testViewModel() {
        let vm = LUXTableViewModel()
        let tableView = UITableView()
        vm.tableView = tableView
        XCTAssert(vm.tableView != nil)
    }
    
}

class RefreshableTableViewModelTests: XCTestCase {
    func testViewModel() {
        let call: CombineNetCall = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        call.firingFunc = { $0.responder?.data = json.data(using: .utf8) }
        let refresher = LUXCallRefresher(call)
        var wasRefreshed: Bool = false
        let vm = LUXRefreshableTableViewModel(refresher)
        refresher.onRefresh = {
            wasRefreshed = true
        }
        XCTAssert(!(vm.refresher as! LUXCallRefresher).isFetching)
        vm.refresh()
        XCTAssert(wasRefreshed)
        let tableView = UITableView()
        vm.tableView = tableView
        vm.setupEndRefreshing(from: call)
        XCTAssert(vm.tableView != nil)
    }
    
    func testPageTableViewModel() {
        let call: CombineNetCall = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        call.firingFunc = { $0.responder?.data = json.data(using: .utf8) }
        let configurer: (Human, UITableViewCell) -> Void = {
            humanConfigurer($0)($1)
        }
        let vm: LUXItemsTableViewModel = pageableTableViewModel(call, configurer, { _ in
            print("Tapped")
        })
        vm.sectionsPublisher.sinkThrough({ XCTAssert($0.count > 0)}).cancel()
        
    }
    
    func testRefreshableTableViewModel() {
        let call: CombineNetCall = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        call.firingFunc = { $0.responder?.data = json.data(using: .utf8) }
        let configurer: (Human, UITableViewCell) -> Void = {
            humanConfigurer($0)($1)
        }
        
        var wasTapped: Bool = false
        let vm: LUXRefreshableTableViewModel = refreshableTableViewModel(call, configurer, { _ in
            wasTapped = true
        })
        vm.refresh()
    }
}

