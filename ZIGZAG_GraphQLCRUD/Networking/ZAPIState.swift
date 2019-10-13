//
//  ZAPIState.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/13.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Foundation

enum ZAPIState {
    case standBy
    case loading
    case success(Any)
    case failed
}
