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

public func dismissableAlert(title: String?, message: String?, actionTitle: String, onDismiss: @escaping () -> Void) -> UIAlertController {
    let alert = alertController(title: title, message: message)
    let action = UIAlertAction(title: actionTitle, style: .default, handler: ignoreArg(onDismiss *> alert.dismissClosure()))
    alert.addAction(action)
    return alert
}

public func dismissableAlert(title: String?, message: String?, actionTitle: String) -> UIAlertController {
    let alert = alertController(title: title, message: message)
    let action = UIAlertAction(title: actionTitle, style: .default, handler: ignoreArg(nil *> alert.dismissClosure()))
    alert.addAction(action)
    return alert
}

public func cancellableAlert(title: String, message: String, actionTitle: String, onDismiss: @escaping (() -> Void)) -> UIAlertController {
    let alert = alertController(title: title, message: message)
    let action = UIAlertAction(title: actionTitle, style: .cancel, handler: ignoreArg(onDismiss *> alert.dismissClosure()))
    alert.addAction(action)
    return alert
}

public func cancellableAlert(title: String, message: String, actionTitle: String) -> UIAlertController {
    let alert = alertController(title: title, message: message)
    let action = UIAlertAction(title: actionTitle, style: .cancel, handler: ignoreArg(nil *> alert.dismissClosure()))
    alert.addAction(action)
    return alert
}


