//
//  AppDelegate.swift
//  XZKit
//
//  Created by mlibai on 06/13/2017.
//  Copyright (c) 2017 mlibai. All rights reserved.
//

import UIKit
import XZKit
import StoreKit
import AVFoundation
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let tabBarVC = TabBarController.init();
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()
        self.window = window
        
        XZLog("%@", XZKit.Networking.queue)
        
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        window!.rootViewController?.setNeedsRedirect(with: url)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return application(app, handleOpen: url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.application(application, handleOpen: url)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }

}


