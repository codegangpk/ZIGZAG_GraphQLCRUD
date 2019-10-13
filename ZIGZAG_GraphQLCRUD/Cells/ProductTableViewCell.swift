//
//  ProductTableViewCell.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/12.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var supplierLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameKoLabel: UILabel!
    @IBOutlet weak var nameEnLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        commonInit()
    }
}

extension ProductTableViewCell {
    private func commonInit() {
        supplierLabel.text?.removeAll()
        idLabel.text?.removeAll()
        nameKoLabel.text?.removeAll()
        nameEnLabel.text?.removeAll()
        priceLabel.text?.removeAll()
    }
    
    func configure(with product: Product) {
        idLabel.text = product.id
        nameKoLabel.text = product.nameKo
        nameEnLabel.text = product.nameEn?.isEmpty == false ? product.nameEn : "%L%: (English Name Unavailable)"
        priceLabel.text = product.price?.priceKRW
        supplierLabel.text = product.supplier?.name
    }
}

extension ProductTableViewCell {
    class var nib: UINib? {
        return UINib(nibName: "ProductTableViewCell", bundle: nil)
    }
}
