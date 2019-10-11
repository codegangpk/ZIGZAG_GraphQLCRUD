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
    
    init() {
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductListRequested), notification: .didProductListRequested)
//        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductListRequested), notification: .didProductRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidSupplierListRequested), notification: .didSupplierListRequested)
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidCreateProductRequested), notification: .didCreateProductRequested)
//        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onProductListRequested), notification: .didProductListRequested)
//        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onProductListRequested), notification: .didProductListRequested)
    }
    
    deinit {
        dataTask?.cancel()
    }
}

extension ZAPIManager {
    @objc private func onDidProductListRequested() {
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didProductListRequestUpdated, userInfo: [.state: State.loading])
        
        dataTask = ZAPI.fetch(ProductListQuery(id_list: nil)) { result in
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
        }
    }
    
    @objc private func onDidSupplierListRequested() {
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didSupplierListRequestUpdated, userInfo: [.state: State.loading])
        
        var newState: State = .failed
        var suppliers: [Supplier] = []
        
        dataTask = ZAPI.fetch(SupplierListQuery(id_list: nil)) { result in
            switch result {
            case .success(let graphQLResult):
                newState = .success
                suppliers = graphQLResult.data?.supplierList.itemList.compactMap { Supplier(supplierFragment: $0.fragments.supplierFragment) } ?? []
            case .failure(let error):
                newState = .failed
                NSLog("Error while fetching query: \(error.localizedDescription)")
            }
            ZAPINotificationCenter.post(notification: .didSupplierListRequestUpdated, userInfo: [.state: newState, .suppliers: suppliers])
        }
        
    }
}

extension ZAPIManager {
    @objc private func onDidCreateProductRequested(_ notification: Notification) {
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
            ZAPINotificationCenter.post(notification: .didCreateProductRequestUpdated, userInfo: [.state: newState, .product: product as Any])
        }
    }
}
