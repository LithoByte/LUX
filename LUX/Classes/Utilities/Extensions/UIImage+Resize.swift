//
//  UIImage+Resize.swift
//  LUX
//
//  Created by Elliot Schrock on 4/20/21.
//

import Foundation

public extension UIImage {
    func resizedProportionally(newHeight: CGFloat) -> UIImage? {
        return resizeImageProportionally(self, newHeight: newHeight)
    }
}

public func resizeImageProportionally(_ image: UIImage, newHeight: CGFloat) -> UIImage? {
    let scale = newHeight / image.size.height
    let newWidth = image.size.width * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
}
