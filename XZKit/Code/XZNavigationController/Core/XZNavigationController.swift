//
//  XZNavigationController.swift
//  XZKit
//
//  Created by Xezun on 2017/2/17.
//  Copyright © 2017年 Xezun Individual. All rights reserved.
//

import UIKit
import XZDefines
import ObjectiveC

/// 为导航控制器 UINavigationController 提供 自定义全屏手势 功能和 自定义导航条 功能的协议。
///
/// 当导航控制器开启自定义功能后：
/// 1. 栈内控制器可通过协议 `XZNavigationBarCustomizable` 自定义导航条。
/// 2. 边缘返回手势默认开启，但可通过协议 `XZNavigationGestureDrivable` 控制手势导航行为，或开启全屏手势。
/// 3. 导航控制器原生的自定义转场效果功能，虽然与原生开起来一样，但是如果开发者需自定义转场效果的话，需考虑自定义导航条的转场效果。
@MainActor public protocol XZNavigationController: UINavigationController {

}

extension XZNavigationController {
    
    /// 开启自定义模式。
    /// - Note: 因为会访问的控制器的 view 属性，请在 viewDidLoad 之后再设置此属性。
    public var isCustomizable: Bool {
        get {
            return self.transitionController != nil
        }
        set {
            if let transitionController = self.transitionController {
                if !newValue {
                    self.transitionController = nil
                    self.navigationBar.isCustomizable = false
                    self.interactivePopGestureRecognizer?.isEnabled = true
                    transitionController.interactiveNavigationGestureRecognizer.isEnabled = false
                    
                    self.navigationBar.navigationBar = nil
                }
            } else if newValue {
                let transitionController = XZNavigationControllerTransitionController.init(for: self)
                self.transitionController = transitionController
                
                // 关于原生手势
                // 即使重写属性 interactivePopGestureRecognizer 也不能保证原生的返回手势不会被创建，所以我们创建了新的手势，并设置了优先级。
                self.navigationBar.isCustomizable = true
                if let popGestureRecognizer = self.interactivePopGestureRecognizer {
                    popGestureRecognizer.isEnabled = false
                    popGestureRecognizer.require(toFail: transitionController.interactiveNavigationGestureRecognizer)
                }
                
                let aClass = type(of: self)
                if objc_getAssociatedObject(aClass, &_naviagtionController) == nil {
                    objc_setAssociatedObject(aClass, &_naviagtionController, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                        
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, UIViewController, Bool) -> Void
                        // 导航控制器，同一控制器不能重复 push 不论栈顶还是栈中，否则崩溃，所以这里不需要判断。
                        // 在 push 方法调用的过程中，目标控制器没有任何生命周期函数被调用，所以可以在 super.push 之后再执行转场准备工作。
                        let selector = #selector(UINavigationController.pushViewController(_:animated:));
                        let override: MethodType = { `self`, viewController, animated in
                            xz_navc_navigationController(self, customizeViewController: viewController)
                            xz_objc_msgSendSuper(self, v: selector, o: viewController, b: animated)
                            xz_navc_navigationController(self, prepareForTransitioning: animated)
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, viewController, animated in
                                xz_navc_navigationController(self, customizeViewController: viewController)
                                xz_objc_msgSend(self, v: selector, o: viewController, b: animated)
                                xz_navc_navigationController(self, prepareForTransitioning: animated)
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(aClass, selector, nil, nil, override, exchange)
                    }
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, [UIViewController], Bool) -> Void
                        
                        let selector = #selector(UINavigationController.setViewControllers(_:animated:));
                        let override: MethodType = { `self`, viewControllers, animated in
                            for viewController in viewControllers {
                                xz_navc_navigationController(self, customizeViewController: viewController)
                            }
                            let topViewController = self.topViewController
                            xz_objc_msgSendSuper(self, v: selector, o: viewControllers, b: animated)
                            if topViewController != viewControllers.last { // 说明发生了转场
                                xz_navc_navigationController(self, prepareForTransitioning: animated)
                            }
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, viewControllers, animated in
                                for viewController in viewControllers {
                                    xz_navc_navigationController(self, customizeViewController: viewController)
                                }
                                let topViewController = self.topViewController
                                xz_objc_msgSend(self, v: selector, o: viewControllers, b: animated)
                                if topViewController != viewControllers.last {
                                    xz_navc_navigationController(self, prepareForTransitioning: animated)
                                }
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(aClass, selector, nil, nil, override, exchange)
                    }
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, Bool) -> UIViewController?
                        
                        let selector = #selector(UINavigationController.popViewController(animated:));
                        let override: MethodType = { `self`, animated in
                            let viewController = xz_objc_msgSendSuper(self, o: selector, b: animated) as? UIViewController;
                            if viewController != nil {
                                xz_navc_navigationController(self, prepareForTransitioning: animated)
                            }
                            return viewController
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, animated in
                                let viewController = xz_objc_msgSend(self, o: selector, b: animated) as? UIViewController
                                if viewController != nil {
                                    xz_navc_navigationController(self, prepareForTransitioning: animated)
                                }
                                return viewController
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(aClass, selector, nil, nil, override, exchange)
                    }
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, UIViewController, Bool) -> [UIViewController]?
                        
                        let selector = #selector(UINavigationController.popToViewController(_:animated:));
                        let override: MethodType = { `self`, viewController, animated in
                            let viewControllers = xz_objc_msgSendSuper(self, o: selector, o: viewController, b: animated) as? [UIViewController]
                            if let viewControllers = viewControllers, viewControllers.count > 0 {
                                xz_navc_navigationController(self, prepareForTransitioning: animated)
                            }
                            return viewControllers
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, viewController, animated in
                                let viewControllers = xz_objc_msgSend(self, o: selector, o: viewController, b: animated) as? [UIViewController]
                                if let viewControllers = viewControllers, viewControllers.count > 0 {
                                    xz_navc_navigationController(self, prepareForTransitioning: animated)
                                }
                                return viewControllers
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(aClass, selector, nil, nil, override, exchange)
                    }
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, Bool) -> [UIViewController]?
                        
                        let selector = #selector(UINavigationController.popToRootViewController(animated:));
                        let override: MethodType = { `self`, animated in
                            let viewControllers = xz_objc_msgSendSuper(self, o: selector, b: animated) as? [UIViewController]
                            if let viewControllers = viewControllers, viewControllers.count > 0 {
                                xz_navc_navigationController(self, prepareForTransitioning: animated)
                            }
                            return viewControllers
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, animated in
                                let viewControllers = xz_objc_msgSend(self, o: selector, b: animated) as? [UIViewController]
                                if let viewControllers = viewControllers, viewControllers.count > 0 {
                                    xz_navc_navigationController(self, prepareForTransitioning: animated)
                                }
                                return viewControllers
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(aClass, selector, nil, nil, override, exchange)
                    }
                }
                
                // 栈内控制启用自定义功能
                for viewController in viewControllers {
                    xz_navc_navigationController(self, customizeViewController: viewController)
                }
                
                // 因为非自定义模式，转场走的时原生的逻辑，因此即使在转场过程被调用，如下处理也是没有问题的。
                if let navigationBar = (topViewController as? XZNavigationBarCustomizable)?.navigationBarIfLoaded {
                    self.navigationBar.isHidden           = navigationBar.isHidden
                    self.navigationBar.isTranslucent      = navigationBar.isTranslucent
                    self.navigationBar.prefersLargeTitles = navigationBar.prefersLargeTitles
                    self.navigationBar.navigationBar      = navigationBar
                }
                
            }
        }
    }
    
    /// 自定义的转场效果：处理全屏手势和自定义导航条的转场。
    public private(set) var transitionController: XZNavigationControllerTransitionController? {
        get {
            return objc_getAssociatedObject(self, &_transitionController) as? XZNavigationControllerTransitionController
        }
        set {
            objc_setAssociatedObject(self, &_transitionController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

// 以下方法，不写成 category 的原因，是因为这些方法并不属于一般特性，仅适合在当前环境下使用。

/// 向控制器的 viewWillAppear/viewDidAppear 中注入代码。
@MainActor fileprivate func xz_navc_navigationController(_ navigationController: UINavigationController, customizeViewController viewController: UIViewController) {
    guard navigationController is XZNavigationController else {
        return
    }
    let aClass = type(of: viewController)
    guard objc_getAssociatedObject(aClass, &_viewController) == nil else { return }
    objc_setAssociatedObject(aClass, &_viewController, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    guard viewController is XZNavigationBarCustomizable else { return }
    
    // 注入 viewWillAppear 用以更新导航条状态
    do {
        typealias MethodType = @convention(block) (UIViewController, Bool) -> Void
        
        let selector = #selector(UIViewController.viewWillAppear(_:))
        let override: MethodType = { `self`, animated in
            xz_objc_msgSendSuper(self, v: selector, b: animated)
            xz_navc_viewController(self, viewWillAppear: animated)
        }
        let exchange = { (selector: Selector) in
            let exchange: MethodType = { `self`, animated in
                xz_objc_msgSend(self, v: selector, b: animated)
                xz_navc_viewController(self, viewWillAppear: animated)
            }
            return exchange
        }
        xz_objc_class_addMethodWithBlock(aClass, selector, nil, nil, override, exchange)
    }
    
    do {
        typealias MethodType = @convention(block) (UIViewController, Bool) -> Void
        
        let selector = #selector(UIViewController.viewDidAppear(_:))
        let override: MethodType = { `self`, animated in
            xz_objc_msgSendSuper(self, v: selector, b: animated)
            xz_navc_viewController(self, viewDidAppear: animated)
        }
        let exchange = { (selector: Selector) in
            let exchange: MethodType = { `self`, animated in
                xz_objc_msgSend(self, v: selector, b: animated)
                xz_navc_viewController(self, viewDidAppear: animated)
            }
            return exchange
        }
        xz_objc_class_addMethodWithBlock(aClass, selector, nil, nil, override, exchange)
    }
}

/// 转场开始，自定义导航条与原生导航条解除绑定。转场过程中的导航条操作，最终会在 viewWillAppear 的注入逻辑覆盖。
@MainActor fileprivate func xz_navc_navigationController(_ navigationController: UINavigationController, prepareForTransitioning animated: Bool) {
    navigationController.navigationBar.navigationBar = nil
}


/// 转场已开始，转场动画即将开始：更新导航条样式。
/// - Attention: This method is private, do not use it directly.
@MainActor fileprivate func xz_navc_viewController(_ viewController: UIViewController, viewWillAppear animated: Bool) {
    //print("\(type(of: viewController)).\(#function) \(animated)")
    guard let navigationController = viewController.navigationController as? XZNavigationController else {
        return
    }
    guard navigationController.isCustomizable == true else {
        return
    }
    guard let viewController = viewController as? XZNavigationBarCustomizable else {
        return
    }
    guard let customNavigationBar = viewController.navigationBarIfLoaded else {
        return
    }
    
    let navigationBar = navigationController.navigationBar
    if navigationBar.isTranslucent != customNavigationBar.isTranslucent {
        navigationBar.isTranslucent = customNavigationBar.isTranslucent
    }
    if navigationBar.prefersLargeTitles != customNavigationBar.prefersLargeTitles {
        navigationBar.prefersLargeTitles = customNavigationBar.prefersLargeTitles
    }
    if navigationController.isNavigationBarHidden != customNavigationBar.isHidden {
        navigationController.setNavigationBarHidden(customNavigationBar.isHidden, animated: animated)
    }
}

/// 转场完成，自定义导航条与原生导航条绑定。任何对原生导航条的操作，都会保存到自定义导航条上，并用于下一次转场。
@MainActor fileprivate func xz_navc_viewController(_ viewController: UIViewController, viewDidAppear animated: Bool) {
    guard let navigationController = viewController.navigationController as? XZNavigationController else {
        return
    }
    guard navigationController.isCustomizable == true else {
        return
    }
    navigationController.navigationBar.navigationBar = (viewController as? XZNavigationBarCustomizable)?.navigationBarIfLoaded
}

/// 记录控制器是否进行了自定义化
@MainActor private var _viewController = 0
/// 记录导航控制器是否进行了自定义化
@MainActor private var _naviagtionController = 0
/// 保存自定义转场控制。
@MainActor private var _transitionController = 0

// 【开发备忘】
// 为了将更新导航条的操作放在 viewWillAppear 中：
// 一、 用 Swift 方法交换，重写基类 UIViewController 的 viewWillAppear 方法，遇到以下问题：
//      1. 某些页面，交换后的方法不执行，可能是因为 Swift 消息派发机制，没有把方法按 objc 消息派发造成的。
//      2. 在基类中添加的代码，在自类用户的代码之前执行，所以页面导航条状态可以被用户修改，没有按照自定义导航条的配置来展示。
//      3. 重写基类 UIViewController 影响会所有的控制器。
// 二、重写 UINavigationController 的 addChildViewController 方法。
//      1. 控制器入栈，不会调用这个方法，即栈内控制器不是导航控制器的子控制器。
// 三、监听 viewControllers 属性
//      1. KVO 可能不会触发
// 最终采用的方案：
// 注入导航控制器的所有入栈方法和出栈方法（属性 isCustomizable 被设置为 true 时），
// 在控制器入栈时，向控制器 viewWillAppear/viewDidAppear 注入代码，这样就只影响控制器本身。
//
// 【已知问题一】
// 如下操作会导致自定义导航条丢失。
// ```swift
// if let navigationController = navigationController {
//    let viewControllers = navigationController.viewControllers
//    navigationController.setViewControllers([], animated: false)
//    navigationController.setViewControllers(viewControllers, animated: false)
// }
// ```
// 因为 set 操作时，XZNavigationController 认为是转场开始而移除了自定义导航条，
// 但是 UINavigationController 在处理这种情形时，认为没有转场发生，所以最终也没有 viewDidAppear 执行，
// 自定义导航条没有机会展示。
// 这说明，在 UINavigationController 中，方法 setViewControllers 实际是有延迟的。
// 如果确实有这种逻辑需求，可以延迟第二次操作，来避免这个问题。
//
// 【已知问题二】
// 在 UITabBarController 中时，tabBar 只在首页显示，如果手势**跨层**返回首页，那么 tabBar 没有动画转场动画，
// 即没有从场外进场的过程，而是直接显示在底部，覆盖在转场的控制器之上。
// 但是由于问题三的原因，如果转场取消一次，栈内只留下了栈顶和栈底控制器，再次手势返回的话，由于没有跨层 tabBar 就又有了转场动画。
// 目前，重写 tabBar 的动画效果只在 Right-to-Left 的布局环境下生效，虽然在 left-to-right 布局下开启可以开启解决这个问题，但是觉得没有必要。
//
// 【已知问题三】
// 在使用 `-popToViewController:animated:` 进行手势跨层 pop 时，那么被 popTo 跨过的页面
// 会被导航栈移除，且手势取消了操作，导航栈也不会恢复。
// 这 BUG 是原生的，虽然可以尝试修复，但觉得没有必要。
// 因为已经使用 `popTo` 跨层了，那说明，被跨的层，在业务逻辑中，大概率属于不可返回的页面，没有恢复的必要。
//
