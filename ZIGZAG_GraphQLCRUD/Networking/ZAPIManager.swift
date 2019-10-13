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
    
    init() {
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductRequested), notification: .didProductRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductListRequested), notification: .didProductListRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidSupplierListRequested), notification: .didSupplierListRequested)
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidCreateProductRequested(_:)), notification: .didCreateProductRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidDeleteProductRequested(_:)), notification: .didDeleteProductRequested)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidUpdateProductRequested(_:)), notification: .didUpdateProductRequested)
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
        ZAPINotificationCenter.post(notification: .didProductRequestUpdated, userInfo: [.zAPIState: ZAPIState.loading])
        
        dataTask = ZAPI.fetch(ProductQuery(id: productId)) { [weak self] result in
            guard let self = self else { return }
            
            self.dataTask = nil
            
            var newState: ZAPIState = .failed
            
            switch result {
            case .success(let graphQLResult):
                if let productDetailFragment = graphQLResult.data?.product?.fragments.productDetailFragment,
                    let product = Product(productDetailFragment: productDetailFragment) {
                    newState = .success(product)
                }
            case .failure(let error):
                NSLog("Error while fetching query: \(error.localizedDescription)")
            }
            ZAPINotificationCenter.post(notification: .didProductRequestUpdated, userInfo: [.zAPIState: newState])
        }
    }
    
    @objc private func onDidProductListRequested() {
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didProductListRequestUpdated, userInfo: [.zAPIState: ZAPIState.loading])
        
        dataTask = ZAPI.fetch(ProductListQuery(id_list: nil)) { [weak self] result in
            guard let self = self else { return }
            
            self.dataTask = nil
            
            var newState: ZAPIState = .failed
            
            switch result {
            case .success(let graphQLResult):
                if let products = graphQLResult.data?.productList.itemList.compactMap({ Product(productListFragment: $0.fragments.productListFragment) }) {
                    newState = .success(products)
                }
            case .failure(let error):
                NSLog("Error while fetching query: \(error.localizedDescription)")
            }
            ZAPINotificationCenter.post(notification: .didProductListRequestUpdated, userInfo: [.zAPIState: newState])
        }
    }
    
    @objc private func onDidSupplierListRequested() {
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didSupplierListRequestUpdated, userInfo: [.zAPIState: ZAPIState.loading])
        
        dataTask = ZAPI.fetch(SupplierListQuery(id_list: nil)) { [weak self] result in
            guard let self = self else { return }
            
            self.dataTask = nil

            var newState: ZAPIState = .failed
            
            switch result {
            case .success(let graphQLResult):
                if let suppliers = graphQLResult.data?.supplierList.itemList.compactMap({ Supplier(supplierFragment: $0.fragments.supplierFragment) }) {
                    newState = .success(suppliers)
                }
            case .failure(let error):
                NSLog("Error while fetching query: \(error.localizedDescription)")
            }
            ZAPINotificationCenter.post(notification: .didSupplierListRequestUpdated, userInfo: [.zAPIState: newState])
        }
    }
}

extension ZAPIManager {
    @objc private func onDidCreateProductRequested(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let createProductInput = data[ZAPINotificationCenter.UserInfoKey.createProductInput] as? CreateProductInput else { return }
        
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didCreateProductRequestUpdated, userInfo: [.zAPIState: ZAPIState.loading])
        
        dataTask = ZAPI.perform(CreateProductMutation(input: createProductInput)) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dataTask = nil
            
            var newState: ZAPIState = .failed
            
            switch result {
            case .success(let graphQLResult):
                if let productDetailFragment = graphQLResult.data?.createProduct.fragments.productDetailFragment,
                    let product = Product(productDetailFragment: productDetailFragment)
                {
                    newState = .success(product)
                }
            case .failure(let error):
                NSLog("Error while performing mutation: \(error.localizedDescription)")
            }
            ZAPINotificationCenter.post(notification: .didCreateProductRequestUpdated, userInfo: [.zAPIState: newState])
        }
    }
    
    @objc private func onDidDeleteProductRequested(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let deleteProductInput = data[ZAPINotificationCenter.UserInfoKey.deleteProductInput] as? DeleteProductInput else { return }
        
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didDeleteProductRequestUpdated, userInfo: [.zAPIState: ZAPIState.loading])
        
        dataTask = ZAPI.perform(DeleteProductMutation(input: deleteProductInput)) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dataTask = nil
            
            var newState: ZAPIState = .failed
            
            switch result {
            case .success(let graphQLResult):
                if let productDetailFragment = graphQLResult.data?.deleteProduct.fragments.productDetailFragment,
                    let product = Product(productDetailFragment: productDetailFragment)
                {
                    newState = .success(product)
                }
            case .failure(let error):
                NSLog("Error while performing mutation: \(error.localizedDescription)")
            }
            ZAPINotificationCenter.post(notification: .didDeleteProductRequestUpdated, userInfo: [.zAPIState: newState])
        }
    }
    
    @objc private func onDidUpdateProductRequested(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let updateProductInput = data[ZAPINotificationCenter.UserInfoKey.updateProductInput] as? UpdateProductInput else { return }
        
        dataTask?.cancel()
        ZAPINotificationCenter.post(notification: .didUpdateProductRequestUpdated, userInfo: [.zAPIState: ZAPIState.loading])
        
        dataTask = ZAPI.perform(UpdateProductMutation(input: updateProductInput)) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dataTask = nil
            
            var newState: ZAPIState = .failed
            
            switch result {
            case .success(let graphQLResult):
                if let productDetailFragment = graphQLResult.data?.updateProduct.fragments.productDetailFragment,
                    let product = Product(productDetailFragment: productDetailFragment)
                {
                    newState = .success(product)
                }
            case .failure(let error):
                NSLog("Error while performing mutation: \(error.localizedDescription)")
            }
            ZAPINotificationCenter.post(notification: .didUpdateProductRequestUpdated, userInfo: [.zAPIState: newState])
        }
    }
}
