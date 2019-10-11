//
//  ZigZagAPI+Protocols.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Apollo

protocol ZAPIProtocol {
    static var cacheKeyForObject: Apollo.CacheKeyForObject? { get set }

    static func clearCache(callbackQueue: DispatchQueue, completion: ((Result<Void, Error>) -> Void)?)
    static func fetch<Query>(_ query: Query, cachePolicy: Apollo.CachePolicy, context: UnsafeMutableRawPointer?, queue: DispatchQueue, resultHandler: Apollo.GraphQLResultHandler<Query.Data>?) -> Apollo.Cancellable where Query : Apollo.GraphQLQuery
    static func watch<Query>(_ query: Query, cachePolicy: Apollo.CachePolicy, queue: DispatchQueue, resultHandler: @escaping Apollo.GraphQLResultHandler<Query.Data>) -> Apollo.GraphQLQueryWatcher<Query> where Query : Apollo.GraphQLQuery
    static func perform<Mutation>(_ mutation: Mutation, context: UnsafeMutableRawPointer?, queue: DispatchQueue, resultHandler: Apollo.GraphQLResultHandler<Mutation.Data>?) -> Apollo.Cancellable where Mutation : Apollo.GraphQLMutation
    static func upload<Operation>(_ operation: Operation, context: UnsafeMutableRawPointer?, files: [Apollo.GraphQLFile], queue: DispatchQueue, resultHandler: Apollo.GraphQLResultHandler<Operation.Data>?) -> Apollo.Cancellable where Operation : Apollo.GraphQLOperation
    static func subscribe<Subscription>(_ subscription: Subscription, queue: DispatchQueue, resultHandler: @escaping Apollo.GraphQLResultHandler<Subscription.Data>) -> Apollo.Cancellable where Subscription : Apollo.GraphQLSubscription
}
