//
//  XZNavigationController.swift
//  XZKit
//
//  Created by Xezun on 2017/2/17.
//  Copyright © 2017年 Xezun Individual. All rights reserved.
//

import UIKit
import ObjectiveC

/// 为导航控制器提供定制导航手势、导航栏功能的协议。
///
/// 遵循此协议的导航控制器，可获得``isNavigationCustomizable``属性，以开启导航定制化功能。
/// 1. 栈内控制器可通过协议``XZNavigationBarCustomizable``定制导航栏。
/// 2. 栈内控制器可通过协议``XZNavigationGestureDrivable``定制导航手势，开启全屏手势，或区域手势导航，默认开启边缘手势返回导航。
/// 3. 导航控制器原生的自定义转场效果功能，虽然与原生开起来一样，但是如果开发者需自定义转场效果的话，需考虑定制化导航栏的转场效果。
///
/// ### 已知问题
/// 1. 由于原生导航栏层级比转场视图高，所以从原生导航栏与定制化导航栏互相转场时，原生导航栏若不透明，则会遮挡住转场过程的阴影。
/// > 该问题影响相对较小，暂不处理。
/// 2. 在交互式 pop 转场时，tabBar 的状态，由隐藏到显示，当转场被中途取消时，tabBar 理论上应恢复隐藏，但是 iOS 26 存在系统缺陷，第一次取消转场 tabBar 能正常恢复隐藏，但第二次及之后再取消转场，虽然 tabBar 是隐藏的，但是 tabBar 的液态玻璃效果的图层会残留下来。
/// > 该问题至少在 iOS 26.5 系统中尚未修复，由于影响不大，目前不做任何处理。
@MainActor public protocol XZNavigationController: UINavigationController {
    
}

extension XZNavigationController {
    
    /// 导航定制化是否已启用。
    ///
    /// 开启导航定制化，栈内控制器可以自定义独属于控制器的导航栏，自定义导航手势。
    ///
    /// > 因为会访问的控制器的`view`属性，请在`viewDidLoad`之中或之后，再设置此属性。
    ///
    /// 推荐在导航控制器`UINavigationController`子类的`viewDidLoad`方法中开启此属性。
    public var isNavigationCustomizable: Bool {
        get {
            return self.transitionController != nil
        }
        set {
            // transitionController 是支持自定义的转场控制器，所以。
            // 如果 transitionController 属性已经有值，说明已经支持自定义，否则不支持。
            if let transitionController = self.transitionController {
                if !newValue {
                    self.transitionController = nil
                    self.interactivePopGestureRecognizer?.isEnabled = true
#if compiler(>=6.2)
                    if #available(iOS 26.0, *) {
                        self.interactiveContentPopGestureRecognizer?.isEnabled = true
                    }
#endif // compiler(>=6.2)
                    transitionController.interactiveNavigationGestureRecognizer.isEnabled = false
                    
                    self.view.supportsNavigationCustomization = false;
                    self.navigationBar.supportsNavigationCustomization = false;
                    self.tabBarController?.tabBar.supportsNavigationCustomization = false;
                    
                    self.xzNavigationBar = nil;
                }
            } else if newValue {
                // 定制转场
                let transitionController = XZNavigationTransitionController.init(for: self)
                self.transitionController = transitionController
                
                // 即使重写属性，也不能保证原生的返回手势不会被创建，所以需要创建了新的手势，并设置了优先级。
                if let popGestureRecognizer = self.interactivePopGestureRecognizer {
                    popGestureRecognizer.isEnabled = false
                    popGestureRecognizer.require(toFail: transitionController.interactiveNavigationGestureRecognizer)
                }
#if compiler(>=6.2)
                if #available(iOS 26.0, *) {
                    if let interactiveContentPopGestureRecognizer = self.interactiveContentPopGestureRecognizer {
                        interactiveContentPopGestureRecognizer.isEnabled = false;
                        interactiveContentPopGestureRecognizer.require(toFail: transitionController.interactiveNavigationGestureRecognizer)
                    }
                }
#endif // compiler(>=6.2)
                
                // 让各部件支持定制化导航。
                self.supportsNavigationCustomization = true;
                self.view.supportsNavigationCustomization = true;
                self.navigationBar.supportsNavigationCustomization = true;
                self.tabBarController?.tabBar.supportsNavigationCustomization = true;
                // 站内控制器支持定制化导航。
                for viewController in viewControllers {
                    viewController.supportsNavigationCustomization = true
                }
                
                // 因为非自定义模式，转场走的时原生的逻辑，因此即使在转场过程被调用，如下处理也是没有问题的。
                if let navigationBar = (topViewController as? XZNavigationBarCustomizable)?.xzNavigationBar {
                    self.navigationBar.isHidden           = navigationBar.isHidden
                    self.navigationBar.isTranslucent      = navigationBar.isTranslucent
                    self.navigationBar.prefersLargeTitles = navigationBar.prefersLargeTitles
                    self.xzNavigationBar                  = navigationBar;
                }
            }
        }
    }
    
    /// 自定义的转场效果：处理全屏手势和定制化导航栏的转场。
    public private(set) var transitionController: XZNavigationTransitionController? {
        get {
            return objc_getAssociatedObject(self, &_transitionController) as? XZNavigationTransitionController
        }
        set {
            objc_setAssociatedObject(self, &_transitionController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension UIResponder {
    
    /// 是否支持导航定制化。
    ///
    /// 当导航控制器开启定制导航功能之后，部分视图、控制器的此属性会变为`true`以支持导航定制化。
    @objc public internal(set) var supportsNavigationCustomization: Bool {
        get {
            return false;
        }
        set {
            fatalError("[XZKit][XZNavigationController] Navigation Customization Not Supported on this object \(self)")
        }
    }
    
}

/// 保存定制化转场控制器的标记。
@MainActor private var _transitionController = 0


// 【开发备忘】
// 为了将更新导航栏的操作放在 viewWillAppear 中：
// 一、 用 Swift 方法交换，重写基类 UIViewController 的 viewWillAppear 方法，遇到以下问题：
//      1. 某些页面，交换后的方法不执行，可能是因为 Swift 消息派发机制，没有把方法按 objc 消息派发造成的。
//      2. 在基类中添加的代码，在自类用户的代码之前执行，所以页面导航栏状态可以被用户修改，没有按照定制化导航栏的配置来展示。
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
// 如下操作会导致定制化导航栏丢失。
// ```swift
// if let navigationController = navigationController {
//    let viewControllers = navigationController.viewControllers
//    navigationController.setViewControllers([], animated: false)
//    navigationController.setViewControllers(viewControllers, animated: false)
// }
// ```
// 因为 set 操作时，XZNavigationController 认为是转场开始而移除了定制化导航栏，
// 但是 UINavigationController 在处理这种情形时，认为没有转场发生，所以最终也没有 viewDidAppear 执行，
// 定制化导航栏没有机会展示。
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
