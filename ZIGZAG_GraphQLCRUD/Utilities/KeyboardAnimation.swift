//
//  KeyboardAnimation.swift
//  PurpleMap
//
//  Created by Paul Kim on 26/09/2019.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

protocol BottomOverlayAnimation {
    var frame: CGRect { get set }
    var duration: TimeInterval { get set}
    var options: UIView.AnimationOptions { get set }
}

struct KeyboardAnimation: BottomOverlayAnimation {
    var frame = CGRect.zero
    var duration: TimeInterval = 0.2
    var options = UIView.AnimationOptions()
}

extension Notification {
    var keyboardAnimation: KeyboardAnimation? {
        guard let userInfo = userInfo, let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
        
        var keyboardAnimation = KeyboardAnimation()
        
        keyboardAnimation.frame = endFrame
        if let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            keyboardAnimation.duration = animationDuration
        }
        if let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            keyboardAnimation.options = UIView.AnimationOptions(rawValue: animationCurveRawNSN)
        }
        return keyboardAnimation
    }
}
