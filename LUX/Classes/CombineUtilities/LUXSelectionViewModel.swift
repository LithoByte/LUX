//
//  LUXSelectionViewModel.swift
//  LUX
//
//  Created by Elliot on 1/4/22.
//

import UIKit
import LithoOperators
import Prelude
import Combine

open class LUXSelectionViewModel<Model, ViewType> where Model: Equatable, ViewType: UIView {
    open var isSingleSelect = true
    open var modelViewPairs: [(Model, ViewType)] = []
    open var models: [Model] = []
    open var views: [ViewType] = []
    
    @Published open var selectedModels: [Model] = []
    
    open var viewSelector: (Model, ViewType) -> Void
    open var viewDeselector: (Model, ViewType) -> Void
    
    open lazy var getSelectedIndex: (UIView) -> Int? = { [weak self] view in self?.modelViewPairs.firstIndex(where: ignoreFirstArg(f: view -*> (==))) }
    
    public init(models: [Model],
                initialSelectedModels: [Model]?,
                views: [ViewType],
                viewSelector: @escaping (Model, ViewType) -> Void,
                viewDeselector: @escaping (Model, ViewType) -> Void) {
        self.models = models
        if let initialSelectedModels = initialSelectedModels {
            self.selectedModels = initialSelectedModels
        }
        self.views = views
        self.viewSelector = viewSelector
        self.viewDeselector = viewDeselector
        
        for i in 0..<models.count {
            modelViewPairs.append((models[i], views[i]))
        }
    }
    
    @objc open func toggleView(_ view: UIView) {
        if let selectedIndex = getSelectedIndex(view) {
            toggleIndex(selectedIndex)
        }
    }
    
    @objc open func toggleGestured(_ gesture: UIGestureRecognizer) {
        if let view = gesture.view, let selectedIndex = getSelectedIndex(view) {
            toggleIndex(selectedIndex)
        }
    }
    
    open func toggleIndex(_ index: Int) {
        if !selectedModels.contains(models[index]) {
            if isSingleSelect {
                selectedModels.removeAll()
                modelViewPairs.forEach(viewDeselector)
            }
            
            modelViewPairs[index] |> viewSelector
            selectedModels.append(models[index])
        } else {
            modelViewPairs[index] |> viewDeselector
            
            selectedModels = selectedModels.filter(isEqualTo(models[index]) >>> (!))
        }
    }
}
