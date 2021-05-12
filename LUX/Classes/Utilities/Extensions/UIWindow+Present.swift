//
//  UIWindow+Present.swift
//  LUX
//
//  Created by Calvin Collins on 5/4/21.
//

import Foundation

public extension UIWindow {
    func present<T>(_ vc: T) where T: UIViewController {
        if let rootViewController = rootViewController {
            if let navVC = rootViewController as? UINavigationController, let visibleVC = navVC.visibleViewController {
                visibleVC.present(vc, animated: true, completion: nil)
            } else if let tabVC = rootViewController as? UITabBarController, let selectedVC = tabVC.selectedViewController {
                selectedVC.present(vc, animated: true, completion: nil)
            } else {
                rootViewController.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func presentClosure() -> (UIViewController) -> Void {
        return { [weak self] vc in
            self?.present(vc)
        }
    }
}
