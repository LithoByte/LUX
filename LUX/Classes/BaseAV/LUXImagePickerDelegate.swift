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

public class LUXImagePickerDelegate: FUIImagePickerDelegate {
    
    public init(onSelectMediaURL: @escaping (URL?) -> Void) {
        super.init()
        self.onPickerDidPick = dismissPicker >>> onSelectMediaURL
        self.onPickerDidCancel = dismissAnimated
    }
}

private func dismissPicker(_ picker:UIImagePickerController, info: [UIImagePickerController.InfoKey : Any]) -> URL? {
    picker.dismiss(animated: true, completion: nil)
    return infoToURL(info)
}

private let infoToURL: ([UIImagePickerController.InfoKey : Any]) -> URL? = {
    return $0[UIImagePickerController.InfoKey.mediaURL] as? URL
}

public let urlToAvPlayer: (URL) -> AVPlayer? = AVPlayer.init(url:)
public let urlToImage: (URL) -> UIImage? = urlToData >?> UIImage.init(data:)
public func urlToData(_ url: URL) -> Data? {
    return try? Data(contentsOf: url)
}
public protocol LUXImageViewController {
    var imageView: UIImageView! { get set }
}
