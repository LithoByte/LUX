//
//  UIViewController+DismissKeyboard.swift
//  LUX
//
//  Created by Elliot Schrock on 4/20/21.
//

import UIKit

public extension UIViewController {
    @objc func dismissKeyboard() { view.endEditing(true) }
    func addTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
public func addTapToDismissKeyboard(_ vc: UIViewController) {
    vc.addTapToDismissKeyboard()
}
