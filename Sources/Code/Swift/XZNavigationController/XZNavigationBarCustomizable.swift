//
//  XZNavigationBarCustomizable.swift
//  XZKit
//
//  Created by Xezun on 2018/1/4.
//  Copyright © 2018年 Xezun Individual. All rights reserved.
//

import UIKit
import ObjectiveC

/// 此协议用于控制器，实现此协议的视图控制器，可以使用定制化导航栏。
@MainActor public protocol XZNavigationBarCustomizable: UIViewController {
    
    /// 控制器定制化的导航栏。
    ///
    /// 控制器定制的导航栏，会比控制器的 `viewDidLoad` 更早，因此，请避免在创建定制化导航栏的过程中访问控制器的 `view` 属性，以免控制器生命周期提前。
    ///
    /// 在业务中，我们可以通过下面的方式，全局添加统一的导航栏。
    ///
    /// ```swift
    /// // 给控制器基类拓展一个属性，自动创建导航栏。
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
    /// // 然后在控制器中，只需要声明遵循协议，就可以通过 navigationBar 直接使用定制化导航栏。
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

extension XZNavigationBar {
    
    /// 原生导航栏。
    ///
    /// 此属性为 nil 时，表示定制化导航栏未展示，或者处于转场的过程中。
    public fileprivate(set) var uiNavigationBar: UINavigationBar? {
        get {
            return (objc_getAssociatedObject(self, &_uiNavigationBar) as? WeakWrapper)?.value as? UINavigationBar
        }
        set {
            if let wrapper = objc_getAssociatedObject(self, &_uiNavigationBar) as? WeakWrapper {
                wrapper.value = newValue
            } else {
                let value = WeakWrapper.init(value: newValue)
                objc_setAssociatedObject(self, &_uiNavigationBar, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}

extension UINavigationController {
    
    /// 当前的定制化导航栏。
    public internal(set) var xzNavigationBar: XZNavigationBar? {
        get {
            return objc_getAssociatedObject(self.view!, &_xzNavigationBar) as? XZNavigationBar
        }
        set {
            // 移除旧的
            if let oldValue = self.xzNavigationBar {
                oldValue.uiNavigationBar = nil;
                oldValue.removeFromSuperview()
            }

            // 记录新值
            objc_setAssociatedObject(self.view!, &_xzNavigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // 添加新的
            if let newValue = newValue {
                newValue.frame = self.navigationBar.frame;
                newValue.uiNavigationBar = self.navigationBar;
                // 使用 autoresizing 布局，定制化导航栏的 frame 会在父视图变化时改变，
                // 而定制化导航栏父视图，在转场时会发生改变。
                self.view.addSubview(newValue)
            }
            
            // 将值同步到原生导航栏
            self.navigationBar.xzNavigationBar = newValue;
        }
    }
    
}

extension UINavigationBar {
    
    /// 记录了当前正在显示的自定义的导航栏。在控制器转场过程中，此属性为 nil 。
    public fileprivate(set) var xzNavigationBar: XZNavigationBar? {
        get {
            return (objc_getAssociatedObject(self, &_xzNavigationBar) as? WeakWrapper)?.value as? XZNavigationBar
        }
        set {
            if let weakWrapper = objc_getAssociatedObject(self, &_xzNavigationBar) as? WeakWrapper {
                weakWrapper.value = newValue;
            } else {
                objc_setAssociatedObject(self, &_xzNavigationBar, WeakWrapper(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}

/// 避免循环引用。
@MainActor private class WeakWrapper {
    
    weak var value: AnyObject?
    
    init(value: AnyObject? = nil) {
        self.value = value
    }
    
}

/// 给原生的导航控制器，添加定制化导航栏属性。
@MainActor private var _xzNavigationBar = 0
@MainActor private var _uiNavigationBar = 0



