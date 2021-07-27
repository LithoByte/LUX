import UIKit
import LUX
import PlaygroundVCHelpers
import FunNet
import PlaygroundSupport
import Slippers
import LithoOperators
import Prelude
import fuikit
import StoreKit

let vc = LUXSubscriptionViewController.makeFromXIB(name: "LUXSubscriptionViewController", bundle: Bundle(for: LUXSubscriptionViewController.self))

struct StoreKitIdentifiers: Codable {
    var identifiers: [String]
}

let call = CombineNetCall(configuration: ServerConfiguration(host: "lithobyte.co", apiRoute: "api/v1"), Endpoint())
call.firingFunc = { call in
    call.publisher.data = JsonProvider.encode(StoreKitIdentifiers(identifiers: ["com.LUX.monthly", "com.LUX.biyearly", "com.LUX.yearly"]))
}

let delegate = LUXSubscriptionDelegate()

vc.onViewDidLoad = { (vc: FUITableViewViewController) in
    delegate.fetchProducts(from: call, unwrapper: ^\StoreKitIdentifiers.identifiers)
}
let vm = subscriptionViewModel(onTap: { print($0.localizedTitle) }, delegate: delegate)
vc.onViewDidAppear = { (vc: FUITableViewViewController, animated: Bool) in
    vm.tableView = vc.tableView
    vm.tableView?.reloadData()
    vm.refresh()
}

PlaygroundPage.current.liveView = vc
PlaygroundPage.current.needsIndefiniteExecution = true
