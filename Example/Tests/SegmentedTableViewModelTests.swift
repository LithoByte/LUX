//
//  SegmentedTableViewModelTests.swift
//  LUX_Tests
//
//  Created by Calvin Collins on 4/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import FunNet
import FlexDataSource
@testable import LUX

class SegmentedTableViewModelTests: XCTestCase {
    func testEmptyTableView() {
        let call = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        let vm = LUXSegmentedTableViewModel(LUXCallRefresher(call))
        vm.segments = []
        XCTAssertNil(vm.dataSource)
    }
    
    func testNonEmptyTableView(){
        let call = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        let vm = LUXSegmentedTableViewModel(LUXCallRefresher(call))
        let sections = [FlexDataSourceSection(title: "One", items: []), FlexDataSourceSection(title: "Two", items: [])]
        let source = FlexDataSource(nil, sections)
        vm.segments = [source]
        XCTAssertNotNil(vm.dataSource)
        vm.selectedIndex = 1
        XCTAssertNotNil(vm.dataSource)
        XCTAssertEqual(vm.dataSource! as! FlexDataSource, source)
        XCTAssertNotNil(vm.segments)
    }
}
