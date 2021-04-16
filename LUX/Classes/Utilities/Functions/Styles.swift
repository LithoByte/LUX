//
//  Styles.swift
//  LUX
//
//  Created by Elliot Schrock on 3/12/21.
//

import Foundation
import LithoOperators
import Prelude

public let setCappedEnds: (UIView) -> Void = {
    if $0.frame.height >= $0.frame.width {
        $0.layer.cornerRadius = $0.frame.width / 2
    } else {
        $0.layer.cornerRadius = $0.frame.height / 2
    }
}

public let setupButtonTitleColor: (UIColor) -> (UIButton) -> Void = { color in
    return { $0.setTitleColor(color, for: .normal) }
}
public let setupButtonTitle: (String) -> (UIButton) -> Void = { title in
    return { $0.setTitle(title, for: .normal) }
}

public let setupBgColor: (UIColor) -> (UIView) -> Void = \UIView.backgroundColor >|> set

public let setAutoLayout = set(\UIView.translatesAutoresizingMaskIntoConstraints, false)
public let setClipBounds = set(\UIView.clipsToBounds, true)

public let setTextFieldFont = \UITextField.font >|> set
public let setTextViewFont = \UITextView.font >|> set
public let setLabelFont = \UILabel.font >|> set

public let setBorderWidth: (CGFloat) -> (UIView) -> Void = \UIView.layer.borderWidth >|> set
public let setBorderColor: (CGColor) -> (UIView) -> Void = \UIView.layer.borderColor >|> set
public let setCornerRadius: (CGFloat) -> (UIView) -> Void = \UIView.layer.cornerRadius >|> set

public let setCapAndClip: (UIView) -> Void = setCappedEnds <> setClipBounds

public let roundTopCorners: (UIView) -> Void = set(\UIView.layer.maskedCorners, [.layerMinXMinYCorner, .layerMaxXMinYCorner])
public let roundBottomCorners: (UIView) -> Void = set(\UIView.layer.maskedCorners, [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
