//
//  XZNavigationControllerTransitionController.swift
//  XZKit
//
//  Created by Xezun on 2018/12/31.
//

import UIKit
import ObjectiveC
import XZDefines

/// 转场控制器，接管了导航控制的代理。
@MainActor public final class XZNavigationControllerTransitionController: NSObject {
    
    /// 导航手势对象。
    public let interactiveNavigationGestureRecognizer: UIKit.UIPanGestureRecognizer
    /// 导航控制器。
    public unowned let navigationController: XZNavigationController
    
    public init(for navigationController: XZNavigationController) {
        let panGestureRecognizer = UIPanGestureRecognizer.init()
        self.navigationController = navigationController
        self.interactiveNavigationGestureRecognizer = panGestureRecognizer
        super.init()
        
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        
        navigationController.view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(interactiveNavigationGestureRecognizerAction(_:)))
        
        // 处理代理。
        customizeNavigationControllerDelegate(navigationController.delegate)
        
        // 监听 delegate 属性，没有使用 KVO 是因为：
        // 1、在 iOS 14 以下，被观察的对象销毁时，如果没有移除 KVO 会发生崩溃。
        // 2、运行时绑定的对象，生命周期可能会比宿主更长，导致在 -deinit 中移除 KVO 时，已经找不到宿主；
        // 特别的，当使用 unowned 引用宿主时，还会出现 bad_access 崩溃。
        let aClass = type(of: navigationController)
        if objc_getAssociatedObject(aClass, &_isObserved) == nil {
            objc_setAssociatedObject(aClass, &_isObserved, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            typealias MethodType = @convention(block) (UINavigationController, UINavigationControllerDelegate?) -> Void
            let selector = #selector(setter: UINavigationController.delegate)
            let override: MethodType = { `self`, delegate in
                xz_objc_msgSendSuper(self, aClass, v: selector, o: delegate)
                if let transitionController = (self as? XZNavigationController)?.transitionController {
                    transitionController.customizeNavigationControllerDelegate(delegate)
                }
            }
            let exchange = { (_ selector: Selector) in
                let exchange: MethodType = { `self`, delegate in
                    xz_objc_msgSend(self, v: selector, o: delegate)
                    if let transitionController = (self as? XZNavigationController)?.transitionController {
                        transitionController.customizeNavigationControllerDelegate(delegate)
                    }
                }
                return exchange
            }
            xz_objc_class_addMethodWithBlock(aClass, selector, nil, nil, override, exchange)
        }
        
    }
    
    /// 交互式的转场控制器，只有在手势触发的转场过程中，此属性才有值。
    public private(set) var interactiveAnimationController: XZNavigationControllerAnimationController?
    
    /// 处理导航控制器的代理，使其支持 XZNavigationController 自定义。
    private func customizeNavigationControllerDelegate(_ delegate: UINavigationControllerDelegate?) {
        guard let delegate = delegate else {
            navigationController.delegate = self
            return
        }
        
        if delegate.isEqual(self) {
            return
        }
        
        let aClass = type(of: delegate);
        if objc_getAssociatedObject(aClass, &_isCustomized) != nil {
            return
        }
        objc_setAssociatedObject(aClass, &_isCustomized, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        do {
            typealias MethodType = @convention(block) (UINavigationControllerDelegate, UINavigationController, UINavigationController.Operation, UIViewController, UIViewController) -> UIViewControllerAnimatedTransitioning?
            let selector = #selector(UINavigationControllerDelegate.navigationController(_:animationControllerFor:from:to:))
            let encoding = xz_objc_class_getMethodTypeEncoding(type(of: self), selector)
            let creation: MethodType = { `self`, navigationController, operation, fromVC, toVC in
                guard let transitionController = (navigationController as? XZNavigationController)?.transitionController else { return nil }
                return transitionController.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
            }
            let override: MethodType = { `self`, navigationController, operation, fromVC, toVC in
                if let controller = xz_objc_msgSendSuper(self, aClass, o: selector, o: navigationController, i: operation.rawValue, o: fromVC, o: toVC) {
                    return controller as? UIViewControllerAnimatedTransitioning;
                }
                guard let transitionController = (navigationController as? XZNavigationController)?.transitionController else { return nil }
                return transitionController.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
            }
            let exchange = { (_ selector: Selector) in
                let exchange: MethodType = { `self`, navigationController, operation, fromVC, toVC in
                    if let controller = xz_objc_msgSend(self, o: selector, o: navigationController, i: operation.rawValue, o: fromVC, o: toVC) {
                        return controller as? UIViewControllerAnimatedTransitioning
                    }
                    guard let transitionController = (navigationController as? XZNavigationController)?.transitionController else { return nil }
                    return transitionController.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
                }
                return exchange
            }
            xz_objc_class_addMethodWithBlock(aClass, selector, encoding, creation, override, exchange);
        }
        
        do {
            typealias MethodType = @convention(block) (UINavigationControllerDelegate, UINavigationController, UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
            let selector = #selector(UINavigationControllerDelegate.navigationController(_:interactionControllerFor:))
            let encoding = xz_objc_class_getMethodTypeEncoding(type(of: self), selector)
            let creation: MethodType = { `self`, navigationController, animationController in
                guard let transitionController = (navigationController as? XZNavigationController)?.transitionController else { return nil }
                return transitionController.navigationController(navigationController, interactionControllerFor: animationController)
            }
            let override: MethodType = { `self`, navigationController, animationController in
                if let controller = xz_objc_msgSendSuper(self, aClass, o: selector, o: navigationController, o: animationController) {
                    return controller as? UIViewControllerInteractiveTransitioning;
                }
                guard let transitionController = (navigationController as? XZNavigationController)?.transitionController else { return nil }
                return transitionController.navigationController(navigationController, interactionControllerFor: animationController)
            }
            let exchange = { (_ selector: Selector) in
                let exchange: MethodType = { `self`, navigationController, animationController in
                    if let controller = xz_objc_msgSend(self, o: selector, o: navigationController, o: animationController) {
                        return controller as? UIViewControllerInteractiveTransitioning
                    }
                    guard let transitionController = (navigationController as? XZNavigationController)?.transitionController else { return nil }
                    return transitionController.navigationController(navigationController, interactionControllerFor: animationController)
                }
                return exchange
            }
            xz_objc_class_addMethodWithBlock(aClass, selector, encoding, creation, override, exchange);
        }
        
        // 重新设置代理，否则代理方法不会被调用，可能原生内部使用了缓存。
        navigationController.delegate = nil;
        navigationController.delegate = delegate;
    }
}

extension XZNavigationControllerTransitionController: UINavigationControllerDelegate {
    
    // 转场过程中，方法执行的顺序。
    // navigationController(_:animationControllerFor:from:to:)
    // navigationController(_:interactionControllerFor:)
    // navigationController(_:willShow:animated:)
    // animateTransition(using:)
    // navigationController(_:didShow:animated:)
    // animationEnded 在动画的回调中触发
    
    /// 1. 获取转场动画控制器。
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 交互性转场。
        if let animationController = self.interactiveAnimationController {
            return animationController
        }
        // 普通的动画转场。
        return XZNavigationControllerAnimationController.init(for: self.navigationController, operation: operation, isInteractive: false)
    }
    
    /// 2. 动画控制器的交互控制器。
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? XZNavigationControllerAnimationController)?.interactiveTransition
    }
    
}


extension XZNavigationControllerTransitionController {
    
    /// 手势事件。
    @objc private func interactiveNavigationGestureRecognizerAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            interactiveNavigationGestureRecognizerDidBegin(gestureRecognizer)
        case .changed:
            interactiveNavigationGestureRecognizerDidChange(gestureRecognizer)
        case .failed:
            fallthrough
        case .cancelled:
            fallthrough
        case .ended:
            interactiveNavigationGestureRecognizerDidEnd(gestureRecognizer)
        default:
            break
        }
    }
    
    /// 手势开始。通过判断手势方向来确定手势的行为。
    private func interactiveNavigationGestureRecognizerDidBegin(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard interactiveAnimationController == nil else { return }
        
        switch navigationOperation(for: panGestureRecognizer) {
        case .push:
            // 默认情况下，不可以导航到下一级。
            guard let viewController = navigationController.topViewController as? XZNavigationGestureDrivable else { return }
            guard let nextVC = viewController.navigationController(navigationController, viewControllerForGestureNavigation: .push) else { return }
            /// 手势开始的导航行为。
            self.interactiveAnimationController = XZNavigationControllerAnimationController.init(for: navigationController, operation: .push, isInteractive: true)
            navigationController.pushViewController(nextVC, animated: true)
            
        case .pop:
            // 只有一个控制器时，不能 pop
            let viewControllers = navigationController.viewControllers
            guard viewControllers.count > 1 else { return }
            
            self.interactiveAnimationController = XZNavigationControllerAnimationController.init(for: navigationController, operation: .pop, isInteractive: true)
            
            if let viewController = navigationController.topViewController as? XZNavigationGestureDrivable {
                if let nextVC = viewController.navigationController(navigationController, viewControllerForGestureNavigation: .pop) {
                    navigationController.popToViewController(nextVC, animated: true)
                    return
                }
            }
            navigationController.popViewController(animated: true)
        default:
            break
        }
    }
    
    /// 当手势状态发生改变是，更新动画。
    private func interactiveNavigationGestureRecognizerDidChange(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let animationController = self.interactiveAnimationController else { return }
        guard let interactionController = animationController.interactiveTransition else { return }
        
        let t = panGestureRecognizer.translation(in: nil)
        let d = t.x / navigationController.view.bounds.width
        switch navigationController.view.effectiveUserInterfaceLayoutDirection {
        case .rightToLeft:
            if animationController.operation == .push {
                interactionController.update(max(0, d))
            } else if animationController.operation == .pop {
                interactionController.update(-min(0, d))
            }
        case .leftToRight:
            if animationController.operation == .push {
                interactionController.update(-min(0, d))
            } else if animationController.operation == .pop {
                interactionController.update(max(0, d))
            }
        default:
            fatalError()
        }
    }
    
    /// 手势结束了。
    private func interactiveNavigationGestureRecognizerDidEnd(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let animationController = self.interactiveAnimationController else { return }
        self.interactiveAnimationController = nil
        guard let interactiveTransition = animationController.interactiveTransition else { return }
        
        let velocity = panGestureRecognizer.velocity(in: nil).x
        let PERCENT: CGFloat = 0.4
        let VELOCITY: CGFloat = 400
        switch navigationController.view.effectiveUserInterfaceLayoutDirection {
        case .rightToLeft:
            if (animationController.operation == .push && velocity > VELOCITY) || (animationController.operation == .pop && velocity < -VELOCITY) {
                interactiveTransition.finish()
            } else {
                let t = panGestureRecognizer.translation(in: nil)
                let percent = t.x / navigationController.view.bounds.width
                if (percent > PERCENT && animationController.operation == .push) || (percent < -PERCENT && animationController.operation == .pop) {
                    interactiveTransition.finish()
                } else {
                    interactiveTransition.cancel()
                }
            }
        case .leftToRight:
            if (animationController.operation == .push && velocity < -VELOCITY) || (animationController.operation == .pop && velocity > VELOCITY) {
                interactiveTransition.finish();
            } else {
                let t = panGestureRecognizer.translation(in: nil)
                let percent = t.x / navigationController.view.bounds.width
                if (percent < -PERCENT && animationController.operation == .push) || (percent > PERCENT && animationController.operation == .pop) {
                    interactiveTransition.finish()
                } else {
                    interactiveTransition.cancel()
                }
            }
        default:
            fatalError()
        }
        
        
    }
    
    /// 根据导航控制器当前的布局方向，和手势的速度来确定手势代表的导航行为。
    private func navigationOperation(for navigationGestureRecognizer: UIPanGestureRecognizer) -> UINavigationController.Operation {
        let velocity = navigationGestureRecognizer.velocity(in: nil)
        switch navigationController.view.effectiveUserInterfaceLayoutDirection {
        case .leftToRight:
            return (velocity.x > 0 ? .pop : (velocity.x < 0 ? .push : .none))
        case .rightToLeft:
            return (velocity.x < 0 ? .pop : (velocity.x > 0 ? .push : .none))
        default:
            fatalError()
        }
    }
}


extension XZNavigationControllerTransitionController: UIGestureRecognizerDelegate {
    
    /// 此方法返回 true 手势不一定能够识别成功，所以此方法不能决定导航行为。
    public func gestureRecognizerShouldBegin(_ navigationGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationGestureRecognizer = navigationGestureRecognizer as? UIPanGestureRecognizer else { return false }
        let operation   = navigationOperation(for: navigationGestureRecognizer) 
        
        let location    = navigationGestureRecognizer.location(in: nil)
        let translation = navigationGestureRecognizer.translation(in: nil)
        let point       = CGPoint(x: location.x - translation.x, y: location.y - translation.y);
        let bounds      = navigationController.view.bounds
        
        // 滑动横向分量不足时，不识别手势
        if abs(translation.x) < abs(translation.y) * 10 {
            return false
        }
        
        switch operation {
        case .push:
            // 栈顶控制器必须有协议支持
            guard let viewController = navigationController.topViewController as? XZNavigationGestureDrivable else { return false }
            
            // 边缘检测
            if let edgeInsets = viewController.navigationController(navigationController, edgeInsetsForGestureNavigation: .push) {
                switch navigationController.view.effectiveUserInterfaceLayoutDirection {
                case .leftToRight:
                    return point.x >= bounds.maxX - edgeInsets.trailing
                case .rightToLeft:
                    return point.x <= bounds.minX + edgeInsets.trailing
                @unknown default:
                    fatalError()
                }
            }
            
            return true
        case .pop:
            // 数量必须大于 2
            guard navigationController.viewControllers.count > 1 else {
                return false
            }
            
            // pop 定制
            if let viewController = navigationController.topViewController as? XZNavigationGestureDrivable {
                // 边缘检测
                if let edgeInsets = viewController.navigationController(navigationController, edgeInsetsForGestureNavigation: .pop) {
                    switch navigationController.view.effectiveUserInterfaceLayoutDirection {
                    case .leftToRight:
                        return point.x <= bounds.minX + edgeInsets.leading
                    case .rightToLeft:
                        return point.x >= bounds.maxX - edgeInsets.leading
                    @unknown default:
                        fatalError()
                    }
                }
                // 全屏支持返回
                return true
            }
            
            // 默认支持边缘 20.0 点内侧滑返回
            switch navigationController.view.effectiveUserInterfaceLayoutDirection {
            case .leftToRight:
                return point.x <= bounds.minX + 20.0
            case .rightToLeft:
                return point.x >= bounds.maxX - 20.0
            @unknown default:
                fatalError()
            }
        default:
            return false
        }
    }
    
    /// 是否可以与其它手势同时被识别。
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /// 导航驱动手势，是否需要在其它手势失败时才能识别，默认 false 。
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /// 其它手势需等待导航驱动手势失败才能进行。
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

/// 导航控制器 delegate 的 KVO 标记。
@MainActor private var _context = 0
/// 记录导航控制器的 delegate 是否已经进行了自定义化。
@MainActor private var _isCustomized = 0
@MainActor private var _isObserved = 0
// 转场方法调用顺序
//
// Push 成功时：
//    navigationController(_:animationControllerFor:from:to:)
//    navigationController(_:interactionControllerFor:)
//    toVC: viewDidLoad()
//    fromVC: viewWillDisappear(_:)
//    toVC: viewWillAppear(_:)
//    navigationController(_:willShow:animated:)
//    animateTransition(using:)
//    animatePushTransition(using:)
//    fromVC: viewDidDisappear(_:)
//    toVC: viewDidAppear(_:)
//    navigationController(_:didShow:animated:)
//    animationEnded(_:)
//
// Push 取消时：
//    navigationController(_:animationControllerFor:from:to:)
//    navigationController(_:interactionControllerFor:)
//    toVC: viewDidLoad()
//    fromVC: viewWillDisappear(_:)
//    toVC: viewWillAppear(_:)
//    navigationController(_:willShow:animated:)
//    animateTransition(using:)
//    animatePushTransition(using:)
//    toVC: viewWillDisappear(_:)
//    toVC: viewDidDisappear(_:)
//    fromVC: viewWillAppear(_:)
//    fromVC: viewDidAppear(_:)
//    animationEnded(_:)
//
// Pop 成功时：
//    navigationController(_:animationControllerFor:from:to:)
//    navigationController(_:interactionControllerFor:)
//    fromVC: viewWillDisappear(_:)
//    toVC: viewWillAppear(_:)
//    navigationController(_:willShow:animated:)
//    animateTransition(using:)
//    animatePopTransition(using:)
//    fromVC: viewDidDisappear(_:)
//    toVC: viewDidAppear(_:)
//    navigationController(_:didShow:animated:)
//    animationEnded(_:)
// Pop 取消时：
//    navigationController(_:animationControllerFor:from:to:)
//    navigationController(_:interactionControllerFor:)
//    fromVC: viewWillDisappear(_:)
//    toVC: viewWillAppear(_:)
//    navigationController(_:willShow:animated:)
//    animateTransition(using:)
//    animatePopTransition(using:)
//    toVC: viewWillDisappear(_:)
//    toVC: viewDidDisappear(_:)
//    fromVC: viewWillAppear(_:)
//    fromVC: viewDidAppear(_:)
//    animationEnded(_:)
