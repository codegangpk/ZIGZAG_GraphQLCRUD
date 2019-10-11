//
//  ZigZagAPIConfig.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Foundation

struct NetworkConfig {
    enum NetworkEnvironment {
        case test
    }
    
    static let environment: NetworkEnvironment = .test
    static let croquisUUIDHeader = ["Croquis-UUID": "00000000-0000-0000-0000-000000000000"]
}
