//
//  LUXLandingViewController.swift
//  LUX
//
//  Created by Elliot Schrock on 4/2/20.
//

import UIKit
import fuikit

open class LUXLandingViewController: FPUIViewController {
    @IBOutlet open weak var backgroundImageView: UIImageView!
    @IBOutlet open weak var logoImageView: UIImageView!
    @IBOutlet open weak var loginButton: UIButton!
    @IBOutlet open weak var signUpButton: UIButton!
    
    public var onLoginPressed: (LUXLandingViewController) -> Void = { _ in }
    public var onSignUpPressed: (LUXLandingViewController) -> Void = { _ in }
    
    @IBAction @objc open func loginPressed() { onLoginPressed(self) }
    @IBAction @objc open func signUpPressed() { onSignUpPressed(self) }
}
