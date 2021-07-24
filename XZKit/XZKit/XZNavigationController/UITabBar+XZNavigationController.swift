//
//  UITabBar.swift
//  XZKit
//
//  Created by Xezun on 2017/7/11.
//
//

import UIKit


extension UITabBar {
    
    /// 当此属性为 true 时，可以通过是 *isFrameFrozen* 属性控制视图的 frame 是否可以被冻结（冻结后，设置 frame 将不生效），默认 false 。
    @objc(xz_isFrameFreezable) open var isFrameFreezable: Bool {
        return false
    }
    
    /// 是否已冻结，设置此属性为 true 后，更改属性 *frame* 不会生效。
    /// - Note: 设置此属性值，属性 *isFrameFreezable* 值将自动变更为 true 。
    @objc(xz_isFrameFrozen) open var isFrameFrozen: Bool {
        get {
            if let isFrameFrozen = objc_getAssociatedObject(self, &AssociationKey.isFrameFrozen) as? Bool {
                return isFrameFrozen
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &AssociationKey.isFrameFrozen, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            if isFrameFreezable {
                return
            }
            
            let CurrentClass = type(of: self)
            
            // 如果已经有自定义类，直接使用。
            if let CustomClass = objc_getAssociatedObject(CurrentClass, &AssociationKey.CustomClass) as? AnyClass {
                _ = object_setClass(self, CustomClass)
                return
            }
            
            let CustomClass = objc_class_create(CurrentClass, implementation: { (CustomClass) in
                objc_class_addMethods(CustomClass, from: XZFrameFreezableTabBar.self)
            }) as! UITabBar.Type
            
            _ = object_setClass(self, CustomClass)
            
            objc_setAssociatedObject(CurrentClass, &AssociationKey.CustomClass, CustomClass, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
}

@objc(XZFrameFreezableTabBar)
private class XZFrameFreezableTabBar: UITabBar {
    
    /// 返回 true 。
    override var isFrameFreezable: Bool {
        return true
    }
    
    /// 自定义类的 frame 属性，在修改值时，先判断当前是否允许修改。
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            if self.isFrameFrozen {
                return
            }
            super.frame = newValue
        }
    }
}

private struct AssociationKey {
    static var isFrameFrozen = "isFrameFrozen"
    static var CustomClass   = "CustomClass"
}
