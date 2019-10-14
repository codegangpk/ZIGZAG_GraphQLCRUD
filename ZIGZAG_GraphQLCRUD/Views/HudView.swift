//
//  HudView.swift
//  MyLocations
//
//  Created by Paul Kim on 13/08/2019.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    @discardableResult
    class func hud(inView view: UIView, text: String, animated: Bool, completion: (() -> Void)?) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.text = text
        
        hudView.show(animated: animated, completion: completion)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight
        )
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        if let image = UIImage(named: "checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8
            )
            image.draw(at: imagePoint)
        }
        
        let attribs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attribs)
        
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4
        )
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    func show(animated: Bool, completion: (() -> Void)?) {
        guard animated else { return }
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: { [weak self] in
                guard let self = self else { return }
                
                self.alpha = 1
                self.transform = .identity
            },
            completion: { [weak self] (_) in
                guard let self = self else { return }
                
                afterDelay(0.3, run: {
                    UIView.animate(
                        withDuration: 0.3,
                        delay: 0.3,
                        usingSpringWithDamping: 0.7,
                        initialSpringVelocity: 0.5,
                        options: [],
                        animations: { [weak self] in
                            guard let self = self else { return }
                            
                            self.alpha = 0
                            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                        }
                    ) { [weak self] (_) in
                        guard let self = self else { return }
                        
                        completion?()
                        self.hide()
                    }
                })
            }
        )
    }
    
    private func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
}
