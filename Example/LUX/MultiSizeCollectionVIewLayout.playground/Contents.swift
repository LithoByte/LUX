import UIKit
import PlaygroundSupport
import LUX
import FunNet
import Slippers
import Combine
import Prelude
import FlexDataSource
import LithoOperators
import PlaygroundVCHelpers
import fuikit

NSSetUncaughtExceptionHandler { exception in
    print("💥 Exception thrown: \(exception)")
}

//Models
enum House: String, Codable, CaseIterable {
    case phoenix, dragon, lyorn, tiassa, hawk, dzur, issola, tsalmoth, vallista, jhereg, iorich, chreotha, yendi, orca, teckla, jhegaala, athyra
}
struct Emperor: Codable {
    var name: String?
    var imageUrlString: String? = "https://preview.redd.it/e6c2zqbu9gf51.jpg?width=500&format=pjpg&auto=webp&s=9c1e6dcf6d163ae036d534fc315a190223e77ed8"
}
struct Reign: Codable {
    var id: Int
    var house: House
    var emperors: [Emperor]?
}
struct Cycle: Codable {
    var ordinal: Int?
    var reigns = [Reign]()
}
let reigns = [
    Reign(id: 188, house: .phoenix, emperors: []),
    Reign(id: 189, house: .dragon, emperors: [Emperor(name: "Norathar I")]),
    Reign(id: 190, house: .lyorn, emperors: [Emperor(name: "Cuorfor II")]),
    Reign(id: 191, house: .tiassa),
    Reign(id: 192, house: .hawk, emperors: []),
    Reign(id: 193, house: .dzur),
    Reign(id: 194, house: .issola, emperors: [Emperor(name: "Juzai XI")]),
    Reign(id: 195, house: .tsalmoth, emperors: [Emperor(name: "Faarith III")]),
    Reign(id: 196, house: .vallista, emperors: [Emperor(name: "Fecila III")]),
    Reign(id: 197, house: .jhereg),
    Reign(id: 198, house: .iorich, emperors: [Emperor(name: "Synna IV")]),
    Reign(id: 199, house: .chreotha),
    Reign(id: 200, house: .yendi),
    Reign(id: 201, house: .orca),
    Reign(id: 202, house: .teckla, emperors: [Emperor(name: "Kiva IV")]),
    Reign(id: 203, house: .jhegaala),
    Reign(id: 204, house: .athyra)
]
let eleventhCycle = Cycle(ordinal: 11, reigns: reigns)

//model manipulation
let capitalizeFirstLetter: (String) -> String = { $0.prefix(1).uppercased() + $0.lowercased().dropFirst() }
let reignToHouseString: (Reign) -> String = ^\.house >>> String.init(describing:) >>> capitalizeFirstLetter

//linking models to views
let reignConfigurator: (Reign, LUXStandardCollectionViewCell) -> Void = { reign, cell in
    defaultCellStyle(cell)
    cell.titleLabel?.text = reign.emperors?.first?.name ?? "<Unknown>"
    cell.detailsLabel?.text = reignToHouseString(reign)
    if let imageUrlString = reign.emperors?.first?.imageUrlString {
        cell.cellImageView.sd_setImage(with: URL(string: imageUrlString), completed: nil)
    }
}

//setup
let vc =  LUXSearchCollectionViewController<Reign>.makeFromXIB(name: "LUXSearchCollectionViewController", bundle: Bundle(for: LUXSearchCollectionViewController<Reign>.self))
let nc = UINavigationController(rootViewController: vc)

let call = CombineNetCall(configuration: ServerConfiguration(host: "lithobyte.co", apiRoute: "api/v1"), Endpoint())
//just for stubbing purposes
call.firingFunc = { call in
    let page: Int = call.endpoint.getParams["page"] as! Int
    let per: Int = call.endpoint.getParams["count"] as! Int
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
        DispatchQueue.main.async {
            call.publisher.response = nil
            call.publisher.data = JsonProvider.encode(Cycle(ordinal: 11, reigns: reigns.page(number: page - 1, per: per)))
        }
    }
}

let cycleSignal: AnyPublisher<Cycle, Never> = modelPublisher(from: call.publisher.$data.eraseToAnyPublisher())
let cancel = cycleSignal.sink { vc.title = "\($0.ordinal ?? 0)th Cycle" }

let searcher = LUXSearcher<Reign>(reignToHouseString, .allMatchNilAndEmpty, .prefix)
vc.searchViewModel?.onIncrementalSearch = { text in
    searcher.updateIncrementalSearch(text: text)
}

let vm: LUXItemsCollectionViewModel = pageableCollectionViewModel(call, modelUnwrapper: ^\Cycle.reigns, searcher.filteredIncrementalPublisher(from:), reignConfigurator) { _ in }

let layout = LUXMultiSizeCollectionViewLayout()
layout.cellAspectRatio = CGSize(width: 200, height: 300)

let setupView: (LUXSearchCollectionViewController<Reign>) -> Void = { (searchVC: LUXSearchCollectionViewController<Reign>) in
    vm.collectionView = searchVC.collectionView
    vm.collectionView?.collectionViewLayout = layout
    vm.refresh()
}
vc.onViewDidLoad = ~>setupView
vc.collectionViewModel = vm

PlaygroundPage.current.liveView = nc
