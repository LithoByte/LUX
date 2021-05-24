//
//  LUXResetPasswordViewController.swift
//  LithoUXComponents
//
//  Created by Elliot Schrock on 10/31/19.
//

import UIKit
import fuikit
import LithoOperators
import LithoUtils

public let disableSubmitButton: (LUXResetPasswordViewController) -> Void = ^\.submitButton >?> set(\.isEnabled, false)
public let enableSubmitButton: (LUXResetPasswordViewController) -> Void = ^\.submitButton >?> set(\.isEnabled, true)
public let startActivity: (CanIndicateActivity) -> Void = { $0.indicateActivity() }
public let stopActivity: (CanIndicateActivity) -> Void = { $0.activityFinished() }

open class LUXResetPasswordViewController: FUIViewController {
    @IBOutlet open weak var newPasswordTextField: UITextField?
    @IBOutlet open weak var confirmPasswordTextField: UITextField?
    @IBOutlet open weak var submitButton: UIButton?
    @IBOutlet open weak var activityIndicatorView: UIActivityIndicatorView?
    
    public var onSubmit: ((LUXResetPasswordViewController) -> Void)?

    @IBAction open func submitPressed() {
        onSubmit?(self)
    }
}
extension LUXResetPasswordViewController: CanIndicateActivity {}
