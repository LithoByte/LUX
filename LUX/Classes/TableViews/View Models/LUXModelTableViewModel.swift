//
//  LUXModelTableViewModel.swift
//  ThryvUXComponents
//
//  Created by Elliot Schrock on 7/23/18.
//

import UIKit
import FlexDataSource
import Prelude
import FunNet
import Combine
import LithoOperators

open class LUXModelTableViewModel<T>: LUXModelCallViewModel<T> {
    public var sectionsPublisher: AnyPublisher<[FlexDataSourceSection], Never>!
    public var modelToItem: ((T) -> FlexDataSourceItem)
    
    public init(modelsPublisher: AnyPublisher<[T], Never>, modelToItem: @escaping (T) -> FlexDataSourceItem) {
        self.modelToItem = modelToItem
        
        super.init(modelsPublisher: modelsPublisher)
        
        let toSections = itemsToSection >>> arrayOfSingleObject
        let modelsToItems = modelToItem -*> map
        let transform = modelsToItems >>> toSections
        self.sectionsPublisher = self.$models.map(transform).eraseToAnyPublisher()
    }
}

public func arrayOfSingleObject<T>(object: T) -> [T] {
    return [object]
}
