//
//  AppDelegate.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/10.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {
    let networkManager = ZAPIManager()
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
