//
//  NetworkErrorHandler.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/12/19.
//

import UIKit

public protocol ErrorMessage {
    var title: String { get }
    var message: String { get }
    var forCode: Int { get }
}

public protocol NetworkErrorHandler {
    func handleError(_ error: NSError) -> UIViewController
}

public class VerboseLoginErrorHandler: VerboseNetworkErrorHandler {
    public override init() {
        super.init()
        errorMessages.append(DefaultEmailPasswordLoginErrorMessage())
    }
}

public class VerboseNetworkErrorHandler: NetworkErrorHandler {
    var errorMessages: [ErrorMessage] = [DefaultServerUnavailableErrorMessage(), DefaultServerIssueErrorMessage(), DefaultOfflineErrorMessage()]
    var errorMessageMap: [Int: ErrorMessage] {
        get {
            var map = [Int: ErrorMessage]()
            for message in errorMessages {
                map[message.forCode] = message
            }
            return map
        }
    }
    
    public init() {}
    
    open func handleError(_ error: NSError) -> UIViewController {
        print(error)
        if let message = errorMessageMap[error.code] {
            return alert(message.title, message.message)
        } else {
            return alert("Error \(error.code)", "Description: \(error.debugDescription)\nInfo: \(error.userInfo)")
        }
    }
    
    open func notify(title: String, message: String) {
        alert(title, message).show(animated: true)
    }
    
    func alert(_ title: String, _ message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        return alert
    }
}

public struct DefaultServerUnavailableErrorMessage: ErrorMessage {
    public let title: String = "Error"
    public let message: String = "The server is unavailable! Try again in a bit. If this keeps happening, please let us know!"
    public let forCode: Int = 503
    
    public init() {}
}

public struct DefaultServerIssueErrorMessage: ErrorMessage {
    public let title: String = "Error"
    public let message: String = "Looks like we're having a problem. Please contact us to let us know."
    public let forCode: Int = 500
    
    public init() {}
}

public struct DefaultOfflineErrorMessage: ErrorMessage {
    public let title: String = "Hmmm..."
    public let message: String = "Looks like you're offline. Try reconnecting to the internet."
    public let forCode: Int = -1009
    
    public init() {}
}

public struct DefaultUsernamePasswordLoginErrorMessage: ErrorMessage {
    public let title: String = "Oops!"
    public let message: String = "Looks like your username or password is incorrect."
    public let forCode: Int = 401
    
    public init() {}
}

public struct DefaultEmailPasswordLoginErrorMessage: ErrorMessage {
    public let title: String = "Oops!"
    public let message: String = "Looks like your email or password is incorrect. Try again!"
    public let forCode: Int = 401
    
    public init() {}
}

extension UIAlertController {
    public func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindow.Level.alert
        
        if let rootViewController = window.rootViewController {
            window.makeKeyAndVisible()
            
            rootViewController.present(self, animated: flag, completion: completion)
        }
    }
}
