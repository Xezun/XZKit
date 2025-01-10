//
//  XZNavigationGestureDrivable.swift
//  XZKit
//
//  Created by Xezun on 2018/1/4.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import UIKit

/// 本协议用于控制器，用于自定义手势导航行为。
/// - Note: 控制器所在的导航控制器遵循 XZNavigationController 协议。
/// - Note: 未遵循本协议，默认支持侧滑返回。
public protocol XZNavigationGestureDrivable: UIViewController {
    
    /// 通过此方法，可限制手势导航触发的范围。
    /// 1. 返回 nil，表示全屏可手势触发导航行为，默认。
    /// 2. 其它值表示可触发手势导航的边缘范围。
    /// - Parameters:
    ///   - navigationController: 导航控制器。
    ///   - operation: 导航行为。
    /// - Returns: 可以触发手势的边缘范围。
    func navigationController(_ navigationController: UINavigationController, edgeInsetsForGestureNavigation operation: UINavigationController.Operation) -> NSDirectionalEdgeInsets?
    
    /// 当手势导航行为触发时，此方法将被调用。
    /// 1. Push 时，返回目标控制器，即触发 push 进入目标页面，返回 nil 不触发。
    /// 2. Pop 时，返回 nil 表示返回上一个页面，返回其它值，表示返回到指定的栈内页面。
    ///
    /// - Parameter navigationController: 当前控制器所在的导航控制器。
    /// - Parameter operation: 导航类型。
    /// - Returns: 目标控制器。
    func navigationController(_ navigationController: UINavigationController, viewControllerForGestureNavigation operation: UINavigationController.Operation) -> UIViewController?
    
}

extension XZNavigationGestureDrivable {
    
    /// 默认实现返回 nil 表示支持全屏手势。
    public func navigationController(_ navigationController: UINavigationController, edgeInsetsForGestureNavigation operation: UINavigationController.Operation) -> NSDirectionalEdgeInsets? {
        return nil
    }
    
    /// 默认返回 nil 表示不会触发 push 但是可以 pop 到上一页。
    public func navigationController(_ navigationController: UINavigationController, viewControllerForGestureNavigation operation: UINavigationController.Operation) -> UIViewController? {
        return nil
    }
    
}
