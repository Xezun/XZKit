//
//  XZNavigationBarCustomizable.swift
//  XZKit
//
//  Created by Xezun on 2018/1/4.
//  Copyright © 2018年 Xezun Individual. All rights reserved.
//

import UIKit
import ObjectiveC

/// 此协议用于控制器，实现此协议的视图控制器，可以使用自定义导航条。
@MainActor public protocol XZNavigationBarCustomizable: UIViewController {
    /// 控制器自定义导航条。
    ///
    /// - Attention: 框架获取自定义导航条的获取时机会比 `viewDidLoad` 更早，因此，请避免在创建自定义导航条的过程中访问控制器的 `view` 属性，以免控制器生命周期提前。
    var navigationBarIfLoaded: XZNavigationBar? { get }
}

