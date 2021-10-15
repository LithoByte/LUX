import UIKit
import PlaygroundSupport
import LUX
import LithoOperators
import Prelude

let styleVC: (LUXLoginViewController) -> Void = { loginVC in
    print(loginVC.view)
    loginVC.forgotPasswordButton?.isHidden = true
}

let vc = LUXLoginViewController(nibName: "LUXLoginViewController", bundle: Bundle(for: LUXLoginViewController.self))
vc.onViewDidLoad = optionalCast >>> (styleVC -*> ifExecute)

PlaygroundPage.current.liveView = vc
PlaygroundPage.current.needsIndefiniteExecution = true
