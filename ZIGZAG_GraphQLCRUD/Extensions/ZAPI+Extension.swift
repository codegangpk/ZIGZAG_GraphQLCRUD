//
//  ZigZag+Extension.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Apollo

extension ZAPI: ZAPIProtocol {
    static var cacheKeyForObject: Apollo.CacheKeyForObject? {
        get {
            return shared.client.cacheKeyForObject
        }
        set {
            shared.client.cacheKeyForObject = newValue
        }
    }
    
    static func clearCache(callbackQueue: DispatchQueue = .main, completion: ((Result<Void, Error>) -> Void)? = nil) {
        shared.client.clearCache(callbackQueue: callbackQueue, completion: completion)
    }
    
    @discardableResult
    static func fetch<Query>(_ query: Query, cachePolicy: Apollo.CachePolicy = .returnCacheDataElseFetch, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue = DispatchQueue.main, resultHandler: Apollo.GraphQLResultHandler<Query.Data>?) -> Apollo.Cancellable where Query : Apollo.GraphQLQuery {
        return shared.client.fetch(query: query, cachePolicy: cachePolicy, context: context, queue: queue, resultHandler: resultHandler)
    }
    
    @discardableResult
    static func watch<Query>(_ query: Query, cachePolicy: Apollo.CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = .main, resultHandler: @escaping Apollo.GraphQLResultHandler<Query.Data>) -> Apollo.GraphQLQueryWatcher<Query> where Query : Apollo.GraphQLQuery {
        return shared.client.watch(query: query, cachePolicy: cachePolicy, queue: queue, resultHandler: resultHandler)
    }

    @discardableResult
    static func perform<Mutation>(_ mutation: Mutation, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue = DispatchQueue.main, resultHandler: Apollo.GraphQLResultHandler<Mutation.Data>?) -> Apollo.Cancellable where Mutation : Apollo.GraphQLMutation {
        return shared.client.perform(mutation: mutation, context: context, queue: queue, resultHandler: resultHandler)
    }

    @discardableResult
    static func upload<Operation>(_ operation: Operation, context: UnsafeMutableRawPointer? = nil, files: [Apollo.GraphQLFile], queue: DispatchQueue = .main, resultHandler: Apollo.GraphQLResultHandler<Operation.Data>?) -> Apollo.Cancellable where Operation : Apollo.GraphQLOperation {
        return shared.client.upload(operation: operation, context: context, files: files, queue: queue, resultHandler: resultHandler)
    }
    
    @discardableResult
    static func subscribe<Subscription>(_ subscription: Subscription, queue: DispatchQueue = .main, resultHandler: @escaping Apollo.GraphQLResultHandler<Subscription.Data>) -> Apollo.Cancellable where Subscription : Apollo.GraphQLSubscription {
        return shared.client.subscribe(subscription: subscription, queue: queue, resultHandler: resultHandler)
    }
}
