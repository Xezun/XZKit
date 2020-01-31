//
//  NavigationBarCustomizable.swift
//  XZKit
//
//  Created by mlibai on 2018/1/4.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

/// 导航条是否可以自定义。
/// - Note: 因为 `NavigationBarCustomizable: AnyObject where Self: UIViewController` 会爆警告，所以曲线处理一下了。
public protocol NavigationBarCustomizable: UIViewController {
    /// 控制器自定义导航条。
    var navigationBarIfLoaded: (UIView & NavigationBaring)? { get }
}

