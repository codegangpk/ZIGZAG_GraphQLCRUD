//
//  UITextField+Extension.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/15.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

extension UITextField {
    func setCursor(to offset: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let newPosition = self.position(from: self.beginningOfDocument, offset: offset) {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            }
        }
    }
}
