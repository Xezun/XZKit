//
//  Example17BothViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/12.
//

import UIKit
import XZKit

class NavigationAppearance {
    var isHidden: Bool = false
    var isTranslucent: Bool = true
    var prefersLargeTitles: Bool = false
}

// 自定义功能的导航栈中，普通控制器与在普通的导航栈中没有任何区别的，但是对于声明遵循 XZNavigationBarCustomizable 定制化导航栏协议的控制器：。
// 1、导航栈自动根据定制化导航栏，配置原生导航栏状态。
// 2、定制化导航栏，将会覆盖在原生导航栏之上。
// 3、在转场完成之前，即 viewDidAppear 之前，直接对原生导航栏的操作（hidden/translucent/largeTitles），会被定制化导航栏配置的状态覆盖。
// 4、在转场之后，不论是直接操作原生导航栏，还是操作定制化导航栏，其作用和效果都是一样的。
//
// 声明遵循 XZNavigationGestureDrivable 将自动获得全屏手势导航的能力，当然默认只有返回，前进需要实现协议中的方法，且通过协议中的方法，
// 还可以控制手势返回的行为。
class Example17BothViewController: Example17OnlyViewController, XZNavigationBarCustomizable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title         = "定制页"
        navigationBar.barTintColor  = .brown
        navigationBar.isTranslucent = true
        navigationBar.backTitle     = "返回"
    }
    
    func navigationController(_ navigationController: UINavigationController, edgeInsetsForGestureNavigation operation: UINavigationController.Operation) -> NSDirectionalEdgeInsets? {
        return operation == .push ? nil : .init(top: 0, leading: 15, bottom: 0, trailing: 15)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navigationController = navigationController else { return }
        #XZLog("\(self.navigationBar.title!): \(navigationController.viewControllers.count)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let navigationController = navigationController else { return }
        #XZLog("\(self.navigationBar.title!): \(navigationController.viewControllers.count)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let navigationController = navigationController else { return }
        #XZLog("\(self.navigationBar.title!): \(navigationController.viewControllers.count)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let navigationController = navigationController else { return }
        #XZLog("\(self.navigationBar.title!): \(navigationController.viewControllers.count)")
    }
    
}

