//
//  AppDelegate.swift
//  FlappyBrid
//
//  Created by Daniel on 2/2/16.
//  Copyright © 2016 XcodeYang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var newWindow: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        ScreenMirror.share.start()
        return true
    }

//    @available(iOS 13.0, *)
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        print(UIApplication.shared.connectedScenes)
//
//        let scene = UIWindowScene(session: connectingSceneSession, connectionOptions: options)
//        newWindow = UIWindow().then {
//            $0.rootViewController = GameViewController()
//            $0.windowScene = scene
//            $0.isHidden = false
//        }
//        return UISceneConfiguration(name: "External configuration", sessionRole: connectingSceneSession.role)
//    }
}
