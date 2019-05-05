//
//  UITabBar.swift
//  XZKit
//
//  Created by mlibai on 2017/7/11.
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
            if let isFrameLocked = objc_getAssociatedObject(self, &AssociationKey.isFrameLocked) as? Bool {
                return isFrameLocked
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &AssociationKey.isFrameLocked, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            if isFrameFreezable {
                return
            }
            
            // 通过动态派生出 UITabBar.AnimationControllable 类，替换当前的 tabBar 的父类。
            // 新的父类在更改 frame 属性时，会判断 isAnimatable 属性，从而决定是否发送消息。
            assert(Thread.isMainThread, "The property UITabBar.isFrameMutable must be set in main thread.")
            
            let CurrentClass = type(of: self)
            
            // 如果已经有自定义类，直接使用。
            if let CustomClass = objc_getAssociatedObject(CurrentClass, &AssociationKey.CustomClass) as? AnyClass {
                _ = object_setClass(self, CustomClass)
                return
            }
            
            let CustomClassName = objc_class_name_create(CurrentClass)
            let CustomClass     = objc_allocateClassPair(CurrentClass, CustomClassName, 0) as! UITabBar.Type
            
            /// 自定义类的 frame 属性，在修改值时，先判断当前是否允许修改。
            do {
                let setterSEL = #selector(setter: CurrentClass.frame)
                let newSetterBLK: @convention(block) (UITabBar, CGRect) -> Void = { (tabBar, newValue) in
                    if tabBar.isFrameFrozen {
                        return
                    }
                    super.frame = newValue
                }
                
                let newSetterIMP = imp_implementationWithBlock(newSetterBLK)
                let newSetterENC = method_getTypeEncoding(class_getInstanceMethod(CurrentClass, setterSEL)!)
                class_addMethod(CustomClass, setterSEL, newSetterIMP, newSetterENC)
            }
            
            /// 自定义类的 isFrameMutationControllable 属性返回 true 。
            do {
                let getterSEL = #selector(getter: UITabBar.isFrameFreezable)
                
                let newGetterBLK: @convention(block) (UITabBar) -> Bool = { (_) -> Bool in
                    return true
                }
                
                let newGetterIMP = imp_implementationWithBlock(newGetterBLK)
                let newGetterENC = method_getTypeEncoding(class_getInstanceMethod(CurrentClass, getterSEL)!)
                class_addMethod(CustomClass, getterSEL, newGetterIMP, newGetterENC)
            }
            
            objc_registerClassPair(CustomClass)
            
            _ = object_setClass(self, CustomClass)
            
            objc_setAssociatedObject(CurrentClass, &AssociationKey.CustomClass, CustomClass, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
}


private struct AssociationKey {
    static var isFrameLocked = "isFrameLocked"
    static var CustomClass   = "CustomClass"
}
