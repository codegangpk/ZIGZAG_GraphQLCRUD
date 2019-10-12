//
//  TextFieldTableViewCell.swift
//  Checklists
//
//  Created by Paul Kim on 22/07/2019.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    var textFieldDidChange: ((UITextField) -> Void)?
    var textFieldDidEndOnExit: ((UITextField) -> Void)?
    
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
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}

extension TextFieldTableViewCell {
    private func commonInit() {
        selectionStyle = .none
        isUserInteractionEnabled = true
        
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.returnKeyType = .done
        textField.keyboardType = .numberPad
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidEndOnExit(_:)), for: .editingDidEndOnExit)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textFieldDidChange?(textField)
    }
    
    @objc func textFieldDidEndOnExit(_ textField: UITextField) {
        textFieldDidEndOnExit?(textField)
    }
}

extension TextFieldTableViewCell {
    class var nib: UINib? {
        return UINib(nibName: "TextFieldTableViewCell", bundle: nil)
    }
}
