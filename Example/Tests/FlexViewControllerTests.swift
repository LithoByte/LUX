//
//  FlexViewControllerTests.swift
//  LUX_Tests
//
//  Created by Calvin Collins on 1/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import LUX
import FlexDataSource
import FunNet
import Combine
import Slippers

class FlexViewControllerTests: XCTestCase {

    func testFlexViewController() {
        let call = CombineNetCall(configuration: ServerConfiguration(host: "lithobyte.co", apiRoute: nil), Endpoint())
        let refreshManager = LUXRefreshableNetworkCallManager(call)
        let tableView = UITableView(frame: .zero)
        let dataSource = FlexSimpleDataSource(tableView, nil)
        let vc = LUXFlexViewController<FlexDataSource>()
        vc.viewModel = dataSource
        vc.refreshableModelManager = refreshManager
        XCTAssertNotNil(vc.refreshableModelManager)
    }

}

