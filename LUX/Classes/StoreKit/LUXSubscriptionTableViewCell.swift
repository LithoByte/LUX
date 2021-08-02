//
//  SubscriptionTableViewCell.swift
//  LUX
//
//  Created by Calvin Collins on 7/26/21.
//

import UIKit

public class LUXSubscriptionTableViewCell: UITableViewCell {
    @IBOutlet weak var subscriptionNameLabel: UILabel!
    @IBOutlet weak var subscriptionDescriptionLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var onPriceTap: (() -> Void)?
    
    @IBAction func priceTapped(_ sender: UIButton!) {
        onPriceTap?()
    }
}
