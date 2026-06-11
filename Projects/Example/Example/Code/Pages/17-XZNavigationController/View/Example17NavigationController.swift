//
//  Example17NavigationController.swift
//  Example
//
//  Created by Xezun on 2024/6/16.
//

import UIKit
import XZKit

// 导航控制器声明遵循 XZNavigationController 协议。
// 推荐使用自定义的导航栏控制器，当然也可以直接给 UINavigationController 进行声明，
// 且对于那些没有使用定制化导航栏的导航控制器来说，也没有任何副作用，但这不利于我们控制代码维护，
// 因为后续维护代码的人，可能并不知道遵循了协议的导航栈，是否使用了这个功能。
// 协议 XZNavigationController 没有任何方法或属性需要实现，因为它是一个拓展功能的协议，遵循它可以获得额外属性。
class Example17NavigationController: UINavigationController, XZNavigationController {
    
    deinit {
        //print("\(type(of: self)) \(#function) successfully")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance.init()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.init(white: 1.0, alpha: 0.7)
        appearance.shadowColor = rgb(0xBCBCBC)
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
        
        // 开启导航定制化。
        self.isNavigationCustomizable = true
    }
    
    // 以下为调试代码。
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let tabBarController = self.tabBarController else { return }
        #XZLog("isBeingPresented: %@, modalPresentationStyle: %@", tabBarController.isBeingPresented, tabBarController.modalPresentationStyle as! CVarArg)
    }
    
    override func show(_ viewController: UIViewController, sender: Any?) {
        #XZLog("viewController: %@", viewController)
        super.show(viewController, sender: sender)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        #XZLog("viewController: %@", viewController)
        super.pushViewController(viewController, animated: animated)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        #XZLog("viewControllers: %@", viewControllers)
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override var viewControllers: [UIViewController] {
        willSet {
            #XZLog("viewControllers.setter: %ld", newValue.count)
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        #XZLog("animated: %@", animated);
        return super.popViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        #XZLog("viewController: %@", viewController)
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        #XZLog("animated: %@", animated);
        return super.popToRootViewController(animated: animated)
    }

}
