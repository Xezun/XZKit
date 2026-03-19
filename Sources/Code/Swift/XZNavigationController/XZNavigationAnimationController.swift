//
//  XZNavigationAnimationController.swift
//  XZKit
//
//  Created by Xezun on 2017/7/11.
//
//

import UIKit

@MainActor public protocol XZNavigationAnimationControllerDelegate: AnyObject {
    
    /// 转场动画结束事件回调。
    ///
    /// 如果转场没有结束，应避免发起新的转场，否则定制化导航条可能无法显示。
    ///
    /// - Parameters:
    ///   - animationController: 转场动画控制器
    ///   - transitionCompleted: 转场是否完成
    func animationController(_ animationController: XZNavigationAnimationController, didEndTransitionAnimation transitionCompleted: Bool) -> Void
    
}

/// 动画控制器，处理了导航控制器的转场过程中的动画效果。
@MainActor open class XZNavigationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// 导航控制器。
    public unowned let navigationController: XZNavigationController
    
    /// 导航行为。
    public let operation: UINavigationController.Operation
    
    /// 此属性存在时，表示当前是一个交互式转场。
    public let interactionController: UIPercentDrivenInteractiveTransition?
    
    /// 是否为交互性动画。
    public var isInteractive: Bool {
        return interactionController != nil
    }
    
    /// 代理。
    public weak var delegate: XZNavigationAnimationControllerDelegate?
    
    /// 初始化。
    /// - Parameters:
    ///   - navigationController: 导航控制器
    ///   - operation: 导航类型
    ///   - isInteractive: 是否为交互式转场
    ///   - delegate: 接收事件的对象
    public init?(for navigationController: XZNavigationController, operation: UINavigationController.Operation, isInteractive: Bool, delegate: XZNavigationAnimationControllerDelegate?) {
        guard operation != .none else { return nil }
        self.navigationController  = navigationController
        self.operation             = operation
        self.interactionController = (isInteractive ? UIPercentDrivenInteractiveTransition() : nil)
        self.navigationBar = (navigationController.isNavigationBarHidden, navigationController.navigationBar.frame)
        self.delegate              = delegate
        super.init()
    }
    
    /// 在转场开始前，导航栏是否隐藏。
    ///
    /// 在动画的过程中，只能拿到原生导航栏当前的状态，此属性记录了原生导航栏在转场前是否隐藏，以便控制转场效果。
    fileprivate let navigationBar: (isHidden: Bool, frame: CGRect)
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    /// 4. 配置转场动画。
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let animationContext = XZNavigationAnimationContext(for: self, operation, transitionContext) else {
            return transitionContext.completeTransition(false)
        }
        #XZLog("[XZNavigationController] 配置转场动画 \(transitionContext) \n\(animationContext)", in: .XZKit)
        
        let options  : UIView.AnimationOptions = [self.isInteractive ? .curveLinear : .curveEaseInOut, .layoutSubviews]
        let delay    : TimeInterval            = 0
        let duration : TimeInterval            = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            animationContext.from.viewController.view.frame = animationContext.from.viewController.finalFrame;
            animationContext.to.viewController.view.frame   = animationContext.to.viewController.finalFrame;
            animationContext.shadow.view.frame              = animationContext.shadow.finalFrame
            
            if let navigationBar = animationContext.from.navigationBar {
                navigationBar.view.frame = navigationBar.finalFrame
            }
            
            if let navigationBar = animationContext.to.navigationBar {
                navigationBar.view.frame = navigationBar.finalFrame
            }
            
            if let navigationBar = animationContext.navigationBar {
                navigationBar.view.frame = navigationBar.finalFrame
                navigationBar.view.isFrozen = true
            }
            
            if let tabBar = animationContext.tabBar {
                tabBar.view.frame = tabBar.finalFrame
                tabBar.view.isFrozen = true
            }
        }, completion: { _ in
            animationContext.navigationBar?.view.isFrozen = false
            animationContext.tabBar?.view.isFrozen = false
            
            // 删除阴影。
            animationContext.shadow.view.removeFromSuperview()

            // 定制化导航栏在转场过程中，仅仅作为转场效果出现。将放置到导航栏上有导航控制器处理，所以这里要移除。
            // uiNavigationBar.frame = containerView.convert(uiNavigationBarFrame1, to: uiNavigationBar.superview)
            animationContext.from.navigationBar?.view.removeFromSuperview()
            animationContext.to.navigationBar?.view.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    /// 6. 转场结束。
    open func animationEnded(_ transitionCompleted: Bool) {
        // print("\(#function): \(transitionCompleted)");
        // 此方法在 UIViewControllerContextTransitioning.completeTransition(_:) 中被调用。
        // 且调用后，系统内部处理了一些操作，致使在这里处理取消导航的恢复操作无法生效，所以取消导航的恢复操作放在了动画的 completion 回调中处理。
        // navigationController.transitionController.navigationController(navigationController, animationController: self, animatedTransitionDidEnd: transitionCompleted)
        // 在此取 navigationController.topViewController 可能并不准确，因为 viewDidAppear 比此方法先调用，
        // 如果在 viewDidAppear 中 push 了新的控制器，那么这里的获取到的 topViewController 就是新的控制器。
        // 因此在此方法中无法设置当前的定制化导航栏。
        delegate?.animationController(self, didEndTransitionAnimation: transitionCompleted)
    }
    
}

/// 转场动画效果信息。
@MainActor public class XZNavigationAnimationContext: @MainActor CustomStringConvertible {
    
    /// 原生转场信息。
    private let context: UIViewControllerContextTransitioning
    
    /// 转场容器。
    public var containerView: UIView {
        return self.context.containerView
    }
    
    /// 导航操作类型。
    public let operation: UINavigationController.Operation
    
    /// 转场原始页面的视图、定制化 navigationBar 的信息。
    public var from: (viewController: ViewContext<UIView>, navigationBar: ViewContext<XZNavigationBarProtocol>?)
    
    /// 转场目标页面的视图、定制化 navigationBar 的信息。
    public var to: (viewController: ViewContext<UIView>, navigationBar: ViewContext<XZNavigationBarProtocol>?)
    
    /// 为转场提供阴影效果的视图的信息。
    public var shadow: ViewContext<UIView>
    
    /// 原生 navigationBar 的转场信息。原生 navigationBar 不在转场容器内。
    public var navigationBar: NavigationBarContext?
    
    /// 原生 tabBar 的转场信息。原生 navigationBar 不在转场容器内。
    public var tabBar: TabBarContext?
    
    fileprivate init(
        context: UIViewControllerContextTransitioning,
        operation: UINavigationController.Operation,
        from: (view: (UIView, CGRect), navigationBar: (XZNavigationBarProtocol?, CGRect?)),
        to: (view: (UIView, CGRect), navigationBar: (XZNavigationBarProtocol?, CGRect?)),
        navigationBar: (UINavigationBar?, CGRect?),
        tabBar: (UITabBar?, CGRect?),
        shadow: (UIView, CGRect)
    ) {
        self.context = context;
        self.operation = operation;
        self.from = (
            ViewContext(view: from.view.0, frame: from.view.1),
            ViewContext(from.navigationBar.0, from.navigationBar.1)
        );
        self.to = (
            ViewContext(view: to.view.0, frame: to.view.1),
            ViewContext(to.navigationBar.0, to.navigationBar.1)
        );
        self.navigationBar = NavigationBarContext(navigationBar.0, navigationBar.1);
        self.tabBar = TabBarContext(tabBar.0, tabBar.1)
        self.shadow = ViewContext(view: shadow.0, frame: shadow.1);
    }
    
    public convenience init?(for animationController: XZNavigationAnimationController, _ operation: UINavigationController.Operation, _ transitionContext: UIViewControllerContextTransitioning) {
        switch operation {
        case .push:
            self.init(for: animationController, pushContext: transitionContext)
        case .pop:
            self.init(for: animationController, popContext: transitionContext)
        default:
            return nil
        }
    }
    
    private convenience init?(for animationController: XZNavigationAnimationController, pushContext transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC   = transitionContext.viewController(forKey: .from),
              let fromView = transitionContext.view(forKey: .from),
              let toVC     = transitionContext.viewController(forKey: .to),
              let toView   = transitionContext.view(forKey: .to)
        else {
            return nil
        }
        
        let rootView = animationController.navigationController.view!
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
        let shadowView = XZNavigationTransitionShadowView.init(frame: shadowFrame1)
        containerView.insertSubview(shadowView, belowSubview: toView)
        
        // 处理原生导航栏的转场动画效果：
        // 1、转场容器与原生导航栏不在同一个层次上，且原生导航栏的层级更高，会覆盖在转场容器之上。
        // 2、在 iOS 26 之前，可以通过将原生导航栏移动到屏幕之外，来解决转场过程中，原生导航栏覆盖定制化导航栏的问题。
        // 3、在 iOS 26 开始，将原生导航栏移动到屏幕之外，它会在转场的过程中自己移动回来（也可能是玻璃效果）。
        // 4、通过锁定 frame 和 center 可以解决 iOS 26 导航栏自己移回来的问题。
        //
        // 【备忘】
        // 尝试过将原生导航栏 sendSubviewToBack 虽然转场过程中没有问题，但是下面的情形中，会发生问题：
        // 页面 A 导航栏显示，页面 B 导航栏隐藏，在 A => B 的手势转场中，如果取消了转场，那么在这个取消的转场
        // 完成之后，原生会将导航栏隐藏，即使在动画结束后，我们已经原生导航栏重新恢复到顶层。
        //
        // 所以最终采用将导航栏向上偏移到不可见范围，以避免转场的过程中，原生导航栏覆盖定制化导航栏的问题。
        // 原生导航栏的位置，在转场结束时，恢复到原始位置。
        //
        // 【已知问题】
        // 1、由于原生导航栏层级比转场视图高，所以从原生导航栏与定制化导航栏互相转场时，原生导航栏若不透明，则会遮挡住转场过程的阴影。
        //
        
        let uiNavigationBar = animationController.navigationController.navigationBar // 系统导航栏。
        let uiNavigationBarFrame1 = animationController.navigationBar.frame;
        var uiNavigationBarFrame2 = uiNavigationBar.frame
        let uiNavigationBarRect2  = rootView.convert(uiNavigationBarFrame2, to: containerView)
        
        let fromNavigationBar = (fromVC as? XZNavigationBarCustomizable)?.xzNavigationBar
        var fromNavigationBarFrame2: CGRect?
        if let fromNavigationBar = fromNavigationBar, !fromNavigationBar.isHidden {
            // 此处赋值用于判断导航栏处于显示状态
            fromNavigationBarFrame2 = .zero
            // fromNavigationBar 层级在 fromView 之上
            containerView.insertSubview(fromNavigationBar, aboveSubview: fromView)
        }
        
        let toNavigationBar = (toVC as? XZNavigationBarCustomizable)?.xzNavigationBar
        var toNavigationBarFrame2: CGRect?
        if let toNavigationBar = toNavigationBar, !toNavigationBar.isHidden {
            // 此处赋值用于判断导航栏处于显示状态
            toNavigationBarFrame2 = .zero
            // toNavigationBar 层级在 toView 之上
            containerView.insertSubview(toNavigationBar, aboveSubview: toView)
        }
        
        // 根据转场状态，配置原生导航栏和定制化导航栏的转场行为
        if fromNavigationBarFrame2 != nil && toNavigationBarFrame2 != nil {
            // from 有定制化导航栏
            let fromNavigationBarFrame1 = rootView.convert(fromNavigationBar!.frame, to: containerView)
            fromNavigationBar!.frame = fromNavigationBarFrame1
            fromNavigationBarFrame2  = fromNavigationBarFrame1.offsetBy(dx: -fromNavigationBarFrame1.width * 0.34 * direction, dy: 0);
            
            // to 有定制化导航栏
            toNavigationBarFrame2 = uiNavigationBarRect2
            toNavigationBar!.frame = uiNavigationBarRect2.offsetBy(dx: +uiNavigationBarRect2.width * direction, dy: 0)
            
            // 原生导航栏，移至屏幕外
            // 不能上移，否则会影响页面安全区，从而导致页面在转场的过程中，新页面发生抖动。
            // 在 iOS 26 中，以默认的堆叠模式呈现的导航控制器，在 Push 新控制器时，上移导航条，会导致 safeAreaInsets 改变。
            uiNavigationBarFrame2 = uiNavigationBarFrame2.offsetBy(dx: -uiNavigationBarFrame2.width * direction, dy: 0);
            uiNavigationBar.frame = uiNavigationBarFrame2
        } else if fromNavigationBarFrame2 != nil {
            // from 有定制化导航栏
            let fromNavigationBarFrame1 = rootView.convert(fromNavigationBar!.frame, to: containerView)
            fromNavigationBar!.frame = fromNavigationBarFrame1
            fromNavigationBarFrame2  = fromNavigationBarFrame1.offsetBy(dx: -fromNavigationBarFrame1.width * 0.34 * direction, dy: 0);
            
            // to 无定制化导航栏
            
            // 原生导航栏
            if animationController.navigationController.isNavigationBarHidden {
                // 无原生导航栏
                uiNavigationBarFrame2 = uiNavigationBarFrame2.offsetBy(dx: -uiNavigationBarFrame2.width * direction, dy: 0);
                uiNavigationBar.frame = uiNavigationBarFrame2
            } else {
                // 有原生导航栏，随 to 一起入场
                uiNavigationBar.frame = uiNavigationBarFrame2.offsetBy(dx: +uiNavigationBarFrame2.width * direction, dy: 0)
            }
        } else if toNavigationBarFrame2 != nil {
            // from 无定制化导航栏
            
            // to 有定制化导航栏，跟随入场
            toNavigationBar!.frame = uiNavigationBarRect2.offsetBy(dx: uiNavigationBarRect2.width * direction, dy: 0)
            toNavigationBarFrame2 = uiNavigationBarRect2;
            
            // 原生导航栏
            if animationController.navigationBar.isHidden {
                // 无原生导航栏
                uiNavigationBarFrame2 = uiNavigationBarFrame2.offsetBy(dx: -uiNavigationBarFrame2.width * direction, dy: 0);
                uiNavigationBar.frame = uiNavigationBarFrame2
            } else {
                // 有原生导航栏，随 from 一起退场
                // 由于 toView 无法覆盖原生导航栏，原生导航栏 100% 退场。
                uiNavigationBar.frame = uiNavigationBarFrame2;
                uiNavigationBarFrame2 = uiNavigationBarFrame2.offsetBy(dx: -uiNavigationBarFrame2.width * direction, dy: 0);
            }
        } else {
            if animationController.navigationController.isNavigationBarHidden && animationController.navigationBar.isHidden {
                // 原生导航条始终隐藏
            } else if (animationController.navigationController.isNavigationBarHidden) {
                // 原生导航条，从显示到隐藏
                uiNavigationBar.frame = uiNavigationBarFrame2;
                uiNavigationBarFrame2 = uiNavigationBarFrame2.offsetBy(dx: -uiNavigationBarFrame2.width * direction, dy: 0);
            } else if (animationController.navigationBar.isHidden) {
                // 原生导航条，从隐藏到显示
                uiNavigationBar.frame = uiNavigationBarFrame2.offsetBy(dx: +uiNavigationBarFrame2.width * direction, dy: 0)
            } else {
                // 原生导航条始终显示
            }
        }
        
        // 解决因为状态栏变化而造成的导航栏布局问题：
        // 导航栏 frame 没变，但是覆盖状态栏的背景，需要根据状态栏变化。
        fromNavigationBar?.layoutIfNeeded()
        toNavigationBar?.layoutIfNeeded()
        // 解决原生导航条布局问题：
        // 如果转场的两个定制化导航栏，其中一个是大标题模式，
        // 原生的导航栏虽然向上移动到了屏幕之外，但是其内容，比如标题或按钮，还是会覆盖定制化导航条。
        // uiNavigationBar.layoutIfNeeded()
        
        // 由于 tabBar 在最顶层，所以平移一个屏宽，而非三分之一。
        // 定制页签栏的转场效果的原因：
        // 1、在 right-to-left 书写方向的布局下，原生页签栏转场动画效果，平移方向不对。
        // 2、页签栏透明时，转场没有平移效果。
        var tabBar: UITabBar?
        var tabBarFrame2 = CGRect.zero
        if let tabBarController = animationController.navigationController.tabBarController {
            let viewControllers = animationController.navigationController.viewControllers
            if toVC.hidesBottomBarWhenPushed {
                if !viewControllers[0 ..< viewControllers.count - 1].contains(where: { $0.hidesBottomBarWhenPushed }) {
                    tabBar = tabBarController.tabBar
                    let frame = tabBar!.frame
                    tabBarFrame2 = frame.offsetBy(dx: direction * -frame.width, dy: 0)
                }
            }
        }
        
        self.init(
            context: transitionContext,
            operation: .push,
            from: ((fromView, fromViewFrame2), (fromNavigationBar, fromNavigationBarFrame2)),
            to: ((toView, toViewFrame2), (toNavigationBar, toNavigationBarFrame2)),
            navigationBar: (uiNavigationBar, uiNavigationBarFrame2),
            tabBar: (tabBar, tabBarFrame2),
            shadow: (shadowView, shadowFrame2)
        )
    }

    private convenience init?(for animationController: XZNavigationAnimationController, popContext transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC   = transitionContext.viewController(forKey: .from),
              let fromView = transitionContext.view(forKey: .from),
              let toVC     = transitionContext.viewController(forKey: .to),
              let toView   = transitionContext.view(forKey: .to)
        else {
            return nil
        }
        
        let rootView = animationController.navigationController.view!
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
        let shadowView = XZNavigationTransitionShadowView.init(frame: shadowFrame1)
        containerView.insertSubview(shadowView, belowSubview: fromView)
        
        // 转场容器与导航栏不在同一个层次上，坐标系需要转换。
        let uiNavigationBar = animationController.navigationController.navigationBar // 系统导航栏。
        let uiNavigationBarFrame1 = animationController.navigationBar.frame;
        var uiNavigationBarFrame2 = uiNavigationBar.frame
        let uiNavigationBarRect2  = rootView.convert(uiNavigationBarFrame2, to: containerView)
        
        let fromNavigationBar = (fromVC as? XZNavigationBarCustomizable)?.xzNavigationBar
        var fromNavigationBarFrame2: CGRect?
        if let fromNavigationBar = fromNavigationBar, !fromNavigationBar.isHidden {
            fromNavigationBarFrame2 = .zero;
            containerView.insertSubview(fromNavigationBar, aboveSubview: fromView)
        }
        
        let toNavigationBar = (toVC as? XZNavigationBarCustomizable)?.xzNavigationBar
        var toNavigationBarFrame2: CGRect?
        if let toNavigationBar = toNavigationBar, !toNavigationBar.isHidden {
            toNavigationBarFrame2 = .zero
            containerView.insertSubview(toNavigationBar, aboveSubview: toView)
        }
        
        if fromNavigationBarFrame2 != nil && toNavigationBarFrame2 != nil {
            let fromNavigationBarFrame1 = rootView.convert(fromNavigationBar!.frame, to: containerView)
            fromNavigationBar!.frame = fromNavigationBarFrame1
            fromNavigationBarFrame2 = fromNavigationBarFrame1.offsetBy(dx: +uiNavigationBarFrame1.width * direction, dy: 0);
            
            toNavigationBar!.frame = uiNavigationBarRect2.offsetBy(dx: -uiNavigationBarRect2.width * 0.34 * direction, dy: 0);
            toNavigationBarFrame2 = uiNavigationBarRect2
            
            uiNavigationBarFrame2 = uiNavigationBarFrame2.offsetBy(dx: +uiNavigationBarFrame2.width * direction, dy: 0);
            uiNavigationBar.frame = uiNavigationBarFrame2;
        } else if fromNavigationBarFrame2 != nil {
            let fromNavigationBarFrame1 = rootView.convert(fromNavigationBar!.frame, to: containerView)
            fromNavigationBar!.frame = fromNavigationBarFrame1
            fromNavigationBarFrame2 = fromNavigationBarFrame1.offsetBy(dx: +uiNavigationBarFrame1.width * direction, dy: 0);
            
            if animationController.navigationController.isNavigationBarHidden {
                uiNavigationBarFrame2 = uiNavigationBarFrame2.offsetBy(dx: +uiNavigationBarFrame2.width * direction, dy: 0);
                uiNavigationBar.frame = uiNavigationBarFrame2;
            } else {
                uiNavigationBar.frame = uiNavigationBarFrame2.offsetBy(dx: -uiNavigationBarFrame2.width * direction, dy: 0);
            }
        } else if toNavigationBarFrame2 != nil {
            toNavigationBar!.frame = uiNavigationBarRect2.offsetBy(dx: -uiNavigationBarRect2.width * 0.34 * direction, dy: 0);
            toNavigationBarFrame2 = uiNavigationBarRect2;
            
            if animationController.navigationBar.isHidden {
                uiNavigationBarFrame2 = uiNavigationBarFrame2.offsetBy(dx: +uiNavigationBarFrame2.width * direction, dy: 0);
                uiNavigationBar.frame = uiNavigationBarFrame2;
            } else {
                uiNavigationBar.frame = uiNavigationBarFrame1;
                uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: +uiNavigationBarFrame1.width * direction, dy: 0);
            }
        } else {
            if animationController.navigationController.isNavigationBarHidden && animationController.navigationBar.isHidden {
                // 原生导航条始终隐藏
            } else if (animationController.navigationController.isNavigationBarHidden) {
                // 原生导航条，从显示到隐藏
                uiNavigationBar.frame = uiNavigationBarFrame1;
                uiNavigationBarFrame2 = uiNavigationBarFrame1.offsetBy(dx: +uiNavigationBarFrame1.width * direction, dy: 0);
            } else if (animationController.navigationBar.isHidden) {
                // 原生导航条，从隐藏到显示
                uiNavigationBar.frame = uiNavigationBarFrame2.offsetBy(dx: -uiNavigationBarFrame2.width * direction, dy: 0);
            } else {
                // 原生导航条始终显示
            }
        }
        
        // 强制布局，避免定制化导航栏在动画前，未更新子元素布局
        fromNavigationBar?.layoutIfNeeded()
        toNavigationBar?.layoutIfNeeded()
        // 如果这里刷新原生导航栏，可能会导致原生导航栏 frame 发生改变，
        // 应该是触发了导航控制器刷新布局导致，导致上面初始化的导航栏位置实效。
        //
        // 问题复现：
        // iOS 26，A 页面原生导航栏，B 页面定制化导航栏，从 A 页面通过 push 进入 B 页面，然后在 B 页面触发导航返回手势。
        // 理论上原生导航栏，应该跟随 A 页面一起入场，但是。
        // 如果第一次返回手势中途取消，即保留在 B 页面，那么后续再进行手势返回时，原生导航栏的入场动画就会丢失。
        //
        // uiNavigationBar.layoutIfNeeded()
        
        // 由于 tabBar 的层级比较高，且将 tabBar 添加到 containerView 上，会导致 tabBar 在动画时到显示不正确
        // 所以 tabBar 是平移一个宽度，而页面仅平移了三分之一
        var tabBar: UITabBar?
        var tabBarFrame2 = CGRect.zero
        if let tabBarController = animationController.navigationController.tabBarController {
            // 已知在 popTo 的过程中，viewControllers 可能包含 fromVC 所以这里需要过滤。
            let viewControllers = animationController.navigationController.viewControllers.filter({ $0 != fromVC })
            if fromVC.hidesBottomBarWhenPushed {
                if !viewControllers.contains(where: { $0.hidesBottomBarWhenPushed }) {
                    tabBar = tabBarController.tabBar
                    let frame = tabBar!.frame;
                    tabBar!.frame = CGRect(x: direction * -frame.width, y: frame.origin.y, width: frame.width, height: frame.height);
                    tabBarFrame2 = CGRect(x: 0, y: frame.origin.y, width: frame.width, height: frame.height)
                }
            }
        }
        
        self.init(
            context: transitionContext,
            operation: .pop,
            from: ((fromView, fromViewFrame2), (fromNavigationBar, fromNavigationBarFrame2)),
            to: ((toView, toViewFrame2), (toNavigationBar, toNavigationBarFrame2)),
            navigationBar: (uiNavigationBar, uiNavigationBarFrame2),
            tabBar: (tabBar, tabBarFrame2),
            shadow: (shadowView, shadowFrame2)
        )
    }
    
    private func string(from rect: CGRect?) -> String {
        if let rect = rect {
            return String.init(describing: rect)
        }
        return "None"
    }
    
    public var description: String {
        return """
            from: {
                view: \(from.viewController.view.frame) => \(from.viewController.finalFrame),
                navigationBar: \(string(from: from.navigationBar?.view.frame)) => \(string(from: from.navigationBar?.finalFrame))
            },
            to: {
                view: \(to.viewController.view.frame) => \(to.viewController.finalFrame),
                navigationBar: \(string(from: to.navigationBar?.view.frame)) => \(string(from: to.navigationBar?.finalFrame)),
            },
            navigationBar: \(string(from: navigationBar?.view.frame)) => \(string(from: navigationBar?.finalFrame))
            tabBar: \(string(from: tabBar?.view.frame)) => \(string(from: tabBar?.finalFrame))
            """
    }
    
    /// 普通视图转场信息。
    public class ViewContext<T> {
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
    
    /// 导航栏转场信息。
    public class NavigationBarContext: ViewContext<UINavigationBar> {
    }
    
    /// 页签栏转场信息。
    public class TabBarContext: ViewContext<UITabBar> {
    }
}

/// 转场过程中的阴影视图。
fileprivate class XZNavigationTransitionShadowView: UIView {
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

// MARK: - Customization Navigation Supporting

// 由于不希望 isFrozen 属性外漏，所以下面一系列的运行时方法，不得不写一起。

extension UINavigationBar {
    
    /// 冻结时，不允许修改 frame 和 center 以解决转场过程中的动画效果问题。
    fileprivate var isFrozen: Bool {
        get {
            return (objc_getAssociatedObject(self, &_isFrozen) as? Bool) == true
        }
        set {
            objc_setAssociatedObject(self, &_isFrozen, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
}

extension UITabBar {
    
    /// 是否冻结。此属性为 true 时，更改属性 *frame* 不会生效。
    /// 
    /// 在 right-to-left 布局的环境中，当导航控制器使用了定制化的转场动画后，
    /// tabBar 在转场的过程中的动画效果，与 left-to-right 环境一样，不符合要求。
    /// 但是在转场的过程中，将 tabBar 添加的转场动画，不能生效，因此利用运行时机制，
    /// 在动画的过程中，让其它地方不能再修改 tabBar 的 frame 以避免这个问题。
    fileprivate var isFrozen: Bool {
        get {
            return (objc_getAssociatedObject(self, &_isFrozen) as? Bool) == true
        }
        set {
            objc_setAssociatedObject(self, &_isFrozen, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

}

extension UIView {
    
    public override var supportsNavigationCustomization: Bool {
        get {
            return false
        }
        set {
            if newValue == self.supportsNavigationCustomization {
                return
            }
            
            assert(self.next is UINavigationController, "[XZKit][XZNavigationController] Only UINavigationController's view can call this method.")
            
            if newValue {
                let oldClass = type(of: self);
                if let newClass = objc_getAssociatedObject(oldClass, &_navigationCustomizableClass) as? AnyClass {
                    object_setClass(self, newClass);
                } else {
                    let newClass: AnyClass = xz_objc_createClass(oldClass) { NewClass in
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
                    }
                    objc_setAssociatedObject(oldClass, &_navigationCustomizableClass, newClass, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    object_setClass(self, newClass);
                }
            } else {
                object_setClass(self, self.superclass!)
            }
        }
    }
    
}

extension UINavigationBar {
    
    public override var supportsNavigationCustomization: Bool {
        get {
            return false
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
                    let newClass: AnyClass = xz_objc_createClass(oldClass) { NewClass in
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
                    };
                    objc_setAssociatedObject(oldClass, &_navigationCustomizableClass, newClass, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    object_setClass(self, newClass);
                }
            } else {
                object_setClass(self, self.superclass!)
            }
        }
    }
}

extension UITabBar {
    
    public override var supportsNavigationCustomization: Bool {
        get {
            return false
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
                    let newClass: AnyClass = xz_objc_createClass(oldClass) { (NewClass) in
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
                    };
                    objc_setAssociatedObject(oldClass, &_navigationCustomizableClass, newClass, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    object_setClass(self, newClass);
                }
            } else {
                object_setClass(self, self.superclass!)
            }
        }
    }
    
}

extension UIViewController {
    
    public override var supportsNavigationCustomization: Bool {
        get {
            let ViewControllerClass = type(of: self)
            return objc_getAssociatedObject(ViewControllerClass, &_supportsNavigationCustomization) as? Bool == true
        }
        set {
            guard self is XZNavigationBarCustomizable else {
                return
            }
            
            // 因为控制器的类名，有较大概率会用于硬编码，所以不用子类的方式重写。
            // 如果 nil 说明未进行方法交换，如果已经执行方法交换，则不用再进行交换
            let ViewControllerClass = type(of: self)
            if objc_getAssociatedObject(ViewControllerClass, &_supportsNavigationCustomization) != nil {
                objc_setAssociatedObject(ViewControllerClass, &_supportsNavigationCustomization, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                return
            }
            objc_setAssociatedObject(ViewControllerClass, &_supportsNavigationCustomization, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            // 向 viewWillAppear 注入代码，同步定制化导航栏的状态给原生导航栏
            do {
                typealias MethodType = @convention(block) (UIViewController, Bool) -> Void
                
                let selector = #selector(UIViewController.viewWillAppear(_:))
                let override: MethodType = { `self`, animated in
                    xz_objc_msgSendSuper_void(self, ViewControllerClass, selector, animated)
                    self.viewController(of: ViewControllerClass, viewWillAppear: animated)
                }
                let exchange = { (selector: Selector) in
                    let exchange: MethodType = { `self`, animated in
                        xz_objc_msgSend_void(self, selector, animated)
                        self.viewController(of: ViewControllerClass, viewWillAppear: animated)
                    }
                    return exchange
                }
                xz_objc_class_addMethodWithBlock(ViewControllerClass, selector, nil, nil, override, exchange)
            }
            
            // 向 viewDidAppear 注入代码，设置当前的定制化导航栏。
            do {
                typealias MethodType = @convention(block) (UIViewController, Bool) -> Void
                
                let selector = #selector(UIViewController.viewDidAppear(_:))
                let override: MethodType = { `self`, animated in
                    self.viewController(of: ViewControllerClass, viewDidAppear: animated)
                    xz_objc_msgSendSuper_void(self, ViewControllerClass, selector, animated)
                }
                let exchange = { (selector: Selector) in
                    let exchange: MethodType = { `self`, animated in
                        self.viewController(of: ViewControllerClass, viewDidAppear: animated)
                        xz_objc_msgSend_void(self, selector, animated)
                    }
                    return exchange
                }
                xz_objc_class_addMethodWithBlock(ViewControllerClass, selector, nil, nil, override, exchange)
            }
        }
    }
    
    /// 在导航栈内控制器的 viewWillAppear 方法中注入的代码。
    ///
    /// 当此方法执行时，表明转场已开始，但是转场动画还未执行。
    ///
    /// 以在转场动画前，将定制化导航栏的配置，同步到原生导航栏，以保证在执行转场动画时，目标控制器的安全区设置正确。
    ///
    /// 此方法在用户的代码之后执行，以覆盖用户对原生导航栏的操作，保证原生导航栏按照定制化导航栏的设置运行。
    private func viewController(of ViewControllerClass: UIViewController.Type, viewWillAppear animated: Bool) {
        // 避免 VC 子类多次执行。
        guard type(of: self) == ViewControllerClass else {
            return
        }
        // 只有在开启了定制化导航的栈内才执行。
        guard let navigationController = self.navigationController as? XZNavigationController else {
            return
        }
        guard navigationController.isNavigationCustomizable else {
            return
        }
        // 获取定制化导航栏
        guard let xzNavigationBar = (self as? XZNavigationBarCustomizable)?.xzNavigationBar else {
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
            // 需要使用 navigationController 提供的方法来更新原生导航条的显示或隐藏状态，否则导航控制器可能不会刷新当前所显示控制器的布局。
            navigationController.setNavigationBarHidden(xzNavigationBar.isHidden, animated: animated)
        }
    }
    
    /// 在导航栈内控制器的 viewDidAppear 方法中注入的代码。
    ///
    /// 转场完成，定制化导航栏与原生导航栏绑定。任何对原生导航栏的操作，都会保存到定制化导航栏上，并用于下一次转场。
    private func viewController(of ViewControllerClass: UIViewController.Type, viewDidAppear animated: Bool) {
        // 避免 VC 子类多次执行。
        guard type(of: self) == ViewControllerClass else {
            return
        }
        guard let navigationController = self.navigationController as? XZNavigationController else {
            return
        }
        guard navigationController.isNavigationCustomizable else {
            return
        }
        let xzNavigationBar = (self as? XZNavigationBarCustomizable)?.xzNavigationBar;
        navigationController.xzNavigationBar = xzNavigationBar;
    }
    
}

extension UINavigationController {
    
    /// 转场开始，定制化导航栏与原生导航栏解除绑定。转场过程中的导航栏操作，最终会在 viewWillAppear 的注入逻辑覆盖。
    private func prepareForCustomizableNavigationTransitioning(_ animated: Bool) {
        self.xzNavigationBar = nil;
    }
    
    public override var supportsNavigationCustomization: Bool {
        get {
            let NavigationControllerClass = type(of: self)
            return objc_getAssociatedObject(NavigationControllerClass, &_supportsNavigationCustomization) as? Bool == true
        }
        set {
            guard self is XZNavigationController else {
                return
            }
            
            let NavigationControllerClass = type(of: self)
            if objc_getAssociatedObject(NavigationControllerClass, &_supportsNavigationCustomization) != nil {
                objc_setAssociatedObject(NavigationControllerClass, &_supportsNavigationCustomization, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                return
            }
            objc_setAssociatedObject(NavigationControllerClass, &_supportsNavigationCustomization, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            // 向导航入栈出栈的方法中注入代码：
            // 1，让入栈的控制器支持定制化导航。
            // 2，让导航控制器进入执行转场准备操作。
            
            do {
                typealias MethodType = @convention(block) (UINavigationController, UIViewController, Bool) -> Void
                // 导航控制器，同一控制器不能重复 push 不论栈顶还是栈中，否则崩溃，所以这里不需要判断。
                // 在 push 方法调用的过程中，目标控制器没有任何生命周期函数被调用，所以可以在 super.push 之后再执行转场准备工作。
                let selector = #selector(UINavigationController.pushViewController(_:animated:));
                let override: MethodType = { `self`, viewController, animated in
                    viewController.supportsNavigationCustomization = true
                    xz_objc_msgSendSuper_void(self, NavigationControllerClass, selector, viewController, animated);
                    self.prepareForCustomizableNavigationTransitioning(animated)
                }
                let exchange = { (selector: Selector) in
                    let exchange: MethodType = { `self`, viewController, animated in
                        viewController.supportsNavigationCustomization = true;
                        xz_objc_msgSend_void(self, selector, viewController, animated);
                        self.prepareForCustomizableNavigationTransitioning(animated);
                    }
                    return exchange
                }
                xz_objc_class_addMethodWithBlock(NavigationControllerClass, selector, nil, nil, override, exchange)
            }
            
            do {
                typealias MethodType = @convention(block) (UINavigationController, [UIViewController], Bool) -> Void
                
                let selector = #selector(UINavigationController.setViewControllers(_:animated:));
                let override: MethodType = { `self`, viewControllers, animated in
                    for viewController in viewControllers {
                        viewController.supportsNavigationCustomization = true
                    }
                    let topViewController = self.topViewController
                    xz_objc_msgSendSuper_void(self, NavigationControllerClass, selector, viewControllers, animated)
                    if topViewController != viewControllers.last { // 说明发生了转场
                        self.prepareForCustomizableNavigationTransitioning(animated)
                    }
                }
                let exchange = { (selector: Selector) in
                    let exchange: MethodType = { `self`, viewControllers, animated in
                        for viewController in viewControllers {
                            viewController.supportsNavigationCustomization = true
                        }
                        let topViewController = self.topViewController
                        xz_objc_msgSend_void(self, selector, viewControllers, animated)
                        if topViewController != viewControllers.last {
                            self.prepareForCustomizableNavigationTransitioning(animated)
                        }
                    }
                    return exchange
                }
                xz_objc_class_addMethodWithBlock(NavigationControllerClass, selector, nil, nil, override, exchange)
            }
            
            do {
                typealias MethodType = @convention(block) (UINavigationController, Bool) -> UIViewController?
                
                let selector = #selector(UINavigationController.popViewController(animated:));
                let override: MethodType = { `self`, animated in
                    let viewController = xz_objc_msgSendSuper_id(self, NavigationControllerClass, selector, animated) as? UIViewController;
                    if viewController != nil {
                        self.prepareForCustomizableNavigationTransitioning(animated)
                    }
                    return viewController
                }
                let exchange = { (selector: Selector) in
                    let exchange: MethodType = { `self`, animated in
                        let viewController = xz_objc_msgSend_id(self, selector, animated) as? UIViewController
                        if viewController != nil {
                            self.prepareForCustomizableNavigationTransitioning(animated)
                        }
                        return viewController
                    }
                    return exchange
                }
                xz_objc_class_addMethodWithBlock(NavigationControllerClass, selector, nil, nil, override, exchange)
            }
            
            do {
                typealias MethodType = @convention(block) (UINavigationController, UIViewController, Bool) -> [UIViewController]?
                
                let selector = #selector(UINavigationController.popToViewController(_:animated:));
                let override: MethodType = { `self`, viewController, animated in
                    let viewControllers = xz_objc_msgSendSuper_id(self, NavigationControllerClass, selector, viewController, animated) as? [UIViewController]
                    if let viewControllers = viewControllers, viewControllers.count > 0 {
                        self.prepareForCustomizableNavigationTransitioning(animated)
                    }
                    return viewControllers
                }
                let exchange = { (selector: Selector) in
                    let exchange: MethodType = { `self`, viewController, animated in
                        let viewControllers = xz_objc_msgSend_id(self, selector, viewController, animated) as? [UIViewController]
                        if let viewControllers = viewControllers, viewControllers.count > 0 {
                            self.prepareForCustomizableNavigationTransitioning(animated)
                        }
                        return viewControllers
                    }
                    return exchange
                }
                xz_objc_class_addMethodWithBlock(NavigationControllerClass, selector, nil, nil, override, exchange)
            }
            
            do {
                typealias MethodType = @convention(block) (UINavigationController, Bool) -> [UIViewController]?
                let selector = #selector(UINavigationController.popToRootViewController(animated:));
                let override: MethodType = { `self`, animated in
                    let viewControllers = xz_objc_msgSendSuper_id(self, NavigationControllerClass, selector, animated) as? [UIViewController]
                    if let viewControllers = viewControllers, viewControllers.count > 0 {
                        self.prepareForCustomizableNavigationTransitioning(animated)
                    }
                    return viewControllers
                }
                let exchange = { (selector: Selector) in
                    let exchange: MethodType = { `self`, animated in
                        let viewControllers = xz_objc_msgSend_id(self, selector, animated) as? [UIViewController]
                        if let viewControllers = viewControllers, viewControllers.count > 0 {
                            self.prepareForCustomizableNavigationTransitioning(animated)
                        }
                        return viewControllers
                    }
                    return exchange
                }
                xz_objc_class_addMethodWithBlock(NavigationControllerClass, selector, nil, nil, override, exchange)
            }
        }
    }
    
}

// 在 objc_msgSendSuper 中使用 self.class 获取当前对象的 Class 那么子类在调用这个方法时就会产生死循环。
// 但是在这里，实际使用的是动态派生的类，没有子类，可以不用考虑这个问题。

// 当向导航控制器根视图添加子视图时，保证定制化导航栏始终显示在最上面。
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

/// 修改原生导航栏样式时，同步状态给定制化导航栏。
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
            
            guard let xzNavigationBar = self.xzNavigationBar else { return }
            
            xzNavigationBar.bounds = newValue;
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
            // 不能拦截此方法，在 iOS 26 中，会导致 hidesBottomBarWhenPushed 无法生效。
            // 在 iOS 26 中，拦截此方法后，第二个页面的 tabBar 还是隐藏的，但是从第三个开始 tabBar 就不隐藏了。
            if isFrozen {
                return
            }
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.isHidden), newValue)
            fatalError("此方法不会被调用")
        }
    }
}

/// 记录 navigationBar 或 tabBar 是否锁定 frame/center/bounds
@MainActor private var _isFrozen = 0
/// 记录视图使用子类实现“定制化导航”支持功能的类的定制化子类。
@MainActor private var _navigationCustomizableClass = 0;
/// 记录导航控制器或控制器是否已经通过“方法交换”实现“定制化导航”支持功能的标记
@MainActor private var _supportsNavigationCustomization = 0;
