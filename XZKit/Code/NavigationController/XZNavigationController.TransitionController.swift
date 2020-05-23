//
//  NavigationController.TransitionController.swift
//  XZKit
//
//  Created by Xezun on 2018/12/31.
//

import Foundation

extension NavigationController {
    
    /// 转场控制器，接管了导航控制的代理。
    public final class TransitionController: NSObject {
        
        /// 导航控制器的代理，如果设置了此属性，那么转场动画将优先使用代理定义的转场。
        public weak var delegate: UINavigationControllerDelegate?
        /// 导航手势对象。
        public let interactiveNavigationGestureRecognizer: UIPanGestureRecognizer
        /// 导航控制器。
        public unowned let navigationController: NavigationController
        
        public init(for navigationController: NavigationController) {
            self.navigationController = navigationController
            self.interactiveNavigationGestureRecognizer = UIPanGestureRecognizer.init()
            super.init()
            self.interactiveNavigationGestureRecognizer.maximumNumberOfTouches = 1
            self.interactiveNavigationGestureRecognizer.delegate = self
            self.navigationController.view.addGestureRecognizer(interactiveNavigationGestureRecognizer)
            self.interactiveNavigationGestureRecognizer.addTarget(self, action: #selector(interactiveNavigationGestureRecognizerAction(_:)))
        }
        
        /// 交互式的转场控制器，只有在手势触发的转场过程中，此属性才有值。
        public private(set) var interactiveAnimationController: NavigationController.AnimationController?
    }
    
}

extension NavigationController.TransitionController: UINavigationControllerDelegate {
    
    // 转场过程中，方法执行的顺序。
    // navigationController(_:animationControllerFor:from:to:)
    // navigationController(_:interactionControllerFor:)
    // navigationController(_:willShow:animated:)
    // animateTransition(using:)
    // navigationController(_:didShow:animated:)
    // animationEnded 在动画的回调中触发
    
    /// 1. 获取转场动画控制器。
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 优先使用自定义转场
        if let animationController = delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC) {
            return animationController
        }
        // 交互性转场。
        if let animationController = self.interactiveAnimationController {
            return animationController
        }
        // 普通的动画转场。
        return NavigationController.AnimationController.init(for: self.navigationController, operation: operation, isInteractive: false)
    }
    
    /// 2. 动画控制器的交互控制器。
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let interactionController = delegate?.navigationController?(navigationController, interactionControllerFor: animationController) {
            return interactionController
        }
        return (animationController as? NavigationController.AnimationController)?.interactionController
    }
    
    /// 3. 新的控制器将要显示。
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 需要在动画开始前配置导航条样式，因为转场动画开始时，会根据当前导航条的状态来确定控制器的布局。
        // 此方法会在 viewDidLoad 之后，但是在转场动画开始之前触发；转场如果取消，此方法不会调用。
        // 导航控制器第一次显示时，栈底控制器如果不是通过初始化方法传入的，可能会造成此方法会被调用，但是 didShow 不调用，所以需要转场事件的回调。
        navigationController.navigationBar.customizedBar = nil // 转场过程中，设置当前的自定义导航条为 nil ，以避免将新导航条的状态同步过来了。
        if let navigationBar = (viewController as? NavigationBarCustomizable)?.navigationBarIfLoaded {
            navigationController.navigationBar.tintColor = navigationBar.tintColor
            navigationController.navigationBar.isTranslucent = navigationBar.isTranslucent
            if #available(iOS 11.0, *) {
                navigationController.navigationBar.prefersLargeTitles = navigationBar.prefersLargeTitles
            }
            navigationController.setNavigationBarHidden(navigationBar.isHidden, animated: animated)
        } else {
            // 如果没有自定义导航条，则默认导航条隐藏、透明，那么控制器强制设置导航条显示时，将展示一个透明的导航条。
            navigationController.navigationBar.tintColor = nil
            navigationController.navigationBar.isTranslucent = true
            if #available(iOS 11.0, *) {
                navigationController.navigationBar.prefersLargeTitles = false
            }
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
        
        delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    
    /// 5. 导航控制器显示了指定的控制器。转场取消的时候，此方法不会调用。
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // 带动画的转场已由转场控制器处理。
        if animated {
            // 因为取消的转场，此方法不会背调用，所以动画转场的收尾工作已在动画回调中处理。
        } else {
            // 非动画转场的处理。
            navigationController.navigationBar.customizedBar = (viewController as? NavigationBarCustomizable)?.navigationBarIfLoaded
        }
        
        delegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    
    /// 转发未实现的代理方法，此方法直接返回 delegate 。
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return delegate
    }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return delegate?.responds(to: aSelector) == true
    }
}


extension NavigationController.TransitionController {
    
    /// 手势事件。
    @objc private func interactiveNavigationGestureRecognizerAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:     interactiveNavigationGestureRecognizerDidBegin(gestureRecognizer)
        case .changed:   interactiveNavigationGestureRecognizerDidChange(gestureRecognizer)
        case .failed:    fallthrough
        case .cancelled: fallthrough
        case .ended:     interactiveNavigationGestureRecognizerDidComplete(gestureRecognizer)
        default:         break
        }
    }
    
    /// 根据导航控制器当前的布局方向，和手势的速度来确定手势代表的导航行为。
    private func navigationOperation(recognized interactiveNavigationGestureRecognizer: UIPanGestureRecognizer) -> UINavigationController.Operation {
        let velocity = interactiveNavigationGestureRecognizer.velocity(in: nil)
        switch navigationController.view.userInterfaceLayoutDirection {
        case .rightToLeft: return velocity.x < 0 ? .pop : .push
        case .leftToRight: fallthrough
        default:           return velocity.x > 0 ? .pop : .push
        }
    }
    
    /// 手势开始。通过判断手势方向来确定手势的行为。
    private func interactiveNavigationGestureRecognizerDidBegin(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard interactiveAnimationController == nil else { return }
        
        let operation = navigationOperation(recognized: panGestureRecognizer)// UINavigationController.Operation.init(for: navigationController, panGestureRecognizer)
        
        switch operation {
        case .push:
            // 默认情况下，不可以导航到下一级。
            guard let drivableViewController = navigationController.topViewController as? NavigationGestureDrivable else { return }
            
            // 检测手势范围。默认情况下全屏可以触发，如果栈顶控制器限定了范围，检测是否在此范围。
            if let edges = drivableViewController.navigationController(navigationController, edgeInsetsForGestureNavigation: operation) {
                let location = panGestureRecognizer.location(in: nil)
                guard navigationController.view.bounds.contains(location, in: edges) else { return }
            }
            
            // 只有栈顶控制器返回了控制器，才能执行 Push。
            guard let viewController = drivableViewController.viewControllerForPushGestureNavigation(navigationController) else { return }
            
            /// 手势开始的导航行为。
            self.interactiveAnimationController = NavigationController.AnimationController.init(for: navigationController, operation: operation, isInteractive: true)
            navigationController.pushViewController(viewController, animated: true)
            
        case .pop:
            // 只有一个控制器时，不能 pop
            let viewControllers = navigationController.viewControllers
            guard viewControllers.count > 1 else { return }
            
            // 检测手势范围。默认支持全屏 POP，如果栈顶控制器限定了范围，则检测范围是否符合。
            if let viewController = navigationController.topViewController as? NavigationGestureDrivable {
                if let gestureEdge = viewController.navigationController(navigationController, edgeInsetsForGestureNavigation: operation) {
                    let location = panGestureRecognizer.location(in: nil)
                    guard navigationController.view.bounds.contains(location, in: gestureEdge) else {
                        return
                    }
                }
            }
            
            self.interactiveAnimationController = NavigationController.AnimationController.init(for: navigationController, operation: operation, isInteractive: true)
            _ = navigationController.popViewController(animated: true)
            
        default:
            break
        }
    }
    
    /// 当手势状态发生改变是，更新动画。
    private func interactiveNavigationGestureRecognizerDidChange(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let animationController = self.interactiveAnimationController else { return }
        guard let interactionController = animationController.interactionController else { return }
        
        let t = panGestureRecognizer.translation(in: nil)
        let d = t.x / navigationController.view.bounds.width
        switch navigationController.view.userInterfaceLayoutDirection {
        case .rightToLeft:
            if animationController.operation == .push {
                interactionController.update(max(0, d))
            } else if animationController.operation == .pop {
                interactionController.update(-min(0, d))
            }
        case .leftToRight: fallthrough
        default:
            if animationController.operation == .push {
                interactionController.update(-min(0, d))
            } else if animationController.operation == .pop {
                interactionController.update(max(0, d))
            }
        }
    }
    
    /// 手势结束了。
    private func interactiveNavigationGestureRecognizerDidComplete(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let transitionController = self.interactiveAnimationController else { return }
        self.interactiveAnimationController = nil
        guard let interactionController = transitionController.interactionController else { return }
        
        let velocity = panGestureRecognizer.velocity(in: nil).x
        let PERCENT: CGFloat = 0.4
        let VELOCITY: CGFloat = 400
        switch navigationController.view.userInterfaceLayoutDirection {
        case .rightToLeft:
            if (transitionController.operation == .push && velocity > VELOCITY) || (transitionController.operation == .pop && velocity < -VELOCITY) {
                interactionController.finish()
            } else {
                let t = panGestureRecognizer.translation(in: nil)
                let percent = t.x / navigationController.view.bounds.width
                if (percent > PERCENT && transitionController.operation == .push) || (percent < -PERCENT && transitionController.operation == .pop) {
                    interactionController.finish()
                } else {
                    interactionController.cancel()
                }
            }
        case .leftToRight: fallthrough
        default:
            if (transitionController.operation == .push && velocity < -VELOCITY) || (transitionController.operation == .pop && velocity > VELOCITY) {
                interactionController.finish();
            } else {
                let t = panGestureRecognizer.translation(in: nil)
                let percent = t.x / navigationController.view.bounds.width
                if (percent < -PERCENT && transitionController.operation == .push) || (percent > PERCENT && transitionController.operation == .pop) {
                    interactionController.finish()
                } else {
                    interactionController.cancel()
                }
            }
        }
    }
}


extension NavigationController.TransitionController: UIGestureRecognizerDelegate {
    
    /// 此方法返回 true 手势不一定能够识别成功，所以此方法不能决定导航行为。
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === interactiveNavigationGestureRecognizer else {
            return false
        }
        guard interactiveAnimationController == nil else {
            return false
        }
        if navigationController.viewControllers.isEmpty {
            return false
        }
        return true
    }
    
    /// 是否可以与其它手势同时被识别。
    /// - Note: 如果站内控制器限定了导航驱动的边缘范围，则在该边缘范围内，导航驱动手势，可以与其它手势同时被识别，例如在 ScrollView 滚动手势，不会屏蔽导航行为。
    /// - Note: 如果没有限定手势驱动的边缘范围，那么在存在 ScrollView 时，默认仅在左右边缘 8pt 内可以触发导航手势，其它范围只能识别 ScrollView 滚动手势。
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果当前代理不是导航驱动手势，默认返回 false 。
        guard gestureRecognizer === interactiveNavigationGestureRecognizer else {
            return false
        }
        let location = interactiveNavigationGestureRecognizer.location(in: nil)
        
        let operation = navigationOperation(recognized: interactiveNavigationGestureRecognizer) // UINavigationController.Operation.init(for: navigationController, interactiveNavigationGestureRecognizer)
        
        // 在指定的范围内，导航驱动手势，可以与其它手势同时被识别。
        if let topViewController = navigationController.topViewController as? NavigationGestureDrivable,
            let gestureGrivenEdge = topViewController.navigationController(navigationController, edgeInsetsForGestureNavigation: operation) {
            return navigationController.view.bounds.contains(location, in: gestureGrivenEdge)
        }
        
        // 没有指定范围，则在边缘可以与其它手势共同触发，以确保手势驱动导航在其它手势存在时，依然可以使用，且不影响其它手势。
        return navigationController.view.bounds.contains(location, in: UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0))
    }
    
    /// 导航驱动手势，是否需要在其它手势失败时才能识别，默认 false 。
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /// 导航驱动手势被识别时，其它手势是否需要导航驱动手势失败才能进行。
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果当前代理不是导航驱动手势，默认返回 false 。
        guard gestureRecognizer === interactiveNavigationGestureRecognizer else {
            return false
        }
        let bounds   = navigationController.view.bounds
        let location = interactiveNavigationGestureRecognizer.location(in: nil)
        let operation = navigationOperation(recognized: interactiveNavigationGestureRecognizer) // UINavigationController.Operation.init(for: navigationController, interactiveNavigationGestureRecognizer)
        // 在指定的范围内，导航驱动手势被识别时，停止其它手势。
        if let topViewController = navigationController.topViewController as? NavigationGestureDrivable,
            let gestureGrivenEdge = topViewController.navigationController(navigationController, edgeInsetsForGestureNavigation: operation) {
            return bounds.contains(location, in: gestureGrivenEdge)
        }
        // 没有指定范围，如果在边缘，停止其它手势识别。不在边缘时，如果有其它手势，导航手势不会被识别。
        return bounds.contains(location, in: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    
}
