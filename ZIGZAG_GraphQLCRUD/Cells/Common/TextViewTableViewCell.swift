//
//  TextViewTableViewCell.swift
//  MyLocations
//
//  Created by Paul Kim on 13/08/2019.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        commonInit()
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
}

extension TextViewTableViewCell {
    private func commonInit() {
        textView.text.removeAll()
        
        selectionStyle = .none
    }
}

extension TextViewTableViewCell {
    class var nib: UINib? {
        return UINib(nibName: "TextViewTableViewCell", bundle: nil)
    }
}
