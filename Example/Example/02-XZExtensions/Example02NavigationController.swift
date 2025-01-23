//
//  Example02NavigationController.swift
//  Example
//
//  Created by 徐臻 on 2025/1/23.
//

import UIKit

class Example02NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override var childForStatusBarStyle: UIViewController? {
        return self.presentedViewController ?? self.topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return self.presentedViewController ?? self.topViewController
    }

    
}
