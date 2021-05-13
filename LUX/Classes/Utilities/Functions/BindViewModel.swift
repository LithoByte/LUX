//
//  BindViewModel.swift
//  LUX
//
//  Created by Calvin Collins on 4/15/21.
//

import Foundation
import Combine
import LithoOperators
import Prelude

public func bindButtonEnabledToPublisher(_ button: UIButton, publisher: AnyPublisher<Bool, Never>, cancelBag: inout Set<AnyCancellable>){
    publisher.sink{ button.isEnabled = $0 }.store(in: &cancelBag)
}

public func bindActivityIndicatorVisibleToPublisher(_ activity: UIActivityIndicatorView, publisher: AnyPublisher<Bool, Never>, cancelBag: inout Set<AnyCancellable>) {
    publisher.sink{ activity.isHidden = !$0 }.store(in: &cancelBag)
}

extension Publisher where Output == Bool, Failure == Never {
    public func bind<T>(to keyPath: WritableKeyPath<T, Bool>, on value: T, storingIn cancelBag: inout Set<AnyCancellable>) {
        self.sink(receiveValue: value >|> setter(keyPath)).store(in: &cancelBag)
    }
}
