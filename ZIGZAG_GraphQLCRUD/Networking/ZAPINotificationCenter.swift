//
//  NetworkNotifications.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/12.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import Foundation

enum ZigZagAPINotification: String {
    case didProductListRequested        = "DidProductListRequested"
    case didProductRequested            = "DidProductRequested"
    case didSupplierListRequested       = "DidSupplierListRequested"
    case didCreateProductRequested      = "DidCreateProductRequested"
    case didDeleteProductRequested      = "DidDeleteProductRequested"
    case didEditProductRequested        = "DidEditProductRequested"
    
    case didProductListRequestUpdated   = "DidProductListRequestUpdated"
    case didProductStateRequestUpdated  = "DidProductStateRequestUpdated"
    case didSupplierListRequestUpdated  = "DidSupplierListRequestUpdated"
    case didCreateProductRequestUpdated = "DidCreateProductRequestUpdated"
    case didDeleteProductRequestUpdated = "DidDeleteProductRequestUpdated"
    case didEditProductRequestUpdated   = "DidEditProductRequestUpdated"
    
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
        case state = "state"
        
        case product = "product"
        case products = "products"
        case suppliers = "suppliers"
        
        case createProductInput = "createProductInput"
    }
}
