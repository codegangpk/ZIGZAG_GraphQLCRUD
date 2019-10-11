//
//  ZigZagAPI+Protocols.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Apollo

protocol ZigZagAPIProtocol {
    static var cacheKeyForObject: Apollo.CacheKeyForObject? { get set }

    static func clearCache(callbackQueue: DispatchQueue, completion: ((Result<Void, Error>) -> Void)?)
    static func fetch<Query>(query: Query, cachePolicy: Apollo.CachePolicy, context: UnsafeMutableRawPointer?, queue: DispatchQueue, resultHandler: Apollo.GraphQLResultHandler<Query.Data>?) -> Apollo.Cancellable where Query : Apollo.GraphQLQuery
    static func watch<Query>(query: Query, cachePolicy: Apollo.CachePolicy, queue: DispatchQueue, resultHandler: @escaping Apollo.GraphQLResultHandler<Query.Data>) -> Apollo.GraphQLQueryWatcher<Query> where Query : Apollo.GraphQLQuery
    static func perform<Mutation>(mutation: Mutation, context: UnsafeMutableRawPointer?, queue: DispatchQueue, resultHandler: Apollo.GraphQLResultHandler<Mutation.Data>?) -> Apollo.Cancellable where Mutation : Apollo.GraphQLMutation
    static func upload<Operation>(operation: Operation, context: UnsafeMutableRawPointer?, files: [Apollo.GraphQLFile], queue: DispatchQueue, resultHandler: Apollo.GraphQLResultHandler<Operation.Data>?) -> Apollo.Cancellable where Operation : Apollo.GraphQLOperation
    static func subscribe<Subscription>(subscription: Subscription, queue: DispatchQueue, resultHandler: @escaping Apollo.GraphQLResultHandler<Subscription.Data>) -> Apollo.Cancellable where Subscription : Apollo.GraphQLSubscription
}
