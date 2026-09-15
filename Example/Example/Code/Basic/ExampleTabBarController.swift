//
//  ExampleTabBarController.swift
//  Example
//
//  Created by Mac on 2026/7/10.
//

import UIKit
import XZKit

class ExampleTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UITabBarAppearance.init()
        appearance.backgroundImage = UIImage(named: "icon-nav-background");
        appearance.shadowColor = .systemGray3
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }

}
