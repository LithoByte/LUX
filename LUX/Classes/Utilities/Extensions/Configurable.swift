//
//  Configurable.swift
//  LUX
//
//  Created by Elliot Schrock on 12/23/19.
//

import Foundation

public protocol Configurable {}
public extension Configurable {
    /// Makes it available to set properties with closures just after initializing.
    ///
    ///     let frame = UIView().configure {
    ///       $0.backgroundColor = .red
    ///     }
    func configure(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
    
    func configure(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}
extension NSObject: Configurable {}
