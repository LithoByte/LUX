//
//  LUXForgotPasswordViewController.swift
//  LithoUXComponents
//
//  Created by Elliot Schrock on 10/31/19.
//

import UIKit
import fuikit

open class LUXForgotPasswordViewController: FPUIViewController {
    @IBOutlet open weak var identifierTextField: UITextField?
    @IBOutlet open weak var resetButton: UIButton?
    
    public var onSubmit: ((String?) -> Void)?

    @IBAction open func resetPressed() {
        onSubmit?(identifierTextField?.text)
    }
}
