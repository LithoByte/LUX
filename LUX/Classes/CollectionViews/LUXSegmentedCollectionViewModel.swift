//
//  LUXSegmentedCollectionViewModel.swift
//  LUX
//
//  Created by Calvin Collins on 3/17/21.
//

import Foundation
import FlexDataSource

open class LUXSegmentedCollectionViewModel: LUXRefreshableCollectionViewModel {
    public var selectedIndex: Int = 0 {
        didSet {
            configureDataSource()
        }
    }
    public var segments: [FlexCollectionDataSource]? {
        didSet {
            configureDataSource()
        }
    }
    
    public func configureDataSource() {
        if let count = segments?.count, selectedIndex < count {
            dataSource = segments?[selectedIndex]
            collectionView?.reloadData()
        } else {
            dataSource = nil
        }
    }
}

