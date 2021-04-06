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
    var dismissPicker: (UIImagePickerController, [UIImagePickerController.InfoKey : Any]) -> Void = ignoreSecondArg(f: dismissAnimated)
    var getInfo: (UIImagePickerController, [UIImagePickerController.InfoKey : Any]) -> URL? = ignoreFirstArg(f: infoToURL)
    public init(onSelectMediaURL: (@escaping (URL?) -> Void) = { _ in }, onSelectEditedImage: (@escaping (UIImage?) -> Void) = { _ in }, onSelectMediaData: (@escaping (Data?) -> Void) = { _ in }, onSelectAVPlayer: (@escaping (AVPlayer?) -> Void) = { _ in }) {
        super.init()
        let imageHandler = ~getInfo >?> urlToImage >?> onSelectEditedImage
        let videoHandler = ~getInfo >?> urlToAvPlayer >?> onSelectAVPlayer
        let dataHandler = ~getInfo >?> urlToData >?> onSelectMediaData
        let urlHandler = ~getInfo >?> onSelectMediaURL
        self.onPickerDidPick = id(with: dismissPicker) >>> (imageHandler <> videoHandler <> dataHandler <> urlHandler)
        self.onPickerDidCancel = dismissAnimated
    }
}

private let infoToURL: ([UIImagePickerController.InfoKey : Any]) -> URL? = { info in
    return info[UIImagePickerController.InfoKey.mediaURL] as? URL
}

public let urlToAvPlayer: (URL) -> AVPlayer? = AVPlayer.init(url:)
public let urlToImage: (URL) -> UIImage? = urlToData >?> UIImage.init(data:)
public func urlToData(_ url: URL) -> Data? {
    return try? Data(contentsOf: url)
}
public func id<A, B>(with sideEffect: @escaping (A, B) -> Void) -> (A, B) -> (A, B) {
    return {
        sideEffect($0, $1)
        return ($0, $1)
    }
}
