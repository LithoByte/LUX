//
//  Alerts.swift
//  LUX
//
//  Created by Calvin Collins on 5/4/21.
//

import Foundation
import LithoOperators
import Prelude

public func alertController(title: String?, message: String?) -> UIAlertController {
    let alert = UIAlertController()
    alert.title = title
    alert.message = message
    return alert
}

public func dismissableAlert(title: String?, message: String?, action: String) -> UIAlertController {
    let alert = alertController(title: title, message: message)
    let action = UIAlertAction(title: action, style: .default, handler: ignoreArg({ alert.dismissAnimated(nil) }))
    alert.addAction(action)
    return alert
}

public func cancellableAlert(title: String, message: String, action: String) -> UIAlertController {
    let alert = alertController(title: title, message: message)
    let action = UIAlertAction(title: action, style: .cancel, handler: ignoreArg({ alert.dismissAnimated(nil) }))
    alert.addAction(action)
    return alert
}


