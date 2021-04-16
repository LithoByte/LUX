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
import Photos

public class LUXImagePickerDelegate: FUIImagePickerDelegate {
    var dismissPicker: (UIImagePickerController, [UIImagePickerController.InfoKey : Any]) -> Void = ignoreSecondArg(f: dismissAnimated)
    var getInfo: (UIImagePickerController, [UIImagePickerController.InfoKey : Any]) -> URL? = ignoreFirstArg(f: infoToMediaURL)
    
    public init(onSelectMediaURL: (@escaping (URL?) -> Void) = { _ in },
                onSelectEditedImage: (@escaping (UIImage?) -> Void) = { _ in },
                onSelectOriginalImage: (@escaping (UIImage?) -> Void) = { _ in },
                onSelectImageUrl: (@escaping (UIImage?) -> Void) = { _ in },
                onSelectCropRect: (@escaping (CGRect?) -> Void) = { _ in },
                onSelectLivePhoto: (@escaping (PHLivePhoto?) -> Void) = { _ in },
                onSelectMediaData: (@escaping (Data?) -> Void) = { _ in },
                onSelectAVPlayer: (@escaping (AVPlayer?) -> Void) = { _ in }) {
        super.init()
        let videoHandler = getInfo >?> urlToAvPlayer >?> onSelectAVPlayer
        let dataHandler = getInfo >?> urlToData >?> onSelectMediaData
        self.onPickerDidPick = union(getInfo >>> onSelectMediaURL,
                                     ignoreFirstArg(f: infoToOriginalImage) >>> onSelectOriginalImage,
                                     ignoreFirstArg(f: infoToEditedImage) >>> onSelectEditedImage,
                                     ignoreFirstArg(f: infoToLivePhoto) >>> onSelectLivePhoto,
                                     dataHandler,
                                     videoHandler,
                                     dismissPicker)
        self.onPickerDidCancel = dismissAnimated
    }
}

public let urlToAvPlayer: (URL) -> AVPlayer? = AVPlayer.init(url:)
public let urlToImage: (URL) -> UIImage? = urlToData >?> UIImage.init(data:)
public func urlToData(_ url: URL) -> Data? {
    return try? Data(contentsOf: url)
}
