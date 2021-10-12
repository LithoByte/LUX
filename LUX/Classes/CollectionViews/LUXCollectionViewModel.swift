import UIKit
import fuikit
import Combine
import FunNet
import Slippers
import FlexDataSource
import Prelude
import LithoOperators

open class LUXCollectionViewModel {
    public var cancelBag = Set<AnyCancellable>()
    public var dataSource: UICollectionViewDataSource? { didSet { didSetDataSource() }}
    public var flexDataSource: FlexCollectionDataSource? {
        return dataSource as? FlexCollectionDataSource
    }
    public var collectionDelegate: UICollectionViewDelegate? { didSet { didSetCollectionDelegate() }}
    
    public var collectionView: UICollectionView? { didSet { configureCollectionView() }}
    
    public init() {}
    
    open func didSetDataSource() { configureCollectionView() }
    open func didSetCollectionDelegate() { configureCollectionView() }
    open func configureCollectionView() {
        collectionView?.dataSource = dataSource
        if let ds = dataSource as? FlexCollectionDataSource {
            ds.collectionView = collectionView
        }
        collectionView?.delegate = collectionDelegate
    }
}

open class LUXRefreshableCollectionViewModel: LUXCollectionViewModel, Refreshable {
    public var refresher: Refreshable
    
    public init(_ refresher: Refreshable) {
        self.refresher = refresher
    }
    
    @objc open func refresh() {
        if let isRefreshing = collectionView?.refreshControl?.isRefreshing, !isRefreshing {
            collectionView?.refreshControl?.beginRefreshing()
        }
        refresher.refresh()
    }
    
    @objc open func endRefreshing() {
        collectionView?.refreshControl?.endRefreshing()
    }
    
    open override func configureCollectionView() {
        super.configureCollectionView()
        
        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}
extension LUXRefreshableCollectionViewModel {
    public func setupEndRefreshing(from call: CombineNetCall) {
        call.responder?.$data.sink { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.endRefreshing()
            }
        }.store(in: &cancelBag)
        
        call.responder?.$error.sink { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.endRefreshing()
            }
        }.store(in: &cancelBag)
        
        call.responder?.$serverError.sink { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.endRefreshing()
            }
        }.store(in: &cancelBag)
        
    }
}

open class LUXSegmentedSectionsCollectionViewModel: LUXSegmentedCollectionViewModel {
    public init(_ refresher: Refreshable, dataSourcePub: AnyPublisher<[FlexCollectionDataSource], Never>) {
        super.init(refresher)
        dataSourcePub.sink {
            self.segments = $0
        }.store(in: &cancelBag)
    }
}

open class LUXSectionsCollectionViewModel: LUXRefreshableCollectionViewModel {
    public var sectionsPublisher: AnyPublisher<[FlexCollectionSection], Never>
    
    public init(_ refresher: Refreshable,
                _ sectionsPublisher: AnyPublisher<[FlexCollectionSection], Never>) {
        self.sectionsPublisher = sectionsPublisher
        
        super.init(refresher)
        
        let dataSource = FlexCollectionDataSource()
        cancelBag.insert(self.sectionsPublisher.sink {
            dataSource.sections = $0
            dataSource.collectionView?.reloadData()
        })
        self.dataSource = dataSource
    }
}

open class LUXItemsCollectionViewModel: LUXSectionsCollectionViewModel {
    public init(_ refresher: Refreshable,
                itemsPublisher: AnyPublisher<[FlexCollectionItem], Never>,
                toSections: @escaping ([FlexCollectionItem]) -> [FlexCollectionSection] = collectionItemsToSection >>> arrayOfSingleObject) {
        super.init(refresher, itemsPublisher.map(toSections).eraseToAnyPublisher())
    }
}

public func pageableCollectionViewModel<T, U, C>(_ call: CombineNetCall,
                                     modelUnwrapper: @escaping (T) -> [U],
                                     _ filterItems: @escaping (AnyPublisher<[U], Never>) -> AnyPublisher<[U], Never> = id,
                                     _ configurer: @escaping (U, C) -> Void,
                                     _ onTap: @escaping (U) -> Void)
    -> LUXItemsCollectionViewModel where T: Decodable, U: Decodable, C: UICollectionViewCell {
        let dataPub = call.publisher.$data.eraseToAnyPublisher()
        let modelPub = unwrappedModelPublisher(from: dataPub, modelUnwrapper)
        let pageManager = LUXPageCallModelsManager(call, modelPub)
        let modelsToItems = map(f: modelItem(configurer))
        let itemsPub: AnyPublisher<[FlexCollectionItem], Never> = filterItems(pageManager.$models.dropFirst().eraseToAnyPublisher()).map(modelsToItems).eraseToAnyPublisher()
        let vm = LUXItemsCollectionViewModel(pageManager, itemsPublisher: itemsPub)
        if let ds = vm.dataSource as? FlexCollectionDataSource {
            let delegate = LUXCollectionDelegate()
            delegate.onWillDisplayCell = pageManager.willDisplayFunction()
            delegate.onDidSelectItem = ds.itemTapOnSelect(onTap: (optionalCast >?> ^\FlexModelCollectionItem<U, C>.model) >?> onTap)
            vm.collectionDelegate = delegate
        }
        vm.setupEndRefreshing(from: call)
        return vm
}

public func pageableCollectionViewModel<U, C>(_ call: CombineNetCall,
                                              _ filterItems: @escaping (AnyPublisher<[U], Never>) -> AnyPublisher<[U], Never> = id,
                                              _ configurer: @escaping (U, C) -> Void,
                                              _ onTap: @escaping (U) -> Void)
    -> LUXItemsCollectionViewModel where U: Decodable, C: UICollectionViewCell {
        let dataPub = call.publisher.$data.eraseToAnyPublisher()
        let modelPub: AnyPublisher<[U], Never> = modelPublisher(from: dataPub)
        let pageManager = LUXPageCallModelsManager(call, modelPub)
        let modelsToItems = map(f: modelItem(configurer))
        let itemsPub: AnyPublisher<[FlexCollectionItem], Never> = filterItems(pageManager.$models.dropFirst().eraseToAnyPublisher()).map(modelsToItems).eraseToAnyPublisher()
        let vm = LUXItemsCollectionViewModel(pageManager, itemsPublisher: itemsPub)
        if let ds = vm.dataSource as? FlexCollectionDataSource {
            let delegate = LUXCollectionDelegate()
            delegate.onWillDisplayCell = pageManager.willDisplayFunction()
            delegate.onDidSelectItem = ds.itemTapOnSelect(onTap: (optionalCast >?> ^\FlexModelCollectionItem<U, C>.model) >?> onTap)
            vm.collectionDelegate = delegate
        }
        vm.setupEndRefreshing(from: call)
        return vm
}

public func refreshableCollectionViewModel<T, U, C>(_ call: CombineNetCall,
                                        modelUnwrapper: @escaping (T) -> [U],
                                        _ filterItems: @escaping (AnyPublisher<[U], Never>) -> AnyPublisher<[U], Never> = id,
                                        _ configurer: @escaping (U, C) -> Void,
                                        _ onTap: @escaping (U) -> Void)
    -> LUXItemsCollectionViewModel where T: Decodable, U: Decodable, C: UICollectionViewCell {
        let dataPub = call.publisher.$data.eraseToAnyPublisher()
        let modelPub = unwrappedModelPublisher(from: dataPub, modelUnwrapper)
        let refreshManager = LUXRefreshableNetworkCallManager(call)
        let modelsToItems = map(f: modelItem(configurer))
        let itemsPub: AnyPublisher<[FlexCollectionItem], Never> = filterItems(modelPub.eraseToAnyPublisher()).map(modelsToItems).eraseToAnyPublisher()
        let vm = LUXItemsCollectionViewModel(refreshManager, itemsPublisher: itemsPub)
        if let ds = vm.dataSource as? FlexCollectionDataSource {
            let delegate = LUXCollectionDelegate()
            delegate.onDidSelectItem = ds.itemTapOnSelect(onTap: (optionalCast >?> ^\FlexModelCollectionItem<U, C>.model) >?> onTap)
            vm.collectionDelegate = delegate
        }
        vm.setupEndRefreshing(from: call)
        return vm
}

public func refreshableCollectionViewModel<U, C>(_ call: CombineNetCall,
                                                 _ filterItems: @escaping (AnyPublisher<[U], Never>) -> AnyPublisher<[U], Never> = id,
                                                 _ configurer: @escaping (U, C) -> Void,
                                                 _ onTap: @escaping (U) -> Void)
    -> LUXItemsCollectionViewModel where U: Decodable, C: UICollectionViewCell {
        let dataPub = call.publisher.$data.eraseToAnyPublisher()
        let modelPub: AnyPublisher<[U], Never> = modelPublisher(from: dataPub)
        let refreshManager = LUXRefreshableNetworkCallManager(call)
        let modelsToItems: ([U]) -> [FlexModelCollectionItem<U, C>] = map(f: modelItem(configurer))
        let itemsPub: AnyPublisher<[FlexCollectionItem], Never> = filterItems(modelPub.eraseToAnyPublisher()).map(modelsToItems).eraseToAnyPublisher()
        let vm = LUXItemsCollectionViewModel(refreshManager, itemsPublisher: itemsPub)
        if let ds = vm.dataSource as? FlexCollectionDataSource {
            let delegate = LUXCollectionDelegate()
            delegate.onDidSelectItem = ds.itemTapOnSelect(onTap: (optionalCast >?> ^\FlexModelCollectionItem<U, C>.model) >?> onTap)
            vm.collectionDelegate = delegate
        }
        vm.setupEndRefreshing(from: call)
        return vm
}
