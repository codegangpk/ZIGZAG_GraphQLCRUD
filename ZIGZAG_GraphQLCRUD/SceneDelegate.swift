//
//  SceneDelegate.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/10.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder {
    var window: UIWindow?
}

extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: ProductsViewController())
        window?.makeKeyAndVisible()
    }
}
