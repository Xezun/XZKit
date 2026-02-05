//
//  XZNavigationAnimationController.swift
//  XZKit
//
//  Created by Xezun on 2017/7/11.
//
//

import UIKit

/// 动画控制器，处理了导航控制器的转场过程中的动画效果。
@MainActor open class XZNavigationAnimationController: NSObject {
    
    /// 导航控制器。
    public unowned let navigationController: XZNavigationController
    
    /// 导航行为。
    public let operation: UINavigationController.Operation
    
    /// 此属性存在时，表示当前是一个交互式转场。
    public let interactiveTransition: UIPercentDrivenInteractiveTransition?
    
    /// 是否为交互性动画。
    public var isInteractive: Bool {
        return interactiveTransition != nil
    }
    
    /// 在动画的过程中，只能拿到原生导航条当前的状态，此属性记录了原生导航条在转场前是否隐藏，以便控制转场效果。
    let isNavigationBarHidden: Bool
    
    public init?(for navigationController: XZNavigationController, operation: UINavigationController.Operation, isInteractive: Bool) {
        guard operation != .none else { return nil }
        self.navigationController  = navigationController
        self.operation             = operation
        self.interactiveTransition = (isInteractive ? UIPercentDrivenInteractiveTransition() : nil)
        self.isNavigationBarHidden = navigationController.isNavigationBarHidden
        super.init()
    }
    
    /// 提供子类重写，自定义转场动画。
    ///
    /// - Parameters:
    ///   - context: 参与转场的视图，以及视图的目标状态。
    open func prepareTransitionAnimations(with context: XZNavigationAnimationContext) {
        
    }
    
}

extension XZNavigationAnimationController: UIViewControllerAnimatedTransitioning {
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    /// 4. 配置转场动画。
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch operation {
        case .push:
            animatePushTransition(using: transitionContext)
        case .pop:
            animatePopTransition(using: transitionContext)
        default:
            break
        }
    }
    
    /// 6. 转场结束。
    open func animationEnded(_ transitionCompleted: Bool) {
        // print("\(#function): \(transitionCompleted)");
        // 此方法在 UIViewControllerContextTransitioning.completeTransition(_:) 中被调用。
        // 且调用后，系统内部处理了一些操作，致使在这里处理取消导航的恢复操作无法生效，所以取消导航的恢复操作放在了动画的 completion 回调中处理。
        // navigationController.transitionController.navigationController(navigationController, animationController: self, animatedTransitionDidEnd: transitionCompleted)
        // 在此取 navigationController.topViewController 可能并不准确，因为 viewDidAppear 比此方法先调用，
        // 如果在 viewDidAppear 中 push 了新的控制器，那么这里的获取到的 topViewController 就是新的控制器。
        // 因此在此方法中无法设置当前的自定义导航条。
    }
    
    /// 执行 Push 动画。
    ///
    /// - Parameter transitionContext: 转场信息。
    private func animatePushTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC   = transitionContext.viewController(forKey: .from),
              let fromView = transitionContext.view(forKey: .from),
              let toVC     = transitionContext.viewController(forKey: .to),
              let toView   = transitionContext.view(forKey: .to)
        else {
            return transitionContext.completeTransition(false)
        }
        
        let containerView = transitionContext.containerView
        let direction: CGFloat = containerView.effectiveUserInterfaceLayoutDirection == .leftToRight ? 1.0 : -1.0
        
        // 配置旧视图
        let fromViewFrame1 = transitionContext.initialFrame(for: fromVC)
        let fromViewFrame2 = fromViewFrame1.offsetBy(dx: direction * -fromViewFrame1.width / 3.0, dy: 0)
        fromView.frame = fromViewFrame1
        containerView.addSubview(fromView)
        
        // 配置新视图
        let toViewFrame2 = transitionContext.finalFrame(for: toVC)
        let toViewFrame1 = toViewFrame2.offsetBy(dx: direction * toViewFrame2.width, dy: 0)
        toView.frame = toViewFrame1
        containerView.addSubview(toView)
        
        // 阴影
        let shadowFrame2 = containerView.bounds // vc 可能要比 containerView 小，不能直接用 vc 的 frame
        let shadowFrame1 = shadowFrame2.offsetBy(dx: direction * shadowFrame2.width, dy: 0);
        let shadowView = XZNavigationShadowView.init(frame: shadowFrame1)
        containerView.insertSubview(shadowView, belowSubview: toView)
        
        // 处理原生导航条的转场动画效果：
        // 1、转场容器与原生导航条不在同一个层次上，且原生导航条的层级更高，会覆盖在转场容器之上。
        // 2、在 iOS 26 之前，可以通过将原生导航条移动到屏幕之外，来解决转场过程中，原生导航条覆盖自定义导航条的问题。
        // 3、在 iOS 26 开始，将原生导航条移动到屏幕之外，它会在转场的过程中自己移动回来（也可能是玻璃效果），即使锁定 frame 也无法阻止。
        //
        // 虽然自定义导航条与控制器一同转场效果最好，但是很明显，苹果的原生导航条写的一塌糊涂，至少这个动画跟转场不对付，所以。
        //
        // 【备忘】尝试过将原生导航条 sendSubviewToBack 虽然转场过程中没有问题，但是下面的情形中，会发生问题：
        // 页面 A 导航条显示，页面 B 导航条隐藏，在 A => B 的手势转场中，如果取消了转场，那么在这个取消的转场
        // 完成之后，原生会将导航条隐藏，即使在动画结束后，我们已经原生导航条重新恢复到顶层。
        //
        // 所以最终采用将导航条向上偏移 200 点或导航条的高度，以避免转场的过程中，原生导航条覆盖自定义导航条的问题。
        // 原生导航条的位置，在转场结束时，恢复到原始位置。
        let uiNavigationBar = navigationController.navigationBar // 系统导航条。
        let uiNavigationBarFrame1 = uiNavigationBar.convert(uiNavigationBar.bounds, to: containerView);
        var uiNavigationBarFrame2: CGRect?
        
        let fromNavigationBar = (fromVC as? XZNavigationBarCustomizable)?.xzNavigationBar
        var fromNavigationBarFrame2: CGRect?
        if let fromNavigationBar = fromNavigationBar, !fromNavigationBar.isHidden {
            // 此处赋值用于判断导航条处于显示状态
            fromNavigationBarFrame2 = .zero
            // fromNavigationBar 层级在 fromView 之上
            containerView.insertSubview(fromNavigationBar, aboveSubview: fromView)
            // 解决因为状态栏变化而造成的导航条布局问题：导航条 frame 没变，但是覆盖状态栏的背景，需要根据状态栏变化。
            fromNavigationBar.setNeedsLayout()
        }
        
        let toNavigationBar = (toVC as? XZNavigationBarCustomizable)?.xzNavigationBar
        var toNavigationBarFrame2: CGRect?
        if let toNavigationBar = toNavigationBar, !toNavigationBar.isHidden {
            // 此处赋值用于判断导航条处于显示状态
            toNavigationBarFrame2 = .zero
            // toNavigationBar 层级在 toView 之上
            containerView.insertSubview(toNavigationBar, aboveSubview: toView)
            // 解决因为状态栏变化而造成的导航条布局问题：导航条 frame 没变，但是覆盖状态栏的背景，需要根据状态栏变化。
            toNavigationBar.setNeedsLayout()
        }
        
        // 根据转场状态，配置原生导航条和自定义导航条的转场行为
        if fromNavigationBarFrame2 != nil && toNavigationBarFrame2 != nil {
            // 导航条：一直显示
            fromNavigationBar!.frame = uiNavigationBarFrame1
            fromNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: -uiNavigationBarFrame1.width * 0.34 * direction, dy: 0);
            toNavigationBar!.frame = uiNavigationBarFrame1.offsetBy(dx: uiNavigationBarFrame1.width * direction, dy: 0)
            toNavigationBarFrame2 = uiNavigationBarFrame1;
            // 将原生导航条，上移至屏幕外
            uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: 0, dy: -abs(uiNavigationBarFrame1.maxY));
            uiNavigationBar.frame = uiNavigationBarFrame2!
        } else if fromNavigationBarFrame2 != nil {
            // 自定义导航条：显示 => 隐藏
            fromNavigationBar!.frame = uiNavigationBarFrame1
            fromNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: -uiNavigationBarFrame1.width * 0.34 * direction, dy: 0);
            // 根据原生导航条的状态，判断 toView 是否显示原生导航条
            if navigationController.isNavigationBarHidden {
                // toView 不显示原生导航条，且没有自定义导航条或自定义导航条隐藏
                // 因为原生导航条可能有隐藏动画，将原生导航条，上移至屏幕外，避免与遮挡自定义导航条
                uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: 0, dy: -abs(uiNavigationBarFrame1.maxY));
                uiNavigationBar.frame = uiNavigationBarFrame2!
            } else {
                // toView 显示原生导航条，原生导航条随目标页面一起入场
                uiNavigationBar.frame = uiNavigationBarFrame1.offsetBy(dx: uiNavigationBarFrame1.width * direction, dy: 0);
                uiNavigationBarFrame2 = uiNavigationBarFrame1
            }
        } else if toNavigationBarFrame2 != nil {
            // 自定义导航条：隐藏 => 显示
            toNavigationBar!.frame = uiNavigationBarFrame1.offsetBy(dx: uiNavigationBarFrame1.width * direction, dy: 0)
            toNavigationBarFrame2 = uiNavigationBarFrame1;
            // 根据导航条转场前的状态，判断from页面是否有自定义导航条
            if self.isNavigationBarHidden {
                // fromView 不显示原生导航条，且没有自定义导航条或自定义导航条隐藏
                uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: 0, dy: -abs(uiNavigationBarFrame1.maxY));
                uiNavigationBar.frame = uiNavigationBarFrame2!
            } else {
                // fromView 显示原生导航条，原生导航条随 fromView 一起退场
                // 原生导航条随 fromView 一起退场，由于 toView 无法覆盖原生导航条，原生导航条 100% 退场。
                uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: -uiNavigationBarFrame1.width * direction, dy: 0);
            }
        } else {
            // nav bar is hidden
        }
        
        // 由于 tabBar 在最顶层，所以平移一个屏宽，而非三分之一
        var tabBar: UITabBar?
        var tabBarFrame2 = CGRect.zero
        if direction < 0, let tabBarController = navigationController.tabBarController {
            let viewControllers = navigationController.viewControllers
            if toVC.hidesBottomBarWhenPushed {
                if !viewControllers[0 ..< viewControllers.count - 1].contains(where: { $0.hidesBottomBarWhenPushed }) {
                    tabBar = tabBarController.tabBar
                    let frame = tabBar!.frame
                    tabBarFrame2 = frame.offsetBy(dx: direction * -frame.width, dy: 0)
                }
            }
        }
        
        let context = XZNavigationAnimationContext(
            operation: .push,
            containerView: containerView,
            from: ((fromView, fromViewFrame2), (fromNavigationBar, fromNavigationBarFrame2)),
            to: ((toView, toViewFrame2), (toNavigationBar, toNavigationBarFrame2)),
            navigationBar: (uiNavigationBar, uiNavigationBarFrame2),
            tabBar: (tabBar, tabBarFrame2),
            shadow: (shadowView, shadowFrame2),
            options: self.isInteractive ? .curveLinear : .curveEaseInOut
        )
        
        self.prepareTransitionAnimations(with: context)
        self.executeTransitionAnimations(with: context, using: transitionContext);
    }

    /// 执行 pop 动画。
    ///
    /// - Parameter transitionContext: 转场信息。
    private func animatePopTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC   = transitionContext.viewController(forKey: .from),
              let fromView = transitionContext.view(forKey: .from),
              let toVC     = transitionContext.viewController(forKey: .to),
              let toView   = transitionContext.view(forKey: .to)
        else {
            return transitionContext.completeTransition(false)
        }
        
        let containerView = transitionContext.containerView
        let direction: CGFloat = containerView.effectiveUserInterfaceLayoutDirection == .leftToRight ? 1.0 : -1.0
        
        // 配置旧视图。
        let fromViewFrame1 = transitionContext.initialFrame(for: fromVC)
        let fromViewFrame2 = fromViewFrame1.offsetBy(dx: direction * fromViewFrame1.width, dy: 0)
        fromView.frame = fromViewFrame1
        containerView.addSubview(fromView)
        
        // 配置新视图。
        let toViewFrame2 = transitionContext.finalFrame(for: toVC)
        let toViewFrame1 = toViewFrame2.offsetBy(dx: direction * -toViewFrame2.width / 3.0, dy: 0)
        toView.frame = toViewFrame1
        containerView.insertSubview(toView, belowSubview: fromView)
        
        // 阴影
        let shadowFrame1 = containerView.bounds
        let shadowFrame2 = shadowFrame1.offsetBy(dx: direction * shadowFrame1.width, dy: 0)
        let shadowView = XZNavigationShadowView.init(frame: shadowFrame1)
        containerView.insertSubview(shadowView, belowSubview: fromView)
        
        // 转场容器与导航条不在同一个层次上，坐标系需要转换。
        let uiNavigationBar = navigationController.navigationBar // 系统导航条。
        let uiNavigationBarFrame1 = uiNavigationBar.convert(uiNavigationBar.bounds, to: containerView);
        var uiNavigationBarFrame2: CGRect?
        
        let fromNavigationBar = (fromVC as? XZNavigationBarCustomizable)?.xzNavigationBar
        var fromNavigationBarFrame2: CGRect?
        if let fromNavigationBar = fromNavigationBar, !fromNavigationBar.isHidden {
            fromNavigationBarFrame2 = .zero;
            containerView.insertSubview(fromNavigationBar, aboveSubview: fromView)
            fromNavigationBar.setNeedsLayout()
        }
        
        let toNavigationBar = (toVC as? XZNavigationBarCustomizable)?.xzNavigationBar
        var toNavigationBarFrame2: CGRect?
        if let toNavigationBar = toNavigationBar, !toNavigationBar.isHidden {
            toNavigationBarFrame2 = .zero
            containerView.insertSubview(toNavigationBar, aboveSubview: toView)
            toNavigationBar.setNeedsLayout()
        }
        
        if fromNavigationBarFrame2 != nil && toNavigationBarFrame2 != nil {
            fromNavigationBar!.frame = uiNavigationBarFrame1;
            fromNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: uiNavigationBarFrame1.width * direction, dy: 0);
            
            toNavigationBar!.frame = uiNavigationBarFrame1.offsetBy(dx: -uiNavigationBarFrame1.width * 0.34 * direction, dy: 0);
            toNavigationBarFrame2 = uiNavigationBarFrame1
            
            uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: 0, dy: -abs(uiNavigationBarFrame1.maxY));
            uiNavigationBar.frame = uiNavigationBarFrame2!
        } else if fromNavigationBarFrame2 != nil {
            fromNavigationBar!.frame = uiNavigationBarFrame1;
            fromNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: +uiNavigationBarFrame1.width * direction, dy: 0);
            
            if navigationController.isNavigationBarHidden {
                uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: 0, dy: -abs(uiNavigationBarFrame1.maxY));
                uiNavigationBar.frame = uiNavigationBarFrame2!
            } else {
                uiNavigationBar.frame = uiNavigationBarFrame1.offsetBy(dx: -uiNavigationBarFrame1.width * direction, dy: 0);
                uiNavigationBarFrame2 = uiNavigationBarFrame1;
            }
        } else if toNavigationBarFrame2 != nil {
            toNavigationBar!.frame = uiNavigationBarFrame1.offsetBy(dx: -uiNavigationBarFrame1.width * 0.34 * direction, dy: 0);
            toNavigationBarFrame2 = uiNavigationBarFrame1;
            
            if self.isNavigationBarHidden {
                uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: 0, dy: -abs(uiNavigationBarFrame1.maxY));
                uiNavigationBar.frame = uiNavigationBarFrame2!
            } else {
                uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: +uiNavigationBarFrame1.width, dy: 0);
            }
        } else {
            // nav bar is hidden
        }
         
        // 由于 tabBar 的层级比较高，且将 tabBar 添加到 containerView 上，会导致 tabBar 在动画时到显示不正确
        // 所以 tabBar 是平移一个宽度，而页面仅平移了三分之一
        var tabBar: UITabBar?
        var tabBarFrame2 = CGRect.zero
        if direction < 0, let tabBarController = navigationController.tabBarController {
            // 已知在 popTo 的过程中，viewControllers 可能包含 fromVC 所以这里需要过滤。
            let viewControllers = navigationController.viewControllers.filter({ $0 != fromVC })
            if fromVC.hidesBottomBarWhenPushed {
                if !viewControllers.contains(where: { $0.hidesBottomBarWhenPushed }) {
                    tabBar = tabBarController.tabBar
                    let frame = tabBar!.frame;
                    tabBar!.frame = CGRect(x: direction * -frame.width, y: frame.origin.y, width: frame.width, height: frame.height);
                    tabBarFrame2 = CGRect(x: 0, y: frame.origin.y, width: frame.width, height: frame.height)
                }
            }
        }
        
        let context = XZNavigationAnimationContext(
            operation: .pop,
            containerView: containerView,
            from: ((fromView, fromViewFrame2), (fromNavigationBar, fromNavigationBarFrame2)),
            to: ((toView, toViewFrame2), (toNavigationBar, toNavigationBarFrame2)),
            navigationBar: (uiNavigationBar, uiNavigationBarFrame2),
            tabBar: (tabBar, tabBarFrame2),
            shadow: (shadowView, shadowFrame2)
        )
        
        prepareTransitionAnimations(with: context);
        executeTransitionAnimations(with: context, using: transitionContext);
    }
    
    private func executeTransitionAnimations(with context: XZNavigationAnimationContext, using transitionContext: UIViewControllerContextTransitioning) {
        let options  = context.options
        let delay    = context.delay;
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            context.from.viewController.view.frame = context.from.viewController.finalFrame;
            context.to.viewController.view.frame   = context.to.viewController.finalFrame;
            context.shadow.view.frame              = context.shadow.finalFrame
            
            if let navigationBar = context.from.navigationBar {
                navigationBar.view.frame = navigationBar.finalFrame
            }
            if let navigationBar = context.to.navigationBar {
                navigationBar.view.frame = navigationBar.finalFrame
            }
            
            if let navigationController = context.navigationController {
                navigationController.navigationBar.frame = navigationController.finalFrame
                navigationController.navigationBar.isFrozen = true
            }
            if let tabBarController = context.tabBarController {
                tabBarController.tabBar.frame = tabBarController.finalFrame
                tabBarController.tabBar.isFrozen = true
            }
        }, completion: { _ in
            context.navigationController?.navigationBar.isFrozen = false
            context.tabBarController?.tabBar.isFrozen = false
            
            // 删除阴影。
            context.shadow.view.removeFromSuperview()

            // 自定义导航条在转场过程中，仅仅作为转场效果出现，将起放置到导航条上有导航控制器处理，所以这里要移除。
            // uiNavigationBar.frame = containerView.convert(uiNavigationBarFrame1, to: uiNavigationBar.superview)
            context.from.navigationBar?.view.removeFromSuperview()
            context.to.navigationBar?.view.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}

/// 转场过程中的阴影视图。
fileprivate class XZNavigationShadowView: UIView {
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


public class XZNavigationAnimationContext {
    
    public class ViewControllerContext<T> {
        public let view: T
        public var finalFrame: CGRect
        convenience init?(_ view: T?, _ frame: CGRect?) {
            guard let view = view, let frame = frame else { return nil }
            self.init(view: view, frame: frame)
        }
        init(view: T, frame: CGRect) {
            self.view = view
            self.finalFrame = frame
        }
    }
    
    public class NavigationControllerContext {
        public let navigationBar: UINavigationBar
        public var finalFrame: CGRect
        init?(_ navigationBar: UINavigationBar?, _ finalFrame: CGRect?) {
            guard let navigationBar = navigationBar, let finalFrame = finalFrame else { return nil }
            self.navigationBar = navigationBar
            self.finalFrame = finalFrame
        }
    }
    
    public class TabBarControllerContext {
        public let tabBar: UITabBar
        public var finalFrame: CGRect
        init?(_ tabBar: UITabBar?, _ finalFrame: CGRect?) {
            guard let tabBar = tabBar, let finalFrame = finalFrame else { return nil }
            self.tabBar = tabBar
            self.finalFrame = finalFrame
        }
    }
    
    public let containerView: UIView
    public let operation: UINavigationController.Operation
    
    public var from: (viewController: ViewControllerContext<UIView>, navigationBar: ViewControllerContext<XZNavigationBar>?)
    public var to: (viewController: ViewControllerContext<UIView>, navigationBar: ViewControllerContext<XZNavigationBar>?)
    public var navigationController: NavigationControllerContext?
    public var tabBarController: TabBarControllerContext?
    public var shadow: ViewControllerContext<UIView>
    
    public var options: UIView.AnimationOptions
    public var delay: TimeInterval = 0
    
    init(
        operation: UINavigationController.Operation,
        containerView: UIView,
        from: (view: (UIView, CGRect), navigationBar: (XZNavigationBar?, CGRect?)),
        to: (view: (UIView, CGRect), navigationBar: (XZNavigationBar?, CGRect?)),
        navigationBar: (UINavigationBar?, CGRect?),
        tabBar: (UITabBar?, CGRect?),
        shadow: (UIView, CGRect),
        options: UIView.AnimationOptions = .curveLinear
    ) {
        self.operation = operation;
        self.containerView = containerView;
        self.from = (
            ViewControllerContext(view: from.view.0, frame: from.view.1),
            ViewControllerContext(from.navigationBar.0, from.navigationBar.1)
        );
        self.to = (
            ViewControllerContext(view: to.view.0, frame: to.view.1),
            ViewControllerContext(to.navigationBar.0, to.navigationBar.1)
        );
        self.navigationController = NavigationControllerContext(navigationBar.0, navigationBar.1);
        self.tabBarController = TabBarControllerContext(tabBar.0, tabBar.1)
        self.shadow = ViewControllerContext(view: shadow.0, frame: shadow.1);
        self.options = options
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
