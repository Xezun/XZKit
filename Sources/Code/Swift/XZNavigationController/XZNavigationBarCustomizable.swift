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
    ///
    /// 在业务中，我们可以通过下面的方式，全局添加统一的导航条。
    ///
    /// ```swift
    /// // 给控制器基类拓展一个属性，自动创建导航条。
    /// extension UIViewController {
    ///     var navigationBar: XZNavigationBar {
    ///         return <custom navigation bar>;
    ///     }
    /// }
    ///
    /// // 给 XZNavigationBarCustomizable 添加拓展。
    /// extension XZNavigationBarCustomizable {
    ///     var xzNavigationBar: XZNavigationBar? {
    ///         return self.navigationBar
    ///     }
    /// }
    /// ```
    /// 如此设置之后，每个控制器只需要声明遵循协议，就可以获得自定义的导航条了。
    var xzNavigationBar: XZNavigationBar? { get }
}

