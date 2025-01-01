//
//  XZNavigationController.AnimationController.swift
//  XZKit
//
//  Created by Xezun on 2017/7/11.
//
//

import UIKit


extension XZNavigationController {
    
    /// 动画控制器，处理了导航控制器的转场过程中的动画效果。
    open class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {
        
        /// 导航控制器。
        public unowned let navigationController: XZNavigationController
        /// 导航行为。
        public let operation: UINavigationController.Operation
        /// 交互控制器。
        public let interactionController: UIPercentDrivenInteractiveTransition?
        /// 是否为交互性动画。
        public var isInteractive: Bool {
            return interactionController != nil
        }
        
        public init?(for navigationController: XZNavigationController, operation: UINavigationController.Operation, isInteractive: Bool) {
            guard operation != .none else { return nil }
            self.navigationController  = navigationController
            self.operation             = operation
            self.interactionController = (isInteractive ? UIPercentDrivenInteractiveTransition() : nil)
            super.init()
        }
        
    }
    
    
}



extension XZNavigationController.AnimationController {
    
    /// 系统默认转场动画时长为 0.3 秒，此处也一样。
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    /// 4. 配置转场动画。
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch operation {
        case .push: animatePushTransition(using: transitionContext)
        case .pop:  animatePopTransition(using: transitionContext)
        default:    break
        }
    }
    
    /// 6. 转场结束。
    open func animationEnded(_ transitionCompleted: Bool) {
        // 此方法在 UIViewControllerContextTransitioning.completeTransition(_:) 中被调用。
        // 且调用后，系统内部处理了一些操作，致使在这里处理取消导航的恢复操作无法生效，所以取消导航的恢复操作放在了动画的 completion 回调中处理。
        // navigationController.transitionController.navigationController(navigationController, animationController: self, animatedTransitionDidEnd: transitionCompleted)
        // 在此取 navigationController.topViewController 可能并不准确，因为 viewDidAppear 比此方法先调用，
        // 如果在 viewDidAppear 中 push 了新的控制器，那么这里的获取到的 topViewController 就是新的控制器。
        // 因此在此方法中无法设置当前的自定义导航条。
    }
    
    open func animationOptions(forTransition operation: UINavigationController.Operation) -> UIView.AnimationOptions {
        if interactionController == nil {
            return .curveEaseInOut
        }
        return .curveLinear
    }
    
    /// 执行 Push 动画。
    ///
    /// - Parameter transitionContext: 转场信息。
    open func animatePushTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC   = transitionContext.viewController(forKey: .from) else { return }
        guard let fromView = transitionContext.view(forKey: .from)           else { return }
        guard let toVC     = transitionContext.viewController(forKey: .to)   else { return }
        guard let toView   = transitionContext.view(forKey: .to)             else { return }
        
        let flag: CGFloat = transitionContext.containerView.userInterfaceLayoutDirection == .leftToRight ? 1.0 : -1.0
        
        // 使用 transform 写动画效果，改变的也是视图的 frame 不能解决在专场开始时获取控制器视图 frame 不正常的问题。
        
        // 配置旧视图。
        let fromViewFrame1 = transitionContext.initialFrame(for: fromVC)
        let fromViewFrame2 = fromViewFrame1.offsetBy(dx: flag * -fromViewFrame1.width / 3.0, dy: 0)
        fromView.frame = fromViewFrame1
        transitionContext.containerView.addSubview(fromView)
        
        // 配置新视图。
        let toViewFrame2 = transitionContext.finalFrame(for: toVC)
        let toViewFrame1 = toViewFrame2.offsetBy(dx: flag * toViewFrame2.width, dy: 0)
        toView.frame = toViewFrame1
        transitionContext.containerView.addSubview(toView)
        
        // 转场容器与导航条不在同一个层次上，坐标系需要转换。
        let navigationBar = navigationController.navigationBar // 系统导航条。
        
        // 获取自定义导航条，并配置导航条。
        let fromNavigationBar = (fromVC as? XZNavigationBarCustomizable)?.navigationBarIfLoaded
        let toNavigationBar = (toVC as? XZNavigationBarCustomizable)?.navigationBarIfLoaded
        // 导航条当前坐标系（这里获取到的是转场之后的导航条状态），已转换到转场容器内。
        // fromNavigationBar 在转场前已从导航条上移除，转换坐标系需使用系统导航条（需保持 fromNavigationBar.frame 不变）。
        let navigationBarRect = navigationBar.convert(navigationBar.bounds, to: transitionContext.containerView)
        // 根据导航条的变化来设置导航条。
        let navigationBarTransition = TransitionType.init(forNavigationBarFrom: fromNavigationBar?.isHidden, to: toNavigationBar?.isHidden)
        switch navigationBarTransition {
        case .alwaysShow:
            // 旧的导航条保持原样添加到动画视图上。
            fromNavigationBar!.frame = navigationBar.convert(fromNavigationBar!.frame, to: transitionContext.containerView)
            transitionContext.containerView.insertSubview(fromNavigationBar!, aboveSubview: fromView)
            // 新的导航条与当前系统导航条一致。
            toNavigationBar!.frame = navigationBarRect.offsetBy(dx: flag * navigationBarRect.width, dy: 0)
            transitionContext.containerView.insertSubview(toNavigationBar!, aboveSubview: toView)
            
        case .alwaysHide:
            break // 始终隐藏，不需要做动画，自定义导航条（如果有）在转场之后添加到系统导航条上。
            
        case .showToHide:
            fromNavigationBar!.frame = navigationBar.convert(fromNavigationBar!.frame, to: transitionContext.containerView)
            transitionContext.containerView.insertSubview(fromNavigationBar!, aboveSubview: fromView)
            
        case .hideToShow:
            toNavigationBar!.frame = navigationBarRect.offsetBy(dx: flag * navigationBarRect.width, dy: 0)
            transitionContext.containerView.insertSubview(toNavigationBar!, aboveSubview: toView)
        }
        // 解决因为状态栏变化而造成的导航条布局问题。
        fromNavigationBar?.setNeedsLayout()
        toNavigationBar?.setNeedsLayout()
        
        // 记录导航条当前位置，然后将导航条放到转场容器内执行动画。
        let navigationBarLocation = (
            superview: navigationBar.superview,
            frame: navigationBar.frame,
            index: navigationBar.superview?.subviews.firstIndex(of: navigationBar)
        )
        navigationBar.frame = navigationBarRect
        transitionContext.containerView.insertSubview(navigationBar, belowSubview: fromView)
        
        // 阴影
        let containerBounds = transitionContext.containerView.bounds
        let shadowView = ShadowView.init(frame: containerBounds.offsetBy(dx: flag * containerBounds.width, dy: 0))
        transitionContext.containerView.insertSubview(shadowView, belowSubview: toView)
        
        let tabBarAnimator = TabBarAnimator.init(
            navigationController: navigationController,
            operation: .push,
            containerView: transitionContext.containerView,
            from: (fromVC, fromViewFrame1, fromViewFrame2),
            to: (toVC, toViewFrame1, toViewFrame2)
        )
        
        let duration = transitionDuration(using: transitionContext)
        let options = animationOptions(forTransition: .push)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            fromView.frame = fromViewFrame2
            toView.frame   = toViewFrame2
            shadowView.frame = containerBounds
            tabBarAnimator?.commitAnimation()
            
            switch navigationBarTransition {
            case .alwaysShow:
                let frame = fromNavigationBar!.frame
                fromNavigationBar!.frame = frame.offsetBy(dx: flag * -frame.width / 3.0, dy: 0)
                toNavigationBar!.frame = navigationBarRect
                
            case .alwaysHide: break
            case .showToHide:
                let frame = fromNavigationBar!.frame
                fromNavigationBar!.frame = frame.offsetBy(dx: flag * -frame.width / 3.0, dy: 0)
                
            case .hideToShow:
                toNavigationBar!.frame = navigationBarRect
            }
        }, completion: { (finished) in
            // 删除阴影。
            shadowView.removeFromSuperview()
            // 恢复导航条原有位置。
            if let superview = navigationBarLocation.superview, let index = navigationBarLocation.index {
                navigationBar.frame = navigationBarLocation.frame
                superview.insertSubview(navigationBar, at: min(index, superview.subviews.count))
            }
            // 恢复 TabBar 。
            tabBarAnimator?.completeAnimation(finished)
            // 自定义导航条在转场过程中，仅仅作为转场效果出现，将起放置到导航条上有导航控制器处理，所以这里要移除。
            fromNavigationBar?.removeFromSuperview()
            toNavigationBar?.removeFromSuperview()
            
            // 恢复导航条状态。如果将恢复操作放在 animationEnded(_:) 方法中，在Demo中没有问题，但是在实际项目中却遇到了未知问题：
            // 页面A导航条透明，页面B导航条不透明。从 B 返回（pop）到 A ，如果操作取消，那么最终 B 页面的导航条属性为不透明，但是从布局（控制器view）上看却是透明的。
            // 由于 animationEnded(_:) 是在控制器 viewDidAppear 或 viewDidDisappear 之后被调用（见页面底部文档），此时再来恢复导航条样式已无济于事。
            // 至于在Demo中放在前后都可以，可能是因为计算少速度快导致的，但是项目计算量达时，放后面就无法及时抓取正确的状态，从而导致问题。
            if transitionContext.transitionWasCancelled {
                if let fromNavigationBar = fromNavigationBar {
                    navigationBar.isTranslucent = fromNavigationBar.isTranslucent
                    navigationBar.tintColor     = fromNavigationBar.tintColor
                    navigationBar.isHidden      = fromNavigationBar.isHidden
                    if #available(iOS 11.0, *) {
                        navigationBar.prefersLargeTitles = fromNavigationBar.prefersLargeTitles
                    }
                } else {
                    navigationBar.isTranslucent = true
                    navigationBar.tintColor = nil
                    navigationBar.isHidden = true
                    if #available(iOS 11.0, *) {
                        navigationBar.prefersLargeTitles = false
                    }
                }
                transitionContext.completeTransition(false)
                navigationBar.customizedBar = fromNavigationBar;
            } else {
                transitionContext.completeTransition(true)
                navigationBar.customizedBar = toNavigationBar;
            }
        })
    }

    
    /// 执行 pop 动画。
    ///
    /// - Parameter transitionContext: 转场信息。
    open func animatePopTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC   = transitionContext.viewController(forKey: .from) else { return }
        guard let fromView = transitionContext.view(forKey: .from)           else { return }
        guard let toVC     = transitionContext.viewController(forKey: .to)   else { return }
        guard let toView   = transitionContext.view(forKey: .to)             else { return }
        
        let flag: CGFloat = transitionContext.containerView.userInterfaceLayoutDirection == .leftToRight ? 1.0 : -1.0
        
        // 配置旧视图。
        let fromViewFrame1 = transitionContext.initialFrame(for: fromVC)
        let fromViewFrame2 = fromViewFrame1.offsetBy(dx: flag * fromViewFrame1.width, dy: 0)
        fromView.frame = fromViewFrame1
        transitionContext.containerView.addSubview(fromView)
        
        // 配置新视图。
        let toViewFrame2 = transitionContext.finalFrame(for: toVC)
        let toViewFrame1 = toViewFrame2.offsetBy(dx: flag * -toViewFrame2.width / 3.0, dy: 0)
        toView.frame = toViewFrame1
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        
        // 转场容器与导航条不在同一个层次上，坐标系需要转换。
        let navigationBar = navigationController.navigationBar // 系统导航条。
        
        // 获取自定义导航条，并配置导航条。
        let fromNavigationBar = (fromVC as? XZNavigationBarCustomizable)?.navigationBarIfLoaded
        let toNavigationBar = (toVC as? XZNavigationBarCustomizable)?.navigationBarIfLoaded
        // 导航条当前坐标系（这里获取到的是转场之后的导航条状态），已转换到转场容器内。
        let navigationBarRect = navigationBar.convert(navigationBar.bounds, to: transitionContext.containerView)
        // 根据导航条的变化来设置导航条。
        let navigationBarTransition = TransitionType.init(forNavigationBarFrom: fromNavigationBar?.isHidden, to: toNavigationBar?.isHidden)
        switch navigationBarTransition {
        case .alwaysShow:
            // 旧的导航条保持原样添加到动画视图上。
            fromNavigationBar!.frame = navigationBar.convert(fromNavigationBar!.frame, to: transitionContext.containerView)
            transitionContext.containerView.insertSubview(fromNavigationBar!, aboveSubview: fromView)
            // 新的导航条与当前系统导航条一致。
            toNavigationBar!.frame = navigationBarRect.offsetBy(dx: flag * -navigationBarRect.width / 3.0, dy: 0)
            transitionContext.containerView.insertSubview(toNavigationBar!, aboveSubview: toView)
            
        case .alwaysHide:
            break // 始终隐藏，不需要做动画，自定义导航条（如果有）在转场之后添加到系统导航条上。
            
        case .showToHide:
            fromNavigationBar!.frame = navigationBar.convert(fromNavigationBar!.frame, to: transitionContext.containerView)
            transitionContext.containerView.insertSubview(fromNavigationBar!, aboveSubview: fromView)
            
        case .hideToShow:
            toNavigationBar!.frame = navigationBarRect.offsetBy(dx: flag * -navigationBarRect.width / 3.0, dy: 0)
            transitionContext.containerView.insertSubview(toNavigationBar!, aboveSubview: toView)
        }
        // 解决因为状态栏变化而造成的导航条布局问题。
        fromNavigationBar?.setNeedsLayout()
        toNavigationBar?.setNeedsLayout()
        
        // 记录导航条当前位置，然后将导航条放到转场容器最底层（作为自定义导航条的背景）执行动画。
        let navigationBarLocation = (
            superview: navigationBar.superview,
            frame: navigationBar.frame,
            index: navigationBar.superview?.subviews.firstIndex(of: navigationBar)
        )
        navigationBar.frame = navigationBarRect
        transitionContext.containerView.insertSubview(navigationBar, belowSubview: toView)
        
        let containerBounds = transitionContext.containerView.bounds
        let shadowView = ShadowView.init(frame: containerBounds)
        transitionContext.containerView.insertSubview(shadowView, belowSubview: fromView)
        
        let tabBarAnimator = TabBarAnimator.init(
            navigationController: navigationController,
            operation: .pop,
            containerView: transitionContext.containerView,
            from: (fromVC, fromViewFrame1, fromViewFrame2),
            to: (toVC, toViewFrame1, toViewFrame2)
        )
        
        let duration = transitionDuration(using: transitionContext)
        let options = animationOptions(forTransition: .push)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            fromView.frame = fromViewFrame2
            toView.frame   = toViewFrame2
            shadowView.frame = containerBounds.offsetBy(dx: flag * containerBounds.width, dy: 0)
            tabBarAnimator?.commitAnimation()
            
            switch navigationBarTransition {
            case .alwaysShow:
                let frame = fromNavigationBar!.frame
                fromNavigationBar!.frame = frame.offsetBy(dx: flag * frame.width, dy: 0)
                toNavigationBar!.frame = navigationBarRect
                
            case .alwaysHide: break
            case .showToHide:
                let frame = fromNavigationBar!.frame
                fromNavigationBar!.frame = frame.offsetBy(dx: flag * frame.width, dy: 0)
                
            case .hideToShow:
                toNavigationBar!.frame = navigationBarRect
            }
        }, completion: { (finished) in
            shadowView.removeFromSuperview()
            // 恢复导航条原有位置。
            if let superview = navigationBarLocation.superview, let index = navigationBarLocation.index {
                superview.insertSubview(navigationBar, at: min(index, superview.subviews.count))
            }
            // 恢复 TabBar 。
            tabBarAnimator?.completeAnimation(finished)
            // 自定义导航条在转场过程中，仅仅作为转场效果出现，将起放置到导航条上有导航控制器处理，所以这里要移除。
            fromNavigationBar?.removeFromSuperview()
            toNavigationBar?.removeFromSuperview()
            
            // 恢复导航条状态。如果将恢复操作放在 animationEnded(_:) 方法中，在Demo中没有问题，但是在实际项目中却遇到了未知问题：
            // 页面A导航条透明，页面B导航条不透明。从 B 返回（pop）到 A ，如果操作取消，那么最终 B 页面的导航条属性为不透明，但是从布局（控制器view）上看却是透明的。
            // 由于 animationEnded(_:) 是在控制器 viewDidAppear 或 viewDidDisappear 之后被调用（见页面底部文档），此时再来恢复导航条样式已无济于事。
            // 至于在Demo中放在前后都可以，可能是因为计算少速度快导致的，但是项目计算量达时，放后面就无法及时抓取正确的状态，从而导致问题。
            if transitionContext.transitionWasCancelled {
                if let fromNavigationBar = fromNavigationBar {
                    navigationBar.isTranslucent = fromNavigationBar.isTranslucent
                    navigationBar.tintColor     = fromNavigationBar.tintColor
                    navigationBar.isHidden      = fromNavigationBar.isHidden
                    if #available(iOS 11.0, *) {
                        navigationBar.prefersLargeTitles = fromNavigationBar.prefersLargeTitles
                    }
                } else {
                    navigationBar.isTranslucent = true
                    navigationBar.tintColor = nil
                    navigationBar.isHidden = true
                    if #available(iOS 11.0, *) {
                        navigationBar.prefersLargeTitles = false
                    }
                }
                transitionContext.completeTransition(false)
                navigationBar.customizedBar = fromNavigationBar
            } else {
                transitionContext.completeTransition(true)
                navigationBar.customizedBar = toNavigationBar
            }
        })
    }
    
    /// 导航条、工具条视图的转场类型，在转场过程中显示/隐藏状态变化。
    public enum TransitionType {
        /// 转场中始终显示。
        case alwaysShow
        /// 转场中始终隐藏。
        case alwaysHide
        /// 转场中由显示到隐藏。
        case showToHide
        /// 转场中由隐藏到显示。
        case hideToShow
        /// 导航条的转场状态。
        public init(forNavigationBarFrom hidden1: Bool?, to hidden2: Bool?) {
            if let fromHidden = hidden1 {
                if let toHidden = hidden2 {
                    if fromHidden {
                        self = toHidden ? .alwaysHide : .hideToShow
                    } else {
                        self = toHidden ? .showToHide : .alwaysShow
                    }
                } else {
                    self = fromHidden ? .alwaysHide : .showToHide
                }
            } else if let toHidden = hidden2 {
                self = toHidden ? .alwaysHide : .hideToShow
            } else {
                self = .alwaysHide
            }
        }
        
        /// 导航控制器转场时，其所在的 tabBar 转场状态。
        public init?(forTabBarEmbedded navigationController: UINavigationController, operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) {
            let viewControllers = navigationController.viewControllers
            if viewControllers.isEmpty {
                return nil
            }
            
            // 导航控制器栈中，只有所有控制器 hidesBottomBarWhenPushed 都为 false 时，tabBar 才不隐藏。
            // 当配置转场动画时，导航控制器栈内控制器已经确定。Push 已包含新控制器，Pop 已不包含站内控制器。
            switch operation {
            case .push:
                let fromHidden = viewControllers[0 ..< viewControllers.count - 1].contains(where: { $0.hidesBottomBarWhenPushed })
                if !fromHidden && toVC.hidesBottomBarWhenPushed {
                    self = .showToHide
                } else {
                    return nil
                }
            case .pop:
                let toHidden = viewControllers.contains(where: { $0.hidesBottomBarWhenPushed })
                if !toHidden && fromVC.hidesBottomBarWhenPushed {
                    self = .hideToShow
                } else {
                    return nil
                }
            case .none: fallthrough
            default:
                return nil
            }
            
        }
    }
    
    /// TabBar 的转场动画控制器。
    public class TabBarAnimator {
        
        let tabBar: UITabBar
        /// tabBar 的原始父视图。
        let tabBarSuperview: UIView
        /// tabBar 在原始父视图中的层级。
        let tabBarIndex: Int
        
        private let tabBarToFrame: CGRect
        
        private(set) var isCompleted: Bool
        
        deinit {
            // 最后尝试恢复 tabBar 。
            completeAnimation(true)
        }
        
        /// 确认动画，配置动画。
        public func commitAnimation() {
            guard !isCompleted else {
                return
            }
            tabBar.isFrameFrozen = false
            tabBar.frame = tabBarToFrame
            tabBar.isFrameFrozen = true
        }
        
        /// 动画执行完毕后。
        public func completeAnimation(_ isFinished: Bool) {
            guard !isCompleted else {
                return
            }
            isCompleted = true
            tabBar.isFrameFrozen = false
            let bounds = tabBarSuperview.bounds
            tabBar.frame = CGRect.init(
                x: bounds.minX,
                y: bounds.maxY - tabBarToFrame.height,
                width: tabBarToFrame.width,
                height: tabBarToFrame.height
            )
            tabBarSuperview.insertSubview(tabBar, at: min(tabBarIndex, tabBarSuperview.subviews.count))
            
            // 根据 Apple 官方的说法 hidesBottomBarWhenPushed 是单向的，一旦设置隐藏，tabBar 就再也不会显示了（Issue 39277909）。
            // 所以不需要控制 tabBar 的显示和隐藏，只控制器动画就行了。因为如果官方不显示 tabBar 的话，不透明时，控制器是没有下边距的。
        }
        
        public typealias AnimationContext = (viewController: UIViewController, fromFrame: CGRect, toFrame: CGRect)
        
        public let transitionType: TransitionType
        
        public init?(navigationController: UINavigationController, operation: UINavigationController.Operation, containerView: UIView, from fromContext: AnimationContext, to toContext: AnimationContext) {
            guard let tabBar = navigationController.tabBarController?.tabBar else { return nil }
            guard let transitionType = TransitionType(forTabBarEmbedded: navigationController, operation: operation, from: fromContext.viewController, to: toContext.viewController) else {
                return nil
            }
            guard let superview = tabBar.superview else { return nil }
            self.isCompleted = false
            
            // TODO: 存在一个未知 BUG ： TabBar 在某些情况下无法恢复，暂无法复现步骤。
            
            switch transitionType {
            case .alwaysHide: return nil
            case .alwaysShow: return nil
            case .showToHide:
                self.tabBar          = tabBar
                self.tabBarIndex     = superview.subviews.firstIndex(of: tabBar)!
                self.tabBarSuperview = superview
                self.transitionType  = .showToHide
                
                tabBar.isFrameFrozen = false
                let tabBarFrame = tabBar.frame
                tabBar.frame = CGRect.init(
                    x: fromContext.fromFrame.minX,
                    y: containerView.bounds.maxY - tabBarFrame.height,
                    width: tabBarFrame.width,
                    height: tabBarFrame.height
                )
                containerView.insertSubview(tabBar, aboveSubview: fromContext.viewController.view)
                self.tabBarToFrame = CGRect.init(
                    x: fromContext.toFrame.minX,
                    y: containerView.bounds.maxY - tabBarFrame.height,
                    width: tabBarFrame.width,
                    height: tabBarFrame.height
                )
                tabBar.isFrameFrozen = true
                
            case .hideToShow:
                self.tabBar             = tabBar
                self.tabBarIndex        = superview.subviews.firstIndex(of: tabBar)!
                self.tabBarSuperview    = superview
                self.transitionType     = .hideToShow
                
                tabBar.isFrameFrozen    = false
                let tabBarFrame = tabBar.frame
                tabBar.frame = CGRect.init(
                    x: toContext.fromFrame.minX,
                    y: containerView.bounds.maxY - tabBarFrame.height,
                    width: tabBarFrame.width,
                    height: tabBarFrame.height
                )
                containerView.insertSubview(tabBar, aboveSubview: toContext.viewController.view)
                self.tabBarToFrame = CGRect.init(
                    x: toContext.toFrame.minX,
                    y: containerView.bounds.maxY - tabBarFrame.height,
                    width: tabBarFrame.width,
                    height: tabBarFrame.height
                )
                tabBar.isFrameFrozen = true
            }
            
        }
    }
    
    /// 转场过程中的阴影视图。
    public class ShadowView: UIView {
        public override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor     = UIColor.white
            self.layer.shadowColor   = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.3
            self.layer.shadowRadius  = 5.0
            self.layer.shadowOffset  = .zero
        }
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}




// 转场过程中，各个函数先后执行顺序：
//Push:
//
//navigationController(_:animationControllerFor:from:to:)
//navigationController(_:interactionControllerFor:)
//<Example.SampleViewController: 0x7fa1a4434440> viewDidLoad()
//<Example.SampleViewController: 0x7fa1a6835bb0> viewWillDisappear
//<Example.SampleViewController: 0x7fa1a4434440> viewWillAppear
//navigationController(_:willShow:animated:)
//animateTransition(using:)
//animatePushTransition(using:) Config Animation.
//<Example.SampleViewController: 0x7fa1a4434440> viewWillLayoutSubviews()
//<Example.SampleViewController: 0x7fa1a4434440> viewDidLayoutSubviews()
//animatePushTransition(using:) Animation finished 1.
//<Example.SampleViewController: 0x7fa1a6835bb0> viewDidDisappear
//<Example.SampleViewController: 0x7fa1a4434440> viewDidAppear
//navigationController(_:didShow:animated:)
//animationEnded
//animationController(_:animatedTransitionDidEnd:)
//animatePushTransition(using:) Animation finished 2.
//
//Pop:
//
//navigationController(_:animationControllerFor:from:to:)
//navigationController(_:interactionControllerFor:)
//<Example.SampleViewController: 0x7fa1a4436850> viewWillDisappear
//<Example.SampleViewController: 0x7fa1a4434440> viewWillAppear
//navigationController(_:willShow:animated:)
//animateTransition(using:)
//animatePopTransition(using:) Config Animation.
//animatePopTransition(using:) Animation finished 1.
//<Example.SampleViewController: 0x7fa1a4436850> viewDidDisappear
//<Example.SampleViewController: 0x7fa1a4434440> viewDidAppear
//navigationController(_:didShow:animated:)
//animationEnded
//animationController(_:animatedTransitionDidEnd:)
//animatePopTransition(using:) Animation finished 2.
//
//
//Push Cancelled:
//
//navigationController(_:animationControllerFor:from:to:)
//navigationController(_:interactionControllerFor:)
//<Example.SampleViewController: 0x7fa1a683f830> viewDidLoad()
//<Example.SampleViewController: 0x7fa1a4436850> viewWillDisappear
//<Example.SampleViewController: 0x7fa1a683f830> viewWillAppear
//navigationController(_:willShow:animated:)
//animateTransition(using:)
//animatePushTransition(using:) Config Animation.
//<Example.SampleViewController: 0x7fa1a683f830> viewWillLayoutSubviews()
//<Example.SampleViewController: 0x7fa1a683f830> viewDidLayoutSubviews()
//animatePushTransition(using:) Animation finished 1.
//<Example.SampleViewController: 0x7fa1a683f830> viewWillDisappear
//<Example.SampleViewController: 0x7fa1a683f830> viewDidDisappear
//<Example.SampleViewController: 0x7fa1a4436850> viewWillAppear
//<Example.SampleViewController: 0x7fa1a4436850> viewDidAppear
//animationEnded
//animationController(_:animatedTransitionDidEnd:)
//animatePushTransition(using:) Animation finished 2.
//
//Pop Cancelled:
//
//navigationController(_:animationControllerFor:from:to:)
//navigationController(_:interactionControllerFor:)
//<Example.SampleViewController: 0x7fa1a4436850> viewWillDisappear
//<Example.SampleViewController: 0x7fa1a4434440> viewWillAppear
//navigationController(_:willShow:animated:)
//animateTransition(using:)
//animatePopTransition(using:) Config Animation.
//animatePopTransition(using:) Animation finished 1.
//<Example.SampleViewController: 0x7fa1a4434440> viewWillDisappear
//<Example.SampleViewController: 0x7fa1a4434440> viewDidDisappear
//<Example.SampleViewController: 0x7fa1a4436850> viewWillAppear
//<Example.SampleViewController: 0x7fa1a4436850> viewDidAppear
//animationEnded
//animationController(_:animatedTransitionDidEnd:)
//animatePopTransition(using:) Animation finished 2.
