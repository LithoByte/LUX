//
//  CombineNetCall+Publishers.swift
//  LUX
//
//  Created by Calvin Collins on 10/18/21.
//

import Foundation
import FunNet
import Combine

@available(iOS 13.0, *) extension CombineNetCall {
    public func modelPublisher<T: Codable>() -> AnyPublisher<T, Never> {
        return LUX.modelPublisher(from: publisher.$data.eraseToAnyPublisher())
    }
    public func unwrappedModelPublisher<T: Codable, U: Codable>(unwrapper: @escaping (T) -> U?) -> AnyPublisher<U?, Never> {
        return self.modelPublisher().map(unwrapper).eraseToAnyPublisher()
    }
}
