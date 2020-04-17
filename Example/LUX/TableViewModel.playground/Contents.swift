import UIKit
import PlaygroundSupport
@testable import LUX
@testable import FunNet
import Combine
import Prelude
import FlexDataSource
import LithoOperators
import PlaygroundVCHelpers

//Models
enum House: String, Codable, CaseIterable {
    case phoenix, dragon, lyorn, tiassa, hawk, dzur, issola, tsalmoth, vallista, jhereg, iorich, chreotha, yendi, orca, teckla, jhegaala, athyra
}
struct Emperor: Codable { var name: String? }
struct Reign: Codable {
    var house: House
    var emperors: [Emperor]?
}
struct Cycle: Codable {
    var ordinal: Int?
    var reigns = [Reign]()
}

let json = """
{ "ordinal": 11,
  "reigns":[{"house":"phoenix", "emperors": []},
            {"house":"dragon", "emperors": [{"name":"Norathar I"}]},
            {"house":"lyorn", "emperors": [{"name":"Cuorfor II"}]},
            {"house":"tiassa"},
            {"house":"hawk", "emperors": []},
            {"house":"dzur"},
            {"house":"issola", "emperors": [{"name":"Juzai XI"}]},
            {"house":"tsalmoth", "emperors": [{"name":"Faarith III"}]},
            {"house":"vallista", "emperors": [{"name":"Fecila III"}]},
            {"house":"jhereg"},
            {"house":"iorich", "emperors": [{"name":"Synna IV"}]},
            {"house":"chreotha"},
            {"house":"yendi"},
            {"house":"orca"},
            {"house":"teckla", "emperors": [{"name":"Kiva IV"}]},
            {"house":"jhegaala"},
            {"house":"athyra"}]
}
"""

//model manipulation
let capitalizeFirstLetter: (String) -> String = { $0.prefix(1).uppercased() + $0.lowercased().dropFirst() }
let houseToString: (House) -> String = { String(describing: $0) }
let reignToHouseString: (Reign) -> String = get(\Reign.house) >>> houseToString >>> capitalizeFirstLetter

//table view cell subclass
class DetailTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//linking models to views
let reignConfigurator: (Reign, DetailTableViewCell) -> Void = { reign, cell in
    cell.textLabel?.text = reign.emperors?.first?.name ?? "<Unknown>"
    cell.detailTextLabel?.text = reignToHouseString(reign)
}

//setup
let vc = LUXFunctionalTableViewController.makeFromXIB()
let nc = UINavigationController(rootViewController: vc)

let call = CombineNetCall(configuration: ServerConfiguration(host: "lithobyte.co", apiRoute: "api/v1"), Endpoint())

//just for stubbing purposes
call.firingFunc = { $0.responder?.data = json.data(using: .utf8) }

let cycleSignal: AnyPublisher<Cycle, Never> = modelPublisher(from: call.publisher.$data.eraseToAnyPublisher())
let cancel = cycleSignal.sink { vc.title = "\($0.ordinal ?? 0)th Cycle" }

let vm = refreshableTableViewModel(call, modelUnwrapper: ^\Cycle.reigns, reignConfigurator) { _ in }

vc.onViewDidLoad = {
    $0.view.backgroundColor = UIColor.white
    
    vm?.tableView = $0.tableView
    vm?.refresh()
}

PlaygroundPage.current.liveView = nc
PlaygroundPage.current.needsIndefiniteExecution = true
