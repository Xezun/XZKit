//
//  Example17NavigationController.swift
//  Example
//
//  Created by 徐臻 on 2024/6/16.
//

import UIKit
import XZNavigationController

// 导航控制器声明遵循 XZNavigationController 协议。
// 推荐使用自定义的导航条控制器，当然也可以直接给 UINavigationController 进行声明，
// 且对于那些没有使用自定义导航条的导航控制器来说，也没有任何副作用，但这不利于我们控制代码维护，
// 因为后续维护代码的人，可能并不知道遵循了协议的导航栈，是否使用了这个功能。
// 协议 XZNavigationController 没有任何方法或属性需要实现，因为它是一个拓展功能的协议，遵循它可以获得额外属性。
class Example17NavigationController: UINavigationController, XZNavigationController {
    
    deinit {
        print("\(type(of: self)) \(#function) successfully")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        // 打开了自定义开关，XZNavigationController 所提供的功能才会生效，除此之外，也不需要其它任何操作。
        self.isCustomizable  = true
    }
    
    // 以下为调试代码。
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        print("\(#function) \(vc)")
        super.show(vc, sender: sender)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        print("\(#function) \(viewController)")
        super.pushViewController(viewController, animated: animated)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        print("\(#function) \(viewControllers.count)")
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override var viewControllers: [UIViewController] {
        willSet {
            print("\(#function).setter \(newValue.count)")
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        print("\(#function) \(animated)")
        return super.popViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        print("\(#function) \(viewController)")
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        print("\(#function) \(animated)")
        return super.popToRootViewController(animated: animated)
    }

}
