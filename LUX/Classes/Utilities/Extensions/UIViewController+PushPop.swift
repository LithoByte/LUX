//
//  UIViewController+PushPop.swift
//  LUX
//
//  Created by Elliot Schrock on 12/23/19.
//

import UIKit

public extension UIViewController {
    func pushClosure() -> (UIViewController) -> Void {
        return { [weak self] vc in
            self?.pushAnimated(vc)
        }
    }
    
    func emptyBackClosure() -> (UIViewController) -> Void {
        return { [weak self] vc in
            self?.emptyBackButtonPush(vc)
        }
    }
    
    func popClosure() -> () -> Void {
        return { [weak self] in
            self?.popAnimated()
        }
    }
    
    func presentClosure() -> (UIViewController) -> Void {
        return { [weak self] vc in
            self?.presentAnimated(vc)
        }
    }
    
    func dismissClosure() -> ((() -> Void)?) -> Void {
        return { [weak self] completion in
            self?.dismissAnimated(completion)
        }
    }
    
    func tabPushClosure() -> (UIViewController) -> Void {
        return { [weak self] vc in
            self?.tabPushAnimated(vc)
        }
    }
    
    func tabPopClosure() -> () -> Void {
        return { [weak self] in
            self?.tabPopAnimated()
        }
    }
    
    func tabPresentClosure() -> (UIViewController) -> Void {
        return { [weak self] vc in
            self?.tabPresentAnimated(vc)
        }
    }
    
    func showClosure() -> (UIViewController) -> Void {
        return { [weak self] vc in
            self?.show(vc, sender: self)
        }
    }
}

public extension UIViewController {
    func pushAnimated(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func emptyBackButtonPush(_ vc: UIViewController) {
        let barButton = UIBarButtonItem()
        barButton.title = " "
        navigationItem.backBarButtonItem = barButton
        
        pushAnimated(vc)
    }
    
    func popAnimated() {
        navigationController?.popViewController(animated: true)
    }
    
    func presentAnimated(_ vc: UIViewController, completion: @escaping (() -> Void)) {
        present(vc, animated: true, completion: completion)
    }
    
    func presentAnimated(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
    
    func dismissAnimated(_ completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func tabContainer() -> UITabBarController? {
        return tabBarController
    }
    
    func tabPushAnimated(_ vc: UIViewController) {
        tabBarController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tabPopAnimated() {
        tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    func tabPresentAnimated(_ vc: UIViewController) {
        tabBarController?.present(vc, animated: true, completion: nil)
    }
    
    func tabDismissAnimated(_ vc: UIViewController, completion: @escaping (() -> Void)) {
        vc.dismiss(animated: true, completion: completion)
    }
    
    func tabDismissAnimated(_ vc: UIViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
}

public func pushAnimated<T>(_ pusher: T, _ pushee: UIViewController) where T: UIViewController {
    pusher.pushAnimated(pushee)
}

public func emptyBackButtonPush<T>(_ pusher: T, _ pushee: UIViewController) where T: UIViewController {
    pusher.emptyBackButtonPush(pushee)
}

public func popAnimated<T>(_ vc: T) where T: UIViewController {
    vc.popAnimated()
}

public func presentAnimated<T>(_ presenter: T, _ vc: UIViewController, completion: @escaping (() -> Void)) where T: UIViewController {
    presenter.present(vc, animated: true, completion: completion)
}

public func presentAnimated<T>(_ presenter: T, _ vc: UIViewController) where T: UIViewController {
    presenter.present(vc, animated: true, completion: nil)
}

public func dismissAnimated<T>(_ vc: T, completion: @escaping (() -> Void)) where T: UIViewController{
    vc.dismissAnimated(completion)
}

public func dismissAnimated<T>(_ vc: T) where T: UIViewController {
    vc.dismissAnimated(nil)
}

public func tabPushAnimated<T>(_ pusher: T, _ vc: UIViewController) where T: UIViewController {
    pusher.tabBarController?.navigationController?.pushViewController(vc, animated: true)
}

public func tabPopAnimated<T>(_ vc: T) where T: UIViewController {
    vc.tabBarController?.navigationController?.popViewController(animated: true)
}

public func tabPresentAnimated<T>(_ presenter: T, _ vc: UIViewController) where T: UIViewController {
    presenter.tabBarController?.present(vc, animated: true, completion: nil)
}
