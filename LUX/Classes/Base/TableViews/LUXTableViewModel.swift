//
//  LUXTableViewModel.swift
//  LUX
//
//  Created by Elliot Schrock on 11/14/20.
//

import FlexDataSource
import Slippers
import Combine

open class LUXTableViewModel {
    open var dataSource: UITableViewDataSource? { didSet { didSetDataSource() }}
    open var tableDelegate: UITableViewDelegate? { didSet { didSetTableDelegate() }}
    
    public var tableView: UITableView? { didSet { configureTableView() }}
    
    public init() {}
    
    open func didSetDataSource() { configureTableView() }
    open func didSetTableDelegate() { configureTableView() }
    open func configureTableView() {
        tableView?.dataSource = dataSource
        if let ds = dataSource as? FlexDataSource {
            ds.tableView = tableView
        }
        tableView?.delegate = tableDelegate
    }
}
