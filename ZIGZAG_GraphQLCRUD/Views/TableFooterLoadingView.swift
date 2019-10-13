//
//  TableFooterLoadingView.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/13.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

class TableFooterLoadingView: UIActivityIndicatorView {
    init() {
        super.init(style: .medium)
        
        self.startAnimating()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
