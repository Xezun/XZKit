//
//  UINavigationBar.swift
//  XZKit
//
//  Created by Xezun on 2017/7/11.
//
//

import UIKit
import ObjectiveC

extension UINavigationBar {
    
    /// 记录了当前正在显示的自定义的导航条。在控制器转场过程中，此属性为 nil 。
    public internal(set) var xzNavigationBar: XZNavigationBar? {
        get {
            return objc_getAssociatedObject(self, &_navigationBar) as? XZNavigationBar
        }
        set {
            objc_setAssociatedObject(self, &_navigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 冻结时，不允许修改 frame 和 center 以解决转场过程中的动画效果问题。
    internal var isFrozen: Bool {
        get {
            return (objc_getAssociatedObject(self, &_isFrozen) as? Bool) == true
        }
        set {
            objc_setAssociatedObject(self, &_isFrozen, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
}

@MainActor private var _isFrozen = 0
@MainActor private var _navigationBar = 0
