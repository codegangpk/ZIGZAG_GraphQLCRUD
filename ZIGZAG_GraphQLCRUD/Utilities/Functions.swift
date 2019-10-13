//
//  Functions.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/13.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
