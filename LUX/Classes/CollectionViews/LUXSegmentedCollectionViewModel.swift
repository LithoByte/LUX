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
            dataSource = segments?[selectedIndex]
            collectionView?.reloadData()
        }
    }
    public var segments: [FlexCollectionDataSource]? {
        didSet {
            dataSource = segments?[selectedIndex]
            collectionView?.reloadData()
        }
    }
}

