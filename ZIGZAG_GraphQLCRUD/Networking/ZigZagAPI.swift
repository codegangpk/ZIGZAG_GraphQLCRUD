//
//  Apollo.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Apollo

class ZigZagAPI {
    static let shared = ZigZagAPI()
    
    var baseURL: URL {
        switch NetworkConfig.environment {
        default:
            return URL(string: "http://test.recruit.croquis.com:28500/")!
        }
    }
    private lazy var networkTransport = HTTPNetworkTransport(url: baseURL, delegate: self)
    private (set) lazy var client = ApolloClient(networkTransport: networkTransport)
}

extension ZigZagAPI: HTTPNetworkTransportPreflightDelegate {
    func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
        return true
    }
    
    func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
        NetworkConfig.croquisUUIDHeader.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
