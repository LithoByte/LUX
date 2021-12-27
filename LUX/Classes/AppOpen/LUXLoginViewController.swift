//
//  LUXLoginViewController.swift
//  ThryvUXComponents
//
//  Created by Elliot Schrock on 2/10/18.
//

import UIKit
import fuikit
import Combine
import LithoOperators
import LithoUtils

open class LUXLoginViewController: FPUIViewController, CanIndicateActivity {
    @IBOutlet open weak var backgroundImageView: UIImageView!
    @IBOutlet open weak var logoImageView: UIImageView?
    @IBOutlet open weak var logoHeight: NSLayoutConstraint!
    @IBOutlet open weak var usernameTextField: UITextField?
    @IBOutlet open weak var passwordTextField: UITextField?
    @IBOutlet open weak var loginButton: UIButton?
    @IBOutlet open weak var loginHeight: NSLayoutConstraint!
    @IBOutlet open weak var signUpButton: UIButton?
    @IBOutlet open weak var forgotPasswordButton: UIButton?
    @IBOutlet open weak var legalButton: UIButton?
    @IBOutlet open weak var activityIndicatorView: UIActivityIndicatorView?
    
    public var cancelBag = Set<AnyCancellable>()
    open var loginViewModel: LUXLoginProtocol?
    open var onSignUpPressed: ((LUXLoginViewController) -> Void)?
    open var onForgotPasswordPressed: ((LUXLoginViewController) -> Void)?
    open var onLegalPressed: ((LUXLoginViewController) -> Void)?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField?.delegate = loginViewModel?.inputs.usernameDelegate
        passwordTextField?.delegate = loginViewModel?.inputs.passwordDelegate
        loginViewModel?.outputs.submitButtonEnabledPublisher.sink { enabled in
            self.loginButton?.isEnabled = enabled
        }.store(in: &cancelBag)
        loginViewModel?.inputs.viewDidLoad()
        if let textField = passwordTextField {
            setRightView(textField, showPasswordButton(target: self, selector: #selector(rightViewPressed)))
            loginViewModel?.outputs.showButtonPressedPublisher.sink(receiveValue: textField *> (toggle(\.isSecureTextEntry) <> ((^\.rightView) >?> ~>toggle(\UIButton.isSelected)))).store(in: &cancelBag)
        }
        if let activityIndicatorView = activityIndicatorView, let vm = loginViewModel{
            bindActivityIndicatorVisibleToPublisher(activityIndicatorView, publisher: vm.outputs.activityIndicatorVisiblePublisher, cancelBag: &cancelBag)
        }
    }
    
    @IBAction @objc open func usernameChanged() {
        loginViewModel?.inputs.usernameChanged(username: usernameTextField!.text)
    }
    
    @IBAction @objc open func passwordChanged() {
        loginViewModel?.inputs.passwordChanged(password: passwordTextField!.text)
    }
    
    @IBAction @objc open func loginButtonPressed() {
        loginViewModel?.inputs.submitButtonPressed()
    }
    
    @objc open func rightViewPressed() {
        loginViewModel?.inputs.rightViewPressed()
    }
    
    @IBAction @objc open func signUpPressed() { onSignUpPressed?(self) }
    @IBAction @objc open func forgotPasswordPressed() { onForgotPasswordPressed?(self) }
    @IBAction @objc open func termsPressed() { onLegalPressed?(self) }
}

public func showPasswordButton(target: Any?, selector: Selector) -> UIButton {
    return UIButton(type: .custom).configure {
        $0.setImage(UIImage(systemName: "eye"), for: .normal)
        $0.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        $0.addTarget(target, action: selector, for: .touchUpInside)
    }
}
