//
//  NavigationGestureDrivable.swift
//  XZKit
//
//  Created by mlibai on 2018/1/4.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

/// 本协议用于控制器，用于自定义手势导航行为。
/// - Note: 控制器所在的导航控制器必须为 XZKit.UINavigationController 。
/// - Note: 在应用协议前，须设置当前控制器所在的导航控制器的 isNavigationGestureDrivable 属性为 true 。
public protocol NavigationGestureDrivable: ObjectProtocol where Self: UIViewController {
    
    /// 当一个 Push 手势触发时，此方法会被调用。控制应该在此方法中返回需要 Push 的下级控制器。
    /// - Note: 默认返回 nil ，表示没有下级页面。
    ///
    /// - Parameter navigationController: 当前控制器所在的导航控制器
    /// - Returns: 将要被 Push 出的控制器
    func viewControllerForPushGestureNavigation(_ navigationController: UINavigationController) -> UIViewController?
    
    /// 栈内控制器控制手势驱动导航行为触发的范围。
    /// - Note: 默认返回 nil，表示全屏可手势触发导航行为。
    ///
    /// - Parameters:
    ///   - navigationController: 导航控制器。
    ///   - operation: 导航行为。
    /// - Returns: 可以触发手势的边缘范围。
    func navigationController(_ navigationController: UINavigationController, edgeInsetsForGestureNavigation operation: UINavigationController.Operation) -> UIEdgeInsets?
    
}
