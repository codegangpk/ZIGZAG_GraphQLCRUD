//
//  Error+Extension.swift
//  Orange Map
//
//  Created by Paul Kim on 21/09/2019.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Foundation

extension Error {
    var isCanceledNetworkRequest: Bool {
        return (self as NSError?)?.code == NSURLErrorCancelled
    }
}
