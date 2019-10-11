//
//  ZigZagNetworkManager.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Apollo

class ZAPIManager {
    private var dataTask: Cancellable?
    
    enum State {
        case standBy
        case loading
        case success
        case failed
    }
    private(set) var state: State = .standBy
    
    init() {
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onProductListRequested), notification: .didProductListRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onProductListRequested), notification: .didProductRequested)
//        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onProductListRequested), notification: .didProductListRequested)
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onCreateProductRequested(_:)), notification: .didCreateProductRequested)
//        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onProductListRequested), notification: .didProductListRequested)
//        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onProductListRequested), notification: .didProductListRequested)
    }
    
    deinit {
        dataTask?.cancel()
    }
}

extension ZAPIManager {
    @objc private func onProductListRequested() {
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didProductListRequestUpdated, userInfo: [.state: State.loading])
        
        dataTask = ZAPI.fetch(ProductListQuery(id_list: nil)) { [weak self] result in
            guard let self = self else { return }
            
            var newState: State = .failed
            var products: [Product] = []
            
            switch result {
            case .success(let graphQLResult):
                newState = .success
                products = graphQLResult.data?.productList.itemList.compactMap { Product(productListFragment: $0.fragments.productListFragment) } ?? []
            case .failure(let error):
                newState = .failed
                NSLog("Error while fetching query: \(error.localizedDescription)")
            }

            ZAPINotificationCenter.post(notification: .didProductListRequestUpdated, userInfo: [.state: newState, .products: products])
            self.state = .standBy
        }
    }
    
    @objc private func onCreateProductRequested(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let createProductInput = data[ZAPINotificationCenter.UserInfoKey.createProductInput] as? CreateProductInput else { return }
        
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didCreateProductRequestUpdated, userInfo: [.state: State.loading])
        
        var newState: State = .failed
        var product: Product?
        
        dataTask = ZAPI.perform(CreateProductMutation(input: createProductInput)) { (result) in
            switch result {
            case .success(let graphQLResult):
                newState = .success
                if let productDetailFragment = graphQLResult.data?.createProduct.fragments.productDetailFragment {
                    product = Product(productDetailFragment: productDetailFragment)
                }
                print(graphQLResult)
            case .failure(let error):
                newState = .failed
                print(error)
            }
        }

        ZAPINotificationCenter.post(notification: .didCreateProductRequestUpdated, userInfo: [.state: newState, .product: product as Any])
        self.state = .standBy
    }
}
