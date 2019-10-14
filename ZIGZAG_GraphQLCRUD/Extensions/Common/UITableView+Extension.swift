//
//  UITableView+Extension.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/15.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

extension UITableView {
    func addRefreshControl(target: Any?, action: Selector, for controlEvent: UIControl.Event) {
        let refreshControl = UIRefreshControl()
        refreshControl.layer.zPosition = -1
        refreshControl.addTarget(target, action: action, for: controlEvent)
        self.refreshControl = refreshControl
    }
}
