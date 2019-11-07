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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ScreenMirror.share.start()
        return true
    }
}

