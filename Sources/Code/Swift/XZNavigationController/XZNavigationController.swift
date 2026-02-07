//
//  XZNavigationController.swift
//  XZKit
//
//  Created by Xezun on 2017/2/17.
//  Copyright © 2017年 Xezun Individual. All rights reserved.
//

import UIKit
import ObjectiveC

/// 为导航控制器提供定制导航手势、导航条功能的协议。
///
/// 遵循此协议的导航控制器，可获得``isNavigationCustomizable``属性，以开启导航定制化功能。
/// 1. 栈内控制器可通过协议``XZNavigationBarCustomizable``定制导航条。
/// 2. 栈内控制器可通过协议``XZNavigationGestureDrivable``定制导航手势，开启全屏手势，或区域手势导航，默认开启边缘手势返回导航。
/// 3. 导航控制器原生的自定义转场效果功能，虽然与原生开起来一样，但是如果开发者需自定义转场效果的话，需考虑自定义导航条的转场效果。
@MainActor public protocol XZNavigationController: UINavigationController {
    
}

extension XZNavigationController {
    
    /// 否支持导航条、导航手势定制化。
    ///
    /// 因为会访问的控制器的`view`属性，请在`viewDidLoad`之中或之后，再设置此属性。
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
                    if #available(iOS 26.0, *) {
                        self.interactiveContentPopGestureRecognizer?.isEnabled = true
                    }
                    transitionController.interactiveNavigationGestureRecognizer.isEnabled = false
                    
                    self.view.supportsNavigationCustomization = false;
                    self.navigationBar.supportsNavigationCustomization = false;
                    self.tabBarController?.tabBar.supportsNavigationCustomization = false;
                    
                    self.xzNavigationBar = nil;
                }
            } else if newValue {
                let transitionController = XZNavigationTransitionController.init(for: self)
                self.transitionController = transitionController
                
                // 让视图支持导航定制化
                self.view.supportsNavigationCustomization = true;
                self.navigationBar.supportsNavigationCustomization = true;
                self.tabBarController?.tabBar.supportsNavigationCustomization = true;
                
                // 关于原生手势
                // 即使重写属性 interactivePopGestureRecognizer 也不能保证原生的返回手势不会被创建，所以我们创建了新的手势，并设置了优先级。
                if let popGestureRecognizer = self.interactivePopGestureRecognizer {
                    popGestureRecognizer.isEnabled = false
                    popGestureRecognizer.require(toFail: transitionController.interactiveNavigationGestureRecognizer)
                }
                if #available(iOS 26.0, *) {
                    if let interactiveContentPopGestureRecognizer = self.interactiveContentPopGestureRecognizer {
                        interactiveContentPopGestureRecognizer.isEnabled = false;
                        interactiveContentPopGestureRecognizer.require(toFail: transitionController.interactiveNavigationGestureRecognizer)
                    }
                }
                
                // 向导航入栈出栈的方法中注入代码：1，让入栈的控制器支持自定义导航条；2，让导航控制器进入执行转场准备操作。
                let NavcClass = type(of: self)
                if objc_getAssociatedObject(NavcClass, &_naviagtionController) == nil {
                    objc_setAssociatedObject(NavcClass, &_naviagtionController, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, UIViewController, Bool) -> Void
                        // 导航控制器，同一控制器不能重复 push 不论栈顶还是栈中，否则崩溃，所以这里不需要判断。
                        // 在 push 方法调用的过程中，目标控制器没有任何生命周期函数被调用，所以可以在 super.push 之后再执行转场准备工作。
                        let selector = #selector(UINavigationController.pushViewController(_:animated:));
                        let override: MethodType = { `self`, viewController, animated in
                            xz_navc_navigationController(self, customizeViewController: viewController);
                            xz_objc_msgSendSuper_void(self, NavcClass, selector, viewController, animated);
                            xz_navc_navigationController(self, prepareForTransitioning: animated);
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, viewController, animated in
                                xz_navc_navigationController(self, customizeViewController: viewController);
                                xz_objc_msgSend_void(self, selector, viewController, animated);
                                xz_navc_navigationController(self, prepareForTransitioning: animated);
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(NavcClass, selector, nil, nil, override, exchange)
                    }
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, [UIViewController], Bool) -> Void
                        
                        let selector = #selector(UINavigationController.setViewControllers(_:animated:));
                        let override: MethodType = { `self`, viewControllers, animated in
                            for viewController in viewControllers {
                                xz_navc_navigationController(self, customizeViewController: viewController)
                            }
                            let topViewController = self.topViewController
                            xz_objc_msgSendSuper_void(self, NavcClass, selector, viewControllers, animated)
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
                                xz_objc_msgSend_void(self, selector, viewControllers, animated)
                                if topViewController != viewControllers.last {
                                    xz_navc_navigationController(self, prepareForTransitioning: animated)
                                }
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(NavcClass, selector, nil, nil, override, exchange)
                    }
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, Bool) -> UIViewController?
                        
                        let selector = #selector(UINavigationController.popViewController(animated:));
                        let override: MethodType = { `self`, animated in
                            let viewController = xz_objc_msgSendSuper_id(self, NavcClass, selector, animated) as? UIViewController;
                            if viewController != nil {
                                xz_navc_navigationController(self, prepareForTransitioning: animated)
                            }
                            return viewController
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, animated in
                                let viewController = xz_objc_msgSend_id(self, selector, animated) as? UIViewController
                                if viewController != nil {
                                    xz_navc_navigationController(self, prepareForTransitioning: animated)
                                }
                                return viewController
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(NavcClass, selector, nil, nil, override, exchange)
                    }
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, UIViewController, Bool) -> [UIViewController]?
                        
                        let selector = #selector(UINavigationController.popToViewController(_:animated:));
                        let override: MethodType = { `self`, viewController, animated in
                            let viewControllers = xz_objc_msgSendSuper_id(self, NavcClass, selector, viewController, animated) as? [UIViewController]
                            if let viewControllers = viewControllers, viewControllers.count > 0 {
                                xz_navc_navigationController(self, prepareForTransitioning: animated)
                            }
                            return viewControllers
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, viewController, animated in
                                let viewControllers = xz_objc_msgSend_id(self, selector, viewController, animated) as? [UIViewController]
                                if let viewControllers = viewControllers, viewControllers.count > 0 {
                                    xz_navc_navigationController(self, prepareForTransitioning: animated)
                                }
                                return viewControllers
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(NavcClass, selector, nil, nil, override, exchange)
                    }
                    
                    do {
                        typealias MethodType = @convention(block) (UINavigationController, Bool) -> [UIViewController]?
                        
                        let selector = #selector(UINavigationController.popToRootViewController(animated:));
                        let override: MethodType = { `self`, animated in
                            let viewControllers = xz_objc_msgSendSuper_id(self, NavcClass, selector, animated) as? [UIViewController]
                            if let viewControllers = viewControllers, viewControllers.count > 0 {
                                xz_navc_navigationController(self, prepareForTransitioning: animated)
                            }
                            return viewControllers
                        }
                        let exchange = { (selector: Selector) in
                            let exchange: MethodType = { `self`, animated in
                                let viewControllers = xz_objc_msgSend_id(self, selector, animated) as? [UIViewController]
                                if let viewControllers = viewControllers, viewControllers.count > 0 {
                                    xz_navc_navigationController(self, prepareForTransitioning: animated)
                                }
                                return viewControllers
                            }
                            return exchange
                        }
                        
                        xz_objc_class_addMethodWithBlock(NavcClass, selector, nil, nil, override, exchange)
                    }
                }
                
                // 开启栈内已有控制器的自定义导航条支持功能
                for viewController in viewControllers {
                    xz_navc_navigationController(self, customizeViewController: viewController)
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
    
    /// 自定义的转场效果：处理全屏手势和自定义导航条的转场。
    public private(set) var transitionController: XZNavigationTransitionController? {
        get {
            return objc_getAssociatedObject(self, &_transitionController) as? XZNavigationTransitionController
        }
        set {
            objc_setAssociatedObject(self, &_transitionController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension UINavigationController {
    
    /// 当前的自定义导航条。
    public internal(set) var xzNavigationBar: XZNavigationBar? {
        get {
            return objc_getAssociatedObject(self.view!, &_navigationBar) as? XZNavigationBar
        }
        set {
            // 移除旧的
            if let oldValue = self.xzNavigationBar {
                oldValue.uiNavigationBar = nil;
                oldValue.removeFromSuperview()
            }

            // 记录新值
            objc_setAssociatedObject(self.view!, &_navigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // 添加新的
            if let newValue = newValue {
                newValue.frame = self.navigationBar.frame;
                newValue.uiNavigationBar = self.navigationBar;
                // 使用 autoresizing 布局，自定义导航条的 frame 会在父视图变化时改变，
                // 而自定义导航条父视图，在转场时会发生改变。
                self.view.addSubview(newValue)
            }
            
            // 将值同步到原生导航条
            self.navigationBar.xzNavigationBar = newValue;
        }
    }
    
}

/// 在导航栈内控制器的 viewWillAppear 方法中注入的代码。
///
/// 当此方法执行时，表明转场已开始，但是转场动画还未执行。
///
/// 以在转场动画前，将自定义导航条的配置，同步到原生导航条，以保证在执行转场动画时，目标控制器的安全区设置正确。
///
/// 此方法在用户的代码之后执行，以覆盖用户对原生导航条的操作，保证原生导航条按照自定义导航条的设置运行。
@MainActor fileprivate func xz_navc_viewController(_ viewController: UIViewController, viewWillAppear animated: Bool) {
    guard let navigationController = viewController.navigationController as? XZNavigationController else {
        return
    }
    guard navigationController.isNavigationCustomizable == true else {
        return
    }
    guard let viewController = viewController as? XZNavigationBarCustomizable else {
        return
    }
    guard let xzNavigationBar = viewController.xzNavigationBar else {
        return
    }
    
    let uiNavigationBar = navigationController.navigationBar
    if uiNavigationBar.isTranslucent != xzNavigationBar.isTranslucent {
        uiNavigationBar.isTranslucent = xzNavigationBar.isTranslucent
    }
    if uiNavigationBar.prefersLargeTitles != xzNavigationBar.prefersLargeTitles {
        uiNavigationBar.prefersLargeTitles = xzNavigationBar.prefersLargeTitles
    }
    if navigationController.isNavigationBarHidden != xzNavigationBar.isHidden {
        navigationController.setNavigationBarHidden(xzNavigationBar.isHidden, animated: animated)
    }
}

/// 在导航栈内控制器的 viewDidAppear 方法中注入的代码。
///
/// 转场完成，自定义导航条与原生导航条绑定。任何对原生导航条的操作，都会保存到自定义导航条上，并用于下一次转场。
@MainActor fileprivate func xz_navc_viewController(_ viewController: UIViewController, viewDidAppear animated: Bool) {
    guard let navigationController = viewController.navigationController as? XZNavigationController else {
        return
    }
    guard navigationController.isNavigationCustomizable else {
        return
    }
    let xzNavigationBar = (viewController as? XZNavigationBarCustomizable)?.xzNavigationBar;
    navigationController.xzNavigationBar = xzNavigationBar;
}

// 以下方法，不写成 category 的原因，是因为这些方法并不属于一般特性，仅适合在当前环境下使用。....

/// 向控制器的 viewWillAppear/viewDidAppear 中注入代码。
@MainActor fileprivate func xz_navc_navigationController(_ navigationController: UINavigationController, customizeViewController viewController: UIViewController) {
    guard navigationController is XZNavigationController else {
        return
    }
    let ViewControllerClass = type(of: viewController)
    guard objc_getAssociatedObject(ViewControllerClass, &_viewController) == nil else { return }
    objc_setAssociatedObject(ViewControllerClass, &_viewController, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    guard viewController is XZNavigationBarCustomizable else { return }
    
    // 注入 viewWillAppear 用以更新导航条状态
    do {
        typealias MethodType = @convention(block) (UIViewController, Bool) -> Void
        
        let selector = #selector(UIViewController.viewWillAppear(_:))
        let override: MethodType = { `self`, animated in
            xz_objc_msgSendSuper_void(self, ViewControllerClass, selector, animated)
            xz_navc_viewController(self, viewWillAppear: animated)
        }
        let exchange = { (selector: Selector) in
            let exchange: MethodType = { `self`, animated in
                xz_objc_msgSend_void(self, selector, animated)
                xz_navc_viewController(self, viewWillAppear: animated)
            }
            return exchange
        }
        xz_objc_class_addMethodWithBlock(ViewControllerClass, selector, nil, nil, override, exchange)
    }
    
    do {
        typealias MethodType = @convention(block) (UIViewController, Bool) -> Void
        
        let selector = #selector(UIViewController.viewDidAppear(_:))
        let override: MethodType = { `self`, animated in
            xz_objc_msgSendSuper_void(self, ViewControllerClass, selector, animated)
            xz_navc_viewController(self, viewDidAppear: animated)
        }
        let exchange = { (selector: Selector) in
            let exchange: MethodType = { `self`, animated in
                xz_objc_msgSend_void(self, selector, animated)
                xz_navc_viewController(self, viewDidAppear: animated)
            }
            return exchange
        }
        xz_objc_class_addMethodWithBlock(ViewControllerClass, selector, nil, nil, override, exchange)
    }
}

/// 转场开始，自定义导航条与原生导航条解除绑定。转场过程中的导航条操作，最终会在 viewWillAppear 的注入逻辑覆盖。
@MainActor fileprivate func xz_navc_navigationController(_ navigationController: UINavigationController, prepareForTransitioning animated: Bool) {
    navigationController.xzNavigationBar = nil;
}


extension UIView {
    
    // 视图是否支持导航定制化。
    @objc fileprivate var supportsNavigationCustomization: Bool {
        get {
            return false;
        }
        set {
            if newValue == self.supportsNavigationCustomization {
                return
            }
            
            if newValue {
                let oldClass = type(of: self);
                if let newClass = objc_getAssociatedObject(oldClass, &_navigationCustomizableClass) as? AnyClass {
                    object_setClass(self, newClass);
                } else {
                    let newClass: AnyClass = XZNavigationCustomizableClassCreate(oldClass);
                    objc_setAssociatedObject(oldClass, &_navigationCustomizableClass, newClass, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    object_setClass(self, newClass);
                }
            } else {
                object_setClass(self, self.superclass!)
            }
        }
    }
    
}

/// 为`superClass`派生一个支持定制化导航的子类。
private func XZNavigationCustomizableClassCreate(_ superClass: UIView.Type) -> AnyClass {
    if superClass is UINavigationBar.Type {
        return xz_objc_createClass(superClass) { NewClass in
            let SourceClass = XZNavigationCustomizableNavigationBar.self;
            xz_objc_class_addMethod(
                NewClass, #selector(getter: UINavigationBar.supportsNavigationCustomization),
                SourceClass, nil, #selector(getter: UINavigationBar.supportsNavigationCustomization), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UINavigationBar.center),
                SourceClass, nil, #selector(setter: UINavigationBar.center), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UINavigationBar.frame),
                SourceClass, nil, #selector(setter: UINavigationBar.frame), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UINavigationBar.bounds),
                SourceClass, nil, #selector(setter: UINavigationBar.bounds), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(getter: UINavigationBar.isHidden),
                SourceClass, nil, #selector(getter: UINavigationBar.isHidden), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UINavigationBar.isHidden),
                SourceClass, nil, #selector(setter: UINavigationBar.isHidden), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(getter: UINavigationBar.isTranslucent),
                SourceClass, nil, #selector(getter: UINavigationBar.isTranslucent), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UINavigationBar.isTranslucent),
                SourceClass, nil, #selector(setter: UINavigationBar.isTranslucent), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(getter: UINavigationBar.prefersLargeTitles),
                SourceClass, nil, #selector(getter: UINavigationBar.prefersLargeTitles), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UINavigationBar.prefersLargeTitles),
                SourceClass, nil, #selector(setter: UINavigationBar.prefersLargeTitles), nil
            );
        } as! UINavigationBar.Type
    }
    
    if superClass is UITabBar.Type {
        return xz_objc_createClass(superClass, { (NewClass) in
            let SourceClass = XZNavigationCustomizableTabBar.self
            xz_objc_class_addMethod(
                NewClass, #selector(getter: UITabBar.supportsNavigationCustomization),
                SourceClass, nil, #selector(getter: UITabBar.supportsNavigationCustomization), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UITabBar.frame),
                SourceClass, nil, #selector(setter: UITabBar.frame), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UITabBar.center),
                SourceClass, nil, #selector(setter: UITabBar.center), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UITabBar.bounds),
                SourceClass, nil, #selector(setter: UITabBar.bounds), nil
            );
            xz_objc_class_addMethod(
                NewClass, #selector(setter: UITabBar.isHidden),
                SourceClass, nil, #selector(setter: UITabBar.isHidden), nil
            );
        })
    }
    
    return xz_objc_createClass(superClass) { NewClass in
        let SourceClass = XZNavigationCustomizableView.self;
        xz_objc_class_addMethod(
            NewClass, #selector(getter: UIView.supportsNavigationCustomization),
            SourceClass, nil, #selector(getter: UIView.supportsNavigationCustomization), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(UIView.addSubview(_:)),
            SourceClass, nil, #selector(UIView.addSubview(_:)), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(UIView.bringSubviewToFront(_:)),
            SourceClass, nil, #selector(UIView.bringSubviewToFront(_:)), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(UIView.insertSubview(_:aboveSubview:)),
            SourceClass, nil, #selector(UIView.insertSubview(_:aboveSubview:)), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(UIView.insertSubview(_:at:)),
            SourceClass, nil, #selector(UIView.insertSubview(_:at:)), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(UIView.insertSubview(_:belowSubview:)),
            SourceClass, nil, #selector(UIView.insertSubview(_:belowSubview:)), nil
        );
    } as! UIView.Type
}


// 在 objc_msgSendSuper 中使用 self.class 获取当前对象的 Class 那么子类在调用这个方法时就会产生死循环。
// 但是在这里，实际使用的是动态派生的类，没有子类，可以不用考虑这个问题。

// 当向导航控制器根视图添加子视图时，保证自定义导航条始终显示在最上面。
private class XZNavigationCustomizableView: UIView {
    
    override var supportsNavigationCustomization: Bool {
        get {
            return true;
        }
        set {
            fatalError("此方法不会被调用")
        }
    }
    
    open override func addSubview(_ view: UIView) {
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(addSubview(_:)), view)
        
        guard let navigationController = self.next as? UINavigationController else { return }
        guard let navigationBar = navigationController.xzNavigationBar, navigationBar.superview == self else { return }
        guard view != navigationBar else { return }
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(bringSubviewToFront(_:)), navigationBar)
    }

    open override func bringSubviewToFront(_ view: UIView) {
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(bringSubviewToFront(_:)), view)
        
        guard let navigationController = self.next as? UINavigationController else { return }
        guard let navigationBar = navigationController.xzNavigationBar, navigationBar.superview == self else { return }
        guard view != navigationBar else { return }
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(bringSubviewToFront(_:)), navigationBar)
    }

    open override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(insertSubview(_:aboveSubview:)), view, siblingSubview)
        
        guard let navigationController = self.next as? UINavigationController else { return }
        guard let navigationBar = navigationController.xzNavigationBar, navigationBar.superview == self else { return }
        guard siblingSubview != navigationBar else { return }
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(bringSubviewToFront(_:)), navigationBar)
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(insertSubview(_:at:)), view, index)
        
        guard let navigationController = self.next as? UINavigationController else { return }
        guard let navigationBar = navigationController.xzNavigationBar, navigationBar.superview == self else { return }
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(bringSubviewToFront(_:)), navigationBar)
    }

    open override func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(insertSubview(_:belowSubview:)), view, siblingSubview)
        
        guard let navigationController = self.next as? UINavigationController else { return }
        guard let navigationBar = navigationController.xzNavigationBar, navigationBar.superview == self else { return }
        guard view != navigationBar else { return }
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(bringSubviewToFront(_:)), navigationBar)
    }
}

/// 修改原生导航条样式时，同步状态给自定义导航条。
/// 支持冻结`frame`、`center`、`bounds`属性，避免系统行为干扰转场动画。
private class XZNavigationCustomizableNavigationBar: UINavigationBar {
    
    override var supportsNavigationCustomization: Bool {
        get {
            return true;
        }
        set {
            fatalError("此方法不会被调用")
        }
    }
    
    open override var center: CGPoint {
        get {
            fatalError("此方法不会被调用")
        }
        set {
            if self.isFrozen {
                return
            }
            
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.center), newValue)
            
            guard let xzNavigationBar = self.xzNavigationBar else { return }
            
            xzNavigationBar.center = newValue;
        }
    }
    
    open override var frame: CGRect  {
        get {
            fatalError("此方法不会被调用")
        }
        set {
            if self.isFrozen {
                return
            }
            
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.frame), newValue)
            
            guard let xzNavigationBar = self.xzNavigationBar else { return }
            xzNavigationBar.frame = newValue;
        }
    }
    
    open override var bounds: CGRect {
        get {
            fatalError("此方法不会被调用")
        }
        set {
            if self.isFrozen {
                return
            }
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.bounds), newValue)
        }
    }
    
    open override var isHidden: Bool {
        get {
            return xz_objc_msgSendSuper_bool(self, type(of: self), #selector(getter: self.isHidden))
        }
        set {
            if let navigationBar = self.xzNavigationBar {
                navigationBar.isHidden = newValue
            } else {
                xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.isHidden), newValue)
            }
        }
    }
    
    open override var isTranslucent: Bool {
        get {
            return xz_objc_msgSendSuper_bool(self, type(of: self), #selector(getter: self.isTranslucent))
        }
        set {
            if let navigationBar = self.xzNavigationBar {
                navigationBar.isTranslucent = newValue
            } else {
                xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.isTranslucent), newValue)
            }
        }
    }
    
    @available(iOS 11.0, *)
    open override var prefersLargeTitles: Bool {
        get {
            return xz_objc_msgSendSuper_bool(self, type(of: self), #selector(getter: self.prefersLargeTitles))
        }
        set {
            if let navigationBar = self.xzNavigationBar {
                navigationBar.prefersLargeTitles = newValue
            } else {
                xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.prefersLargeTitles), newValue)
            }
        }
    }
    
}

/// 支持冻结`frame`、`center`、`bounds`属性，避免系统行为干扰转场动画。
private class XZNavigationCustomizableTabBar: UITabBar {

    override var supportsNavigationCustomization: Bool {
        get {
            return true;
        }
        set {
            fatalError("此方法不会被调用")
        }
    }
    
    /// 自定义类的 frame 属性，在修改值时，先判断当前是否允许修改。
    open override var frame: CGRect {
        get {
            fatalError("此方法不会被调用")
        }
        set {
            if isFrozen {
                return
            }
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.frame), newValue)
        }
    }
    
    override var center: CGPoint {
        get {
            fatalError("此方法不会被调用")
        }
        set {
            if isFrozen {
                return
            }
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.center), newValue)
        }
    }

    open override var bounds: CGRect {
        get {
            fatalError("此方法不会被调用")
        }
        set {
            if isFrozen {
                return
            }
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.bounds), newValue)
        }
    }

    open override var isHidden: Bool {
        get {
            fatalError("此方法不会被调用")
        }
        set {
            if isFrozen {
                return
            }
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.isHidden), newValue)
        }
    }
}

/// 给原生的导航控制器，添加自定义导航条属性。
@MainActor private var _navigationBar = 0
/// 记录控制器是否进行了自定义化
@MainActor private var _viewController = 0
/// 记录导航控制器是否进行了自定义化
@MainActor private var _naviagtionController = 0
/// 保存自定义转场控制。
@MainActor private var _transitionController = 0
@MainActor private var _navigationCustomizableClass = 0;

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
