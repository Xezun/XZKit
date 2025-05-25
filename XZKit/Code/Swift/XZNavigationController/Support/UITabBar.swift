//
//  UITabBar.swift
//  XZKit
//
//  Created by Xezun on 2017/7/11.
//
//

import UIKit
import XZDefines

// 在 right-to-left 布局的环境中，当导航控制器使用了自定义的转场动画后，
// tabBar 在转场的过程中的动画效果，与 left-to-right 环境一样，不符合要求。
// 但是在转场的过程中，将 tabBar 添加的转场动画，不能生效，因此利用运行时机制，
// 在动画的过程中，让其它地方不能再修改 tabBar 的 frame 以避免这个问题。

extension UITabBar {
    
    /// 当此属性为 true 时，可以通过 *isFrozen* 属性冻结 tabBar 防止其它地方修改 frame 值。
    var isFreezable: Bool {
        return objc_getAssociatedObject(self, &_isFreezable) != nil
    }
    
    /// 是否冻结。此属性为 true 时，更改属性 *frame* 不会生效。
    public var isFrozen: Bool {
        get {
            return (objc_getAssociatedObject(self, &_isFrozen) as? Bool) == true
        }
        set {
            objc_setAssociatedObject(self, &_isFrozen, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            if isFreezable {
                return
            }
            objc_setAssociatedObject(self, &_isFreezable, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            let OldClass = type(of: self)
            if let NewClass = objc_getAssociatedObject(OldClass, &_freezableTabBarClass) as? AnyClass {
                _ = object_setClass(self, NewClass)
            } else if let NewClass = xz_objc_createClass(OldClass, { (NewClass) in
                xz_objc_class_copyMethods(XZUITabBar.self, NewClass)
            }) as? UITabBar.Type {
                _ = object_setClass(self, NewClass)
                objc_setAssociatedObject(OldClass, &_freezableTabBarClass, NewClass, .OBJC_ASSOCIATION_ASSIGN)
            } else {
                print("无法自定义\(OldClass)，转场动画时 tabBar 的动画可能异常")
            }
        }
    }

}

// 在 objc_msgSendSuper 中使用 self.class 获取当前对象的 Class 那么子类在调用这个方法时就会产生死循环。
// 但是在这里，通过实际使用的是动态派生的类，没有子类，可以不用考虑这个问题。

private class XZUITabBar: UITabBar {

    /// 自定义类的 frame 属性，在修改值时，先判断当前是否允许修改。
    open override var frame: CGRect {
        get {
            return xz_objc_msgSendSuper(self, type(of: self), r: #selector(getter: self.frame))
        }
        set {
            if isFrozen {
                return
            }
            xz_objc_msgSendSuper(self, type(of: self), v: #selector(setter: self.frame), newValue)
        }
    }

    open override var bounds: CGRect {
        get {
            return xz_objc_msgSendSuper(self, type(of: self), r: #selector(getter: self.bounds))
        }
        set {
            if isFrozen {
                return
            }
            xz_objc_msgSendSuper(self, type(of: self), v: #selector(setter: self.bounds), newValue)
        }
    }

    open override var isHidden: Bool {
        get {
            return xz_objc_msgSendSuper(self, type(of: self), b: #selector(getter: self.isHidden))
        }
        set {
            if isFrozen {
                return
            }
            xz_objc_msgSendSuper(self, type(of: self), v: #selector(setter: self.isHidden), newValue)
        }
    }
}

@MainActor private var _isFrozen = 0
@MainActor private var _freezableTabBarClass = 0
@MainActor private var _isFreezable = 0
