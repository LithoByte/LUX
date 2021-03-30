//
//  LUXImagePickerDelegate.swift
//  FlexDataSource
//
//  Created by Calvin Collins on 2/25/21.
//

import UIKit
import AVKit
import AVFoundation
import LithoOperators
import fuikit
import Prelude

public class LUXImagePickerDelegate<T>: FUIImagePickerDelegate where T: LUXImageViewController {
    
    public var presentingVC: T
    
    public init(_ vc: T, onSelectImage: @escaping (T, UIImage?) -> Void) {
        self.presentingVC = vc
        super.init()
        self.onPickerDidPick = dismissPicker >>> (presentingVC >|> onSelectImage)
        self.onPickerDidCancel = dismissAnimated
    }
}

private func dismissPicker(_ picker:UIImagePickerController, info: [UIImagePickerController.InfoKey : Any]) -> UIImage? {
    picker.dismiss(animated: true, completion: nil)
    return infoToImage(info)
}

private let infoToImage: ([UIImagePickerController.InfoKey : Any]) -> UIImage? = {
    return $0[UIImagePickerController.InfoKey.editedImage] as? UIImage
}

public protocol LUXImageViewController {
    var imageView: UIImageView! { get set }
}
