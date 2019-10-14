//
//  String+Extension.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/12.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

extension String {
    func boundedRect(maxWidth: CGFloat, font: UIFont) -> CGRect {
        return self.boundingRect(
            with: CGSize(width: maxWidth, height: 999999),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
    }
    
    mutating func filterDigitsOnly() {
        let allowedString = "0123456789"
        self = self.filter {
            allowedString.contains($0)
        }
    }
}
