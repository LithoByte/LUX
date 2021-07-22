//
//  FlexCollectionItems.swift
//  LUX
//
//  Created by Elliot Schrock on 10/20/20.
//

import FlexDataSource
import LithoOperators
import Prelude

open class LUXModelCollectionItem<T, C>: ConcreteFlexCollectionItem<C> where C: UICollectionViewCell {
    open var model: T
    open var configurer: (C) -> Void
    
    public init(_ model: T, _ configurer: @escaping (T, C) -> Void) {
        self.model = model
        self.configurer = model *-> configurer
        super.init(identifier: String(describing: C.self))
    }
    
    override open func configureCell(_ cell: UICollectionViewCell) {
        if let cell = cell as? C {
            configurer(cell)
        }
    }
}

open class LUXTappableModelCollectionItem<T, C>: LUXModelCollectionItem<T, C>, Tappable where C: UICollectionViewCell {
    public var onTap: () -> Void = {}
    
    public init(model: T, configurer: @escaping (T, C) -> Void, tap: @escaping (T) -> Void) {
        self.onTap = voidCurry(model, tap)
        super.init(model, configurer)
    }
}

open class LUXButtonTappableModelCollectionItem<T, C>: LUXTappableModelCollectionItem<T, C> where C: UICollectionViewCell {
    public var onButtonPressed: () -> Void
    
    public init(model: T,
                configurer: @escaping (T, C) -> Void,
                tap: @escaping (T) -> Void,
                buttonPressed: @escaping () -> Void) {
        self.onButtonPressed = buttonPressed
        super.init(model: model, configurer: configurer, tap: tap)
    }
    
    public init(model: T,
                configurer: @escaping (T, C) -> Void,
                tap: @escaping (T) -> Void,
                buttonPressed: @escaping (T) -> Void) {
        self.onButtonPressed = voidCurry(model, buttonPressed)
        super.init(model: model, configurer: configurer, tap: tap)
    }
}

public func modelItem<T, U: UICollectionViewCell>(_ configurer: @escaping (T, U) -> Void) -> (T) -> LUXModelCollectionItem<T, U> {
    return configurer -*> LUXModelCollectionItem.init
}

public func tappableModelItem<T, U: UICollectionViewCell>(_ configurer: @escaping (T, U) -> Void, onTap: @escaping (T) -> Void) -> (T) -> LUXTappableModelCollectionItem<T, U> {
    return (configurer, onTap) -**> LUXTappableModelCollectionItem.init
}
