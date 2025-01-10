//
//  XZNavigationBarCustomizable.swift
//  XZKit
//
//  Created by Xezun on 2018/1/4.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import UIKit
import ObjectiveC

/// 视图控制器遵循协议，表明该控制器使用自定义的导航条。
public protocol XZNavigationBarCustomizable: UIViewController {
    /// 控制器自定义导航条。
    ///
    /// - Attention: 框架获取自定义导航条的获取时机会比 `viewDidLoad` 更早，因此，请避免在创建自定义导航条的过程中访问控制器的 `view` 属性，以免控制器生命周期提前。
    var navigationBarIfLoaded: XZNavigationBarProtocol? { get }
}

/// 自定义导航条所必须实现的协议。
///
/// 自定义导航条可以继承 XZNavigationBar 也可以继承其它视图控件，实现 XZNavigationBarProtocol 协议即可。
///
/// **关于系统导航条**
///
/// 1. 如果 `isTranslucent == false` ，那么导航条背景色 alpha 会被设置为 1.0，但是大标题模式背景色却是白色的。
/// 2. 如果 `isTranslucent == true` ，设置透明色，则导航条可以透明。
///
/// **如何设置原生导航条透明**
///
/// ```swift
/// navigationBar.backgroundColor = UIColor.clear
/// navigationBar.isHidden        = false
/// navigationBar.barTintColor    = UIColor(white: 1.0, alpha: 0)
/// navigationBar.shadowImage     = UIImage()
/// navigationBar.isTranslucent   = true
/// navigationBar.setBackgroundImage(UIImage(), for: .default)
/// ```
///
/// 自定义导航条，可以通过 `navigationBar` 属性获取原生导航条。
///
/// 当原生导航条的状态发生改变时，会自动将状态同步给自定义导航条。
/// 因此，当自定义导航条属性发生改变时，需要向原生导航条同步状态时，应调用以下方法以避免**循环调用**。
///
/// ```swift
/// // self is the custom navigation bar
/// self.isHiddenDidChange()
/// self.prefersLargeTitlesDidChange()
/// self.isTranslucentDidChange()
/// ```
///
/// - Attention: 由于转场需要，自定义导航条并不总是在原生导航条之上，所以自定义导航条需要单独设置 tintColor 的值，以避免转场过程中，导航条颜色不一致的问题。
public protocol XZNavigationBarProtocol: UIView {
    /// 导航条是否半透明。
    var isTranslucent: Bool { get set }
    /// 导航条是否显示大标题模式。
    var prefersLargeTitles: Bool { get set }
}

extension XZNavigationBarProtocol {
    
    /// 原生导航条。
    ///
    /// 此属性为 nil 时，表示自定义导航条未展示，或者处于转场的过程中。
    public internal(set) var navigationBar: UINavigationBar? {
        get {
            return (objc_getAssociatedObject(self, &_navigationBar) as? XZNavigationBarWeakWrapper)?.value
        }
        set {
            if let wrapper = objc_getAssociatedObject(self, &_navigationBar) as? XZNavigationBarWeakWrapper {
                wrapper.value = newValue
            } else {
                let value = XZNavigationBarWeakWrapper.init(value: newValue)
                objc_setAssociatedObject(self, &_navigationBar, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /// 当前导航条 isHidden 属性发生改变时，通过此方法将状态同步给原生导航条。
    /// - Attention: 在 `isHidden` 属性的 willSet/set/didSet 方法中，直接设置原生导航条的属性，会导致循环调用。
    public func isHiddenDidChange() {
        guard let navigationBar = self.navigationBar else { return }
        xz_navc_msgSendSuper(navigationBar, setHidden: self.isHidden)
    }
    
    /// 当前导航条 prefersLargeTitles 属性发生改变时，通过此方法将状态同步给原生导航条。
    /// - Attention: 在 `prefersLargeTitles` 属性的 willSet/set/didSet 方法中，直接设置原生导航条的属性，会导致循环调用。
    public func prefersLargeTitlesDidChange() {
        guard let navigationBar = self.navigationBar else { return }
        xz_navc_msgSendSuper(navigationBar, setPrefersLargeTitles: self.prefersLargeTitles)
    }
    
    /// 当前导航条 isTranslucent 属性发生改变时，通过此方法将状态同步给原生导航条。
    /// - Attention: 在 `isTranslucent` 属性的 willSet/set/didSet 方法中，直接设置原生导航条的属性，会导致循环调用。
    public func isTranslucentDidChange() {
        guard let navigationBar = self.navigationBar else { return }
        xz_navc_msgSendSuper(navigationBar, setTranslucent: self.isTranslucent)
    }
}



private class XZNavigationBarWeakWrapper {
    weak var value: UINavigationBar?
    init(value: UINavigationBar? = nil) {
        self.value = value
    }
}

private var _navigationBar = 0

