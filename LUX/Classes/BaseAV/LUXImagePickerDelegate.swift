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

public class LUXImagePickerDelegate<T>: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate where T: LUXImageViewController {
    
    public var presentingVC: T
    public var onSelectImage: (UIImage?) -> Void
    
    public init(_ vc: T, onSelectImage: @escaping (T, UIImage?) -> Void) {
        self.presentingVC = vc
        self.onSelectImage = presentingVC >|> onSelectImage
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return onSelectImage(nil) }
        onSelectImage(image)
    }
}

public protocol LUXImageViewController {
    var imageView: UIImageView! { get set }
}
