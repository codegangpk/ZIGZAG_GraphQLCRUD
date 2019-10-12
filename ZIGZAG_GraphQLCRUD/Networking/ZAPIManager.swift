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
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductRequested), notification: .didProductRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductListRequested), notification: .didProductListRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidSupplierListRequested), notification: .didSupplierListRequested)
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidCreateProductRequested(_:)), notification: .didCreateProductRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidDeleteProductRequested(_:)), notification: .didDeleteProductRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidUpdateProductRequested(_:)), notification: .didProductListRequested)
    }
    
    deinit {
        dataTask?.cancel()
    }
}

extension ZAPIManager {
    @objc private func onDidProductRequested(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let productId = data[ZAPINotificationCenter.UserInfoKey.productId] as? String else { return }
        
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didProductRequestUpdated, userInfo: [.state: State.loading])
        
        dataTask = ZAPI.fetch(ProductQuery(id: productId)) { result in
            
            self.dataTask = nil
            
            var newState: State = .failed
            var product: Product?
            
            switch result {
            case .success(let graphQLResult):
                newState = .success
                if let productDetailFragment = graphQLResult.data?.product?.fragments.productDetailFragment {
                    product = Product(productDetailFragment: productDetailFragment)
                }
            case .failure(let error):
                newState = .failed
                NSLog("Error while fetching query: \(error.localizedDescription)")
            }
            ZAPINotificationCenter.post(notification: .didProductRequestUpdated, userInfo: [.state: newState, .product: product as Any])
        }
    }
    
    @objc private func onDidProductListRequested() {
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didProductListRequestUpdated, userInfo: [.state: State.loading])
        
        dataTask = ZAPI.fetch(ProductListQuery(id_list: nil)) { [weak self] result in
            guard let self = self else { return }
            
            self.dataTask = nil
            
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
        
        dataTask = ZAPI.fetch(SupplierListQuery(id_list: nil)) { [weak self] result in
            guard let self = self else { return }
            
            self.dataTask = nil
            
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
        
        dataTask = ZAPI.perform(CreateProductMutation(input: createProductInput)) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dataTask = nil
            
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
    
    @objc private func onDidDeleteProductRequested(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let deleteProductInput = data[ZAPINotificationCenter.UserInfoKey.deleteProductInput] as? DeleteProductInput else { return }
        
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didDeleteProductRequestUpdated, userInfo: [.state: State.loading])
        
        var newState: State = .failed
        var product: Product?
        
        dataTask = ZAPI.perform(DeleteProductMutation(input: deleteProductInput)) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dataTask = nil
            
            switch result {
            case .success(let graphQLResult):
                newState = .success
                if let productDetailFragment = graphQLResult.data?.deleteProduct.fragments.productDetailFragment {
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
    
    @objc private func onDidUpdateProductRequested(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let updateProductInput = data[ZAPINotificationCenter.UserInfoKey.updateProductInput] as? UpdateProductInput else { return }
        
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didUpdateProductRequestUpdated, userInfo: [.state: State.loading])
        
        var newState: State = .failed
        var product: Product?
        
        dataTask = ZAPI.perform(UpdateProductMutation(input: updateProductInput)) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dataTask = nil
            
            switch result {
            case .success(let graphQLResult):
                newState = .success
                if let productDetailFragment = graphQLResult.data?.updateProduct.fragments.productDetailFragment {
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
