//
//  TabBarController.swift
//  Example
//
//  Created by mlibai on 2018/6/29.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.tintColor     = UIColor(0xea7653ff)

        let mainVC = XZKitViewController.init(style: .plain);
        let mainNavigationVC = NavigationController.init(rootViewController: mainVC);
        mainNavigationVC.tabBarItem.image           = UIImage(named: "icon_tab_home")
        mainNavigationVC.tabBarItem.selectedImage   = UIImage(named: "icon_tab_home_selected")
        mainNavigationVC.tabBarItem.title           = "XZKit"
        addChild(mainNavigationVC);
        
        let userVC = UIViewController.init()
        let userNavigationVC = NavigationController.init(rootViewController: userVC)
        userNavigationVC.tabBarItem.image           =  UIImage(named: "icon_tab_user")
        userNavigationVC.tabBarItem.selectedImage   =  UIImage(named: "icon_tab_user_selected")
        userNavigationVC.tabBarItem.title           = "Settings"
        addChild(userNavigationVC)
    }
    
    override func didRecevieRedirection(_ redirection: Any) -> UIViewController? {
        let url = redirection as! URL
        guard let host = url.host?.lowercased() else { return nil }
        switch host {
        case "xzkit":    self.selectedIndex = 0
        case "settings": self.selectedIndex = 1
        default:         break
        }
        return selectedViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
