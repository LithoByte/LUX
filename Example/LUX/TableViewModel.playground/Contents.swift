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
struct Emperor: Codable { var name: String? }
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
let reignConfigurator: (Reign, LUXDetailTableViewCell) -> Void = { reign, cell in
    cell.textLabel?.text = reign.emperors?.first?.name ?? "<Unknown>"
    cell.detailTextLabel?.text = reignToHouseString(reign)
}

//setup
let vc =  FUITableViewViewController.makeFromXIB()
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

let vm = pageableTableViewModel(call, modelUnwrapper: ^\Cycle.reigns, reignConfigurator) { _ in }

vc.onViewDidLoad = vm.setupOnLoad()

PlaygroundPage.current.liveView = nc
