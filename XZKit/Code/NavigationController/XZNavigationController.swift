//
//  TTNavigationController.swift
//  XZKit
//
//  Created by Xezun on 2017/2/17.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit

/// NavigationController 提供了 全屏手势 和 自定义导航条 的功能。
/// - Note: 当栈内控制器支持自定义时，系统自带导航条将不可见（非隐藏）。
/// - Note: 当控制器专场时，自动根据控制器自定义导航条状态，设置系统导航条状态。
@objc(XZNavigationController)
open class NavigationController: UINavigationController, UINavigationControllerDelegate {
    
    /// 转场控制器。
    public private(set) lazy var transitionController = NavigationController.TransitionController.init(for: self)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationBar.isCustomizable = true
        super.delegate = transitionController
        
        // 重写属性 interactivePopGestureRecognizer 的并不能保证原生的返回手势不会被创建。
        if let interactivePopGestureRecognizer = self.interactivePopGestureRecognizer {
            interactivePopGestureRecognizer.isEnabled = false
            interactivePopGestureRecognizer.require(toFail: transitionController.interactiveNavigationGestureRecognizer)
        }
    }
    
    /// 请使用 transitionController.delegate 来设置当前导航控制器的代理。
    /// Use the transitionController's delegate property instead.
    open override var delegate: UINavigationControllerDelegate? {
        get {
            return super.delegate
        }
        set {
            transitionController.delegate = self
        }
    }
}


