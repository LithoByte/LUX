//
//  SegmentedCollectionViewModelTests.swift
//  LUX_Tests
//
//  Created by Calvin Collins on 10/27/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import FunNet
import FlexDataSource
@testable import LUX

class SegmentedCollectionViewModelTests: XCTestCase {
    func testEmptyTableView() {
        let call = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        let vm = LUXSegmentedCollectionViewModel(LUXCallRefresher(call))
        vm.segments = []
        XCTAssertNil(vm.dataSource)
    }
    
    func testNonEmptyCollectionView(){
        let call = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        let vm = LUXSegmentedCollectionViewModel(LUXCallRefresher(call))
        let sections = [FlexCollectionSection(title: "One", items: []), FlexCollectionSection(title: "Two", items: [])]
        let source = FlexCollectionDataSource(nil, sections)
        vm.segments = [source]
        XCTAssertNotNil(vm.dataSource)
        vm.selectedIndex = 0
        XCTAssertNotNil(vm.dataSource)
        XCTAssertEqual(vm.dataSource! as! FlexCollectionDataSource, source)
        XCTAssertNotNil(vm.segments)
    }
    
    func testSegmentOutOfRange() {
        let call = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "/v1/api"), Endpoint())
        let vm = LUXSegmentedCollectionViewModel(LUXCallRefresher(call))
        let sections = [FlexCollectionSection(title: "One", items: []), FlexCollectionSection(title: "Two", items: [])]
        let source = FlexCollectionDataSource(nil, sections)
        vm.segments = [source]
        XCTAssertNotNil(vm.dataSource)
        vm.selectedIndex = 2
        XCTAssertNil(vm.dataSource)
        XCTAssertNotNil(vm.segments)
    }
}
