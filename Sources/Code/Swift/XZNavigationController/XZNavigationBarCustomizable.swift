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
    /// 控制器定制化的导航条。
    ///
    /// 控制器定制的导航条，会比控制器的 `viewDidLoad` 更早，因此，请避免在创建自定义导航条的过程中访问控制器的 `view` 属性，以免控制器生命周期提前。
    ///
    /// 在业务中，我们可以通过下面的方式，全局添加统一的导航条。
    ///
    /// ```swift
    /// // 给控制器基类拓展一个属性，自动创建导航条。
    /// extension UIViewController {
    ///     var navigationBar: XZNavigationBar {
    ///         return <lazy load a custom navigation bar>;
    ///     }
    /// }
    ///
    /// // 给 XZNavigationBarCustomizable 添加拓展。
    /// extension XZNavigationBarCustomizable {
    ///     var xzNavigationBar: XZNavigationBar? {
    ///         return self.navigationBar
    ///     }
    /// }
    ///
    /// // 然后在控制器中，只需要声明遵循协议，就可以通过 navigationBar 直接使用自定义导航条。
    /// class ViewController: UIViewController, XZNavigationBarCustomizable {
    ///     override func viewDidLoad() {
    ///         super.viewDidLoad()
    ///
    ///         self.navigationBar.isHidden = false
    ///     }
    /// }
    /// ```
    var xzNavigationBar: XZNavigationBar? { get }
}

