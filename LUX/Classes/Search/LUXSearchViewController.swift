//
//  LUXSearchViewController.swift
//  LithoUXComponents
//
//  Created by Elliot Schrock on 10/17/19.
//

import UIKit
import fuikit
import LithoOperators
import Prelude

open class LUXSearchViewController<T, U>: LUXFlexViewController<T> {
    @IBOutlet open weak var searchBar: UISearchBar?
    @IBOutlet open weak var searchTopConstraint: NSLayoutConstraint?
    
    open var lastScreenYForAnimation: CGFloat?
    
    open var searchViewModel: LUXSearchViewModel<U>? = LUXSearchViewModel<U>()
    open var shouldRefresh = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let y = lastScreenYForAnimation {
            searchTopConstraint?.constant = y
            tableView?.alpha = 0
        }
        
        searchBar?.delegate = searchViewModel?.searchBarDelegate
        
        addTapToDismissKeyboard()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldRefresh = (searchViewModel?.savedSearch == nil || searchViewModel?.savedSearch == "")
        if let searchText = searchViewModel?.savedSearch {
            searchBar?.text = searchText
            searchBar?.resignFirstResponder()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = self.lastScreenYForAnimation {
            UIView.animate(withDuration: 0.25, animations: {
                self.searchTopConstraint?.constant = 0
                self.tableView?.alpha = 1
            }) { _ in
                self.searchBar?.becomeFirstResponder()
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchViewModel?.savedSearch = searchBar?.text
    }
    
    open override func refresh() {
        if shouldRefresh {
            super.refresh()
            searchBar?.resignFirstResponder()
            searchBar?.text = ""
        } else {
            shouldRefresh = true
        }
    }
    
    open func clearSearchBar() {
        searchBar?.text = ""
    }
}
