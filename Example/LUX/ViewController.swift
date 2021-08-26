//
//  ViewController.swift
//  LUX
//
//  Created by Elliot on 12/07/2019.
//  Copyright (c) 2019 Elliot. All rights reserved.
//

import UIKit
import LUX
import LithoOperators
import fuikit
struct Human: Codable {
  var id: Int = -1
  var name: String?
}
class ViewController: LUXFlexViewController<LUXTableViewModel> {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel = LUXTableViewModel()
    self.tableViewDelegate = FPUITableViewDelegate()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

