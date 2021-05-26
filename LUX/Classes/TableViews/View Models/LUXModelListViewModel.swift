//
//  LUXModelListViewModel.swift
//  ThryvUXComponents
//
//  Created by Elliot Schrock on 7/18/18.
//

import UIKit
import FlexDataSource
import Prelude
import Combine

public typealias LUXTableDataSource = FlexDataSource & UITableViewDataSource

public protocol LUXDataSourceProvider {
    var flexDataSource: LUXTableDataSource { get set }
}

open class LUXModelListViewModel<T>: LUXModelTableViewModel<T>, LUXDataSourceProvider {
    public var flexDataSource: LUXTableDataSource
    
    public override init(modelsPublisher: AnyPublisher<[T], Never>, modelToItem: @escaping (T) -> FlexDataSourceItem) {
        flexDataSource = FlexSimpleDataSource()
        super.init(modelsPublisher: modelsPublisher, modelToItem: modelToItem)
        
        cancelBag.insert(self.sectionsPublisher.sink {
            self.flexDataSource.sections = $0
            self.flexDataSource.tableView?.reloadData()
        })
    }
}

open class LUXFilteredModelListViewModel<T>: LUXModelListViewModel<T> {
    public init(modelsPublisher: AnyPublisher<[T], Never>, filter: @escaping (T) -> Bool, modelToItem: @escaping (T) -> FlexDataSourceItem) {
        super.init(modelsPublisher: modelsPublisher.map { $0.filter(filter) }.eraseToAnyPublisher(), modelToItem: modelToItem)
    }
}
