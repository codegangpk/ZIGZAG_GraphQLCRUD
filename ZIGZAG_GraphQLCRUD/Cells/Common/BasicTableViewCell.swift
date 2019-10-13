//
//  BasicTableViewCell.swift
//  MyLocations
//
//  Created by Paul Kim on 19/08/2019.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

class BasicTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        commonInit()
    }
}

extension BasicTableViewCell {
    private func commonInit() {
        label.text?.removeAll()
    }
}

extension BasicTableViewCell {
    class var nib: UINib? {
        return UINib(nibName: "BasicTableViewCell", bundle: nil)
    }
}
