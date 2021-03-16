//
//  LUXLoginViewController.swift
//  ThryvUXComponents
//
//  Created by Elliot Schrock on 2/10/18.
//

import UIKit
import fuikit
import Combine

open class LUXLoginViewController: FUIViewController {
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
    @IBOutlet open weak var spinner: UIActivityIndicatorView?
    
    public var cancelBag = Set<AnyCancellable>()
    open var loginViewModel: LUXLoginProtocol?
    open var onSignUpPressed: ((LUXLoginViewController) -> Void)?
    open var onForgotPasswordPressed: ((LUXLoginViewController) -> Void)?
    open var onLegalPressed: ((LUXLoginViewController) -> Void)?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        loginViewModel?.outputs.submitButtonEnabledPublisher.sink { enabled in
            self.loginButton?.isEnabled = enabled
        }.store(in: &cancelBag)
        loginViewModel?.outputs.activityIndicatorVisiblePublisher.sink { (visible) in
            self.spinner?.isHidden = !visible
        }.store(in: &cancelBag)
        loginViewModel?.inputs.viewDidLoad()
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
    
    @IBAction @objc open func signUpPressed() { onSignUpPressed?(self) }
    @IBAction @objc open func forgotPasswordPressed() { onForgotPasswordPressed?(self) }
    @IBAction @objc open func termsPressed() { onLegalPressed?(self) }
}
