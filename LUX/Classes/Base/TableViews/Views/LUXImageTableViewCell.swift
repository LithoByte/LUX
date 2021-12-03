//
//  LUXImageTableViewCell.swift
//  LUX
//
//  Created by Calvin Collins on 12/3/21.
//

import UIKit
import SDWebImage

open class LUXImageTableViewCell: UITableViewCell {
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var imageTopMargin: NSLayoutConstraint!
    @IBOutlet var imageLeadingMargin: NSLayoutConstraint!
    @IBOutlet var imageTrailingMargin: NSLayoutConstraint!
    @IBOutlet var imageBottomMargin: NSLayoutConstraint!
    @IBOutlet var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var imageWidthConstraint: NSLayoutConstraint!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

public func bindUrlStringToCell(_ cell: LUXImageTableViewCell, urlString: String) {
    if let url = URL(string: urlString) {
        cell.contentImageView.sd_setImage(with: url, completed: { image, _, _, _ in
            if let tableView = cell.superview as? UITableView, let image = image {
                tableView.beginUpdates()
                let imageSize = image.size
                let ratio = imageSize.height / imageSize.width
                
                if let imageView = cell.contentImageView {
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    cell.imageHeightConstraint.constant = imageView.bounds.width * ratio
                }

                tableView.endUpdates()
            }
        })
    }
}
