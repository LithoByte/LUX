//
//  LUXImageTableViewCell.swift
//  LUX
//
//  Created by Calvin Collins on 12/3/21.
//

import UIKit
import SDWebImage
import Prelude
import LithoOperators

open class LUXImageTableViewCell: UITableViewCell {
    @IBOutlet weak public var contentImageView: UIImageView?
    @IBOutlet weak public var imageTopMargin: NSLayoutConstraint?
    @IBOutlet weak public var imageLeadingMargin: NSLayoutConstraint?
    @IBOutlet weak public var imageTrailingMargin: NSLayoutConstraint?
    @IBOutlet weak public var imageBottomMargin: NSLayoutConstraint?
    @IBOutlet weak public var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak public var imageWidthConstraint: NSLayoutConstraint?
    
    /**
     * The LUX provided XIB for this class does not include this constraint, as it could conflict with width/height constraints.
     * It is provided here for storing an aspect ratio constraint, or for subclasses that want to use it as an outlet.
     * If you'd like to use aspect ratio instead of width/height, we recommend looking at the code in bindUrlStringToCell, or
     * just using bindUrlString.
     */
    @IBOutlet weak public var aspectRatioConstraint: NSLayoutConstraint?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

public func bindUrlString<CellType>(to imageView: UIImageView?,
                                    from urlString: String,
                                    storingConstraintIn kp: WritableKeyPath<CellType, NSLayoutConstraint?>,
                                    on cell: CellType)
where CellType: UITableViewCell {
    if let url = URL(string: urlString) {
        imageView?.sd_setImage(with: url, completed: { image, _, _, _ in
            let tableView = cell.superview as? UITableView
            tableView?.beginUpdates()
            
            cell |> set(kp, applyRatioImageConstraint(to: imageView, for: image, removing: cell[keyPath: kp]))

            tableView?.endUpdates()
        })
    }
}

public func bindUrlStringToCell(_ cell: LUXImageTableViewCell, urlString: String) {
    if let url = URL(string: urlString) {
        cell.contentImageView?.sd_setImage(with: url, completed: { image, _, _, _ in
            if let imageView = cell.contentImageView {
                cell.imageHeightConstraint ?> imageView.removeConstraint(_:)
                cell.imageWidthConstraint ?> imageView.removeConstraint(_:)
            }
            
            let tableView = cell.superview as? UITableView
            tableView?.beginUpdates()
            
            cell.aspectRatioConstraint = applyRatioImageConstraint(to: cell.contentImageView, for: image, removing: cell.aspectRatioConstraint)

            tableView?.endUpdates()
        })
    }
}

public func applyRatioImageConstraint(to imageView: UIImageView?, for image: UIImage?, removing oldConstraint: NSLayoutConstraint?) -> NSLayoutConstraint? {
    if let imageView = imageView, let image = image {
        let imageSize = image.size
        let ratio = imageSize.height / imageSize.width
        
        if let oldConstraint = oldConstraint {
            imageView.removeConstraint(oldConstraint)
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let newConstraint = NSLayoutConstraint(item: imageView,
                                               attribute: .height,
                                               relatedBy: .equal,
                                               toItem: imageView,
                                               attribute: .width,
                                               multiplier: ratio,
                                               constant: 0)
        imageView.addConstraint(newConstraint)
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
    
    return nil
}
