//
//  LoadingTableViewCell.swift
//  StoreSearch
//
//  Created by Paul Kim on 20/08/2019.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        commonInit()
    }
}

extension LoadingTableViewCell {
    private func commonInit() {
        label.text?.removeAll()
        spinner.stopAnimating()
    }
}

extension LoadingTableViewCell {
    class var nib: UINib? {
        return UINib(nibName: "LoadingTableViewCell", bundle: nil)
    }
}
