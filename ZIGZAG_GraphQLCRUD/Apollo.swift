//
//  Apollo.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Apollo

class Apollo {
    static let shared = Apollo()
 
    private lazy var networkTransport = HTTPNetworkTransport(url: URL(string: "http://test.recruit.croquis.com:28500/")!, delegate: self)
    private (set) lazy var client = ApolloClient(networkTransport: networkTransport)
}

extension Apollo: HTTPNetworkTransportPreflightDelegate {
    func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
        return true
    }
    
    func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
        var headers = request.allHTTPHeaderFields ?? [String: String]()

        headers["Croquis-UUID"] = "00000000-0000-0000-0000-000000000000"
        request.allHTTPHeaderFields = headers
    }
}
