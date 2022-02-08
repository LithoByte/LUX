//
//  LUXSelectionModelItem.swift
//  LUX
//
//  Created by Elliot on 1/10/22.
//

import FlexDataSource
import Prelude
import LithoOperators
import UIKit

open class LUXSelectionModelItem<T, U: UITableViewCell, V>: FlexGestureModelItem<[T], U> where T: Equatable, V: UIView {
    open var viewsFromCell: (U) -> [V]?
    open var viewSelector: (T, V) -> Void
    open var viewDeselector: (T, V) -> Void
    
    public var selectedModels: [T]?
    
    @Published public var selectionViewModel: LUXSelectionViewModel<T, V>?
    
    public init(_ models: [T], _ selectedModels: [T]?, _ configurer: @escaping ([T], U) -> Void, viewsFromCell: @escaping (U) -> [V]?, viewSelector: @escaping (T, V) -> Void, viewDeselector: @escaping (T, V) -> Void) {
        self.viewsFromCell = viewsFromCell
        self.viewSelector = viewSelector
        self.viewDeselector = viewDeselector
        self.selectedModels = selectedModels
        super.init(models, configurer)
    }
    
    open override func configureCell(_ cell: UITableViewCell) {
        super.configureCell(cell)
        if let selectionCell = cell as? U, let viewArray = viewsFromCell(selectionCell) {
            let vm = LUXSelectionViewModel(models: model, initialSelectedModels: selectedModels, views: viewArray, viewSelector: viewSelector, viewDeselector: viewDeselector)
            if selectedModels?.count ?? 0 > 0 {
                vm.modelViewPairs.filter { selectedModels?.contains($0.0) ?? false }.forEach(viewSelector)
            }
            viewArray.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: vm, action: #selector(vm.toggleGestured))) }
            
            selectionViewModel = vm
        }
    }
}
