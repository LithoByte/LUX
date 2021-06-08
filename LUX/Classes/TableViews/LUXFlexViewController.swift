//
//  LUXFlexController.swift
//  LithoUXComponents
//
//  Created by Elliot Schrock on 10/12/19.
//

import UIKit
import fuikit
import Combine
import Slippers
import FunNet
import fuikit

open class LUXFlexViewController<T>: FUIViewController, Refreshable {
    @IBOutlet public var tableView: UITableView?
    open var tableViewDelegate: FUITableViewDelegate? { didSet { didSetTableDelegate() }}
    open var viewModel: T? { didSet { didSetViewModel() }}
    open var refreshableModelManager: (Refreshable & CallManager)? {
        didSet {
            if let call = refreshableModelManager?.call as? CombineNetCall {
                indicatingCall = call
            }
        }
    }
    open var indicatingCall: CombineNetCall? {
        didSet {
            cancelBag.insert(indicatingCall?.responder?.$response.sink { _ in
                self.tableView?.setContentOffset(.zero, animated: true)
                self.tableView?.refreshControl?.endRefreshing()
            })
            cancelBag.insert(indicatingCall?.responder?.$data.sink { _ in
                self.tableView?.setContentOffset(.zero, animated: true)
                self.tableView?.refreshControl?.endRefreshing()
            })
        }
    }
    var cancelBag = Set<AnyCancellable?>()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.tableFooterView = UIView()
        
        configureTableView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    open func didSetViewModel() {
        configureTableView()
    }
    
    open func didSetTableDelegate() {
        configureTableView()
    }
    
    @objc
    open func refresh() {
        if let refresher = refreshableModelManager {
            if let isRefreshing = tableView?.refreshControl?.isRefreshing, !isRefreshing {
                tableView?.refreshControl?.beginRefreshing()
            }
            refresher.refresh()
        }
    }

    open func configureTableView() {
        if let vm = viewModel as? LUXDataSourceProvider {
            vm.flexDataSource.tableView = tableView
            tableView?.dataSource = vm.flexDataSource
        }
        tableView?.delegate = tableViewDelegate
        
        tableView?.refreshControl = UIRefreshControl()
        tableView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}
