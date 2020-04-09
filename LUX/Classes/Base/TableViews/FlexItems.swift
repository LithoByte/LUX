//
//  FlexItems.swift
//  LUX
//
//  Created by Elliot Schrock on 4/1/20.
//

import FlexDataSource
import LithoOperators
import Prelude

open class LUXModelItem<T, C>: ConcreteFlexDataSourceItem<C> where C: UITableViewCell {
    open var model: T
    open var configurer: (C) -> Void
    
    public init(_ model: T, _ configurer: @escaping (T, C) -> Void) {
        self.model = model
        self.configurer = model >|> configurer
        super.init(identifier: String(describing: C.self))
    }
    
    override open func configureCell(_ cell: UITableViewCell) {
        if let cell = cell as? C {
            configurer(cell)
        }
    }
}

open class LUXTappableModelItem<T, C>: LUXModelItem<T, C>, Tappable where C: UITableViewCell {
    public var onTap: () -> Void = {}
    
    public init(model: T, configurer: @escaping (T, C) -> Void, tap: @escaping (T) -> Void) {
        self.onTap = voidCurry(model, tap)
        super.init(model, configurer)
    }
}
