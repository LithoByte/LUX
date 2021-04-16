//
//  LUXSegmentedTableViewModel.swift
//  LUX
//
//  Created by Calvin Collins on 3/17/21.
//

import Foundation
import FlexDataSource

open class LUXSegmentedTableViewModel: LUXRefreshableTableViewModel {
    public var selectedIndex: Int = 0 {
        didSet {
            configureDataSource()
        }
    }
    public var segments: [FlexDataSource]? {
        didSet {
            configureDataSource()
        }
    }
    
    public func configureDataSource() {
        if let count = segments?.count, selectedIndex < count {
            dataSource = segments?[selectedIndex]
            tableView?.reloadData()
        }
    }
}
