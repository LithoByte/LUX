//
//  LUXSegmentedTableViewModel.swift
//  LUX
//
//  Created by Calvin Collins on 3/17/21.
//

import Foundation
import Combine
import FlexDataSource

open class LUXSegmentedTableViewModel: LUXRefreshableTableViewModel {
    public var selectedIndex: Int = 0 {
        didSet {
            dataSource = segments?[selectedIndex]
            tableView?.reloadData()
        }
    }
    public var segments: [FlexDataSource]? {
        didSet {
            dataSource = segments?[selectedIndex]
            tableView?.reloadData()
        }
    }
}
