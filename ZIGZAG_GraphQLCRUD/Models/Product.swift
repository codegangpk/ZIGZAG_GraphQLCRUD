//
//  Product.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Foundation

struct Product {
    var id: String?
    var nameKo: String?
    var nameEn: String?
    var descriptionKo: String?
    var price: Int?
    var supplier: Supplier?
    var dateCreated: Double?
    var dateUpdatd: Double?
    
    init() { }
    
    init(id: String, nameKo: String, price: Int, supplier: Supplier) {
        self.id = id
        self.nameKo = nameKo
        self.price = price
        self.supplier = supplier
    }
    
    init?(productListFragment: ProductListFragment) {
        let id = productListFragment.id
        guard let nameKo = productListFragment.nameKo else { return nil }
        guard let price = productListFragment.price else { return nil }
        guard let supplierFragment = productListFragment.supplier?.fragments.supplierFragment else { return nil }
        guard let supplier = Supplier(supplierFragment: supplierFragment) else { return nil }
        
        //TODO: data isEmpty validation check
//        guard nameKo.isEmpty == false else { return nil }
//        guard supplierFragment.name.isEmpty == false else { return nil }
        
        self.init(id: id, nameKo: nameKo, price: price, supplier: supplier)
        
        self.nameEn = productListFragment.nameEn
        self.dateCreated = productListFragment.dateCreated
        self.dateUpdatd = productListFragment.dateUpdated
    }
}

struct Supplier {
    var id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init?(supplierFragment: SupplierFragment) {
        let id = supplierFragment.id
        let name = supplierFragment.name
        
        self.init(id: id, name: name)
    }
}
