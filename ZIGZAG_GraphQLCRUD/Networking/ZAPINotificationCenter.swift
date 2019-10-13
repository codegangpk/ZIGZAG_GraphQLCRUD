//
//  NetworkNotifications.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/12.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Foundation

enum ZigZagAPINotification: String {
    case didProductRequested              = "DidProductRequested"
    case didProductListRequested          = "DidProductListRequested"
    case didSupplierListRequested         = "DidSupplierListRequested"
    case didCreateProductRequested        = "DidCreateProductRequested"
    case didDeleteProductRequested        = "DidDeleteProductRequested"
    case didUpdateProductRequested        = "DidUpdateProductRequested"
    
    case didProductRequestUpdated         = "DidProductStateRequestUpdated"
    case didProductListRequestUpdated     = "DidProductListRequestUpdated"
    case didSupplierListRequestUpdated    = "DidSupplierListRequestUpdated"
    case didCreateProductRequestUpdated   = "DidCreateProductRequestUpdated"
    case didDeleteProductRequestUpdated   = "DidDeleteProductRequestUpdated"
    case didUpdateProductRequestUpdated   = "DidUpdateProductRequestUpdated"
    
    var name: Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

class ZAPINotificationCenter {
    static func post(notification: ZigZagAPINotification, object: Any? = nil, userInfo: [UserInfoKey: Any]? = nil) {
        NotificationCenter.default.post(name: notification.name, object: object, userInfo: userInfo)
    }
    
    static func addObserver(observer: Any, selector: Selector, notification: ZigZagAPINotification, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: notification.name, object: object)
    }
}

extension ZAPINotificationCenter {
    enum UserInfoKey: String {
        case zAPIState = "zAPIState"
        
        case productId = "productId"
        
        case product = "product"
        case products = "products"
        case suppliers = "suppliers"
        
        case createProductInput = "createProductInput"
        case deleteProductInput = "deleteProductInput"
        case updateProductInput = "updateProductInput"
    }
}

extension Notification {
    var zAPIState: ZAPIState? {
        guard let zAPIState = userInfo?[ZAPINotificationCenter.UserInfoKey.zAPIState] as? ZAPIState else { return nil }
        
        return zAPIState
    }
}
