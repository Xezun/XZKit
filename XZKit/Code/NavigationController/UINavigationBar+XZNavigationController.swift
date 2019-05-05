//
//  UINavigationBar.swift
//  XZKit
//
//  Created by mlibai on 2017/7/11.
//
//

import UIKit

extension UINavigationBar {
    
    /// 记录了当前正在显示的自定义的导航条。在控制器转场过程中，此属性为 nil 。
    public internal(set) var customizedBar: (UIView & NavigationBaring)? {
        get {
            return objc_getAssociatedObject(self, &AssociationKey.customizedBar) as? (UIView & NavigationBaring)
        }
        set {
            if let oldNavigationBar = self.customizedBar {
                oldNavigationBar.removeFromSuperview() // 移除旧的
            }
            objc_setAssociatedObject(self, &AssociationKey.customizedBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            for subview in subviews {
                subview.isHidden = true // 隐藏原生视图
            }
            if let newNavigationBar = newValue {
                newNavigationBar.frame = bounds
                addSubview(newNavigationBar) // 添加新的
            }
        }
    }
    
    /// 导航条是否可以自定义。
    @objc(xz_isCustomizable) public internal(set) var isCustomizable: Bool {
        get {
            return false
        }
        set {
            guard newValue != isCustomizable else {
                return
            }
            
            if isCustomizable { // 如果当前为自定义类
                object_setClass(self, self.superclass!)
                return
            }
            
            assert(Thread.isMainThread, "Only main thread is allowed to call this method.")
            
            let OldClass  = type(of: self)
            
            // 系统导航条始终不隐藏、全透明。
            // 系统导航条，如果 isTranslucent == false ，那么导航条背景色 alpha 会被设置为 1.0，但是大标题模式背景色却是白色的。
            // 如果 isTranslucent == true ，设置透明色，则导航条可以透明。
            self.backgroundColor = UIColor.clear
            self.isHidden        = false
            self.barTintColor    = UIColor(white: 1.0, alpha: 0)
            self.shadowImage     = UIImage()
            self.isTranslucent   = true
            self.setBackgroundImage(UIImage(), for: .default)
            
            if let NewClass = objc_getAssociatedObject(OldClass, &AssociationKey.NewClass) as? AnyClass {
                object_setClass(self, NewClass)
                return
            }
            
            // 开始创建自定义类，以当前导航条类为父类，创建新的导航条类。
            let NewClassName = objc_class_name_create(OldClass)
            let NewClass     = objc_allocateClassPair(OldClass, NewClassName, 0) as! UINavigationBar.Type
            
            do { // 重写自定义类的 isCustomizable 属性的 getter 方法，使其返回 true 。
                let getterSEL = #selector(getter: OldClass.isCustomizable)
                let getterBLK: @convention(block) (_: NSObject) -> Bool = { (obj: NSObject) -> Bool in
                    return true
                }
                let getterIMP = imp_implementationWithBlock(getterBLK)
                let getterENC = method_getTypeEncoding(class_getInstanceMethod(OldClass, getterSEL)!)
                class_addMethod(NewClass, getterSEL, getterIMP, getterENC)
            }
            
            do { // 重写自定义类的 isHidden 属性，使其 isHidden 属性不再控制导航条的显示或隐藏。
                do {
                    let setterSEL = #selector(setter: OldClass.isHidden)
                    let setterBLK: @convention(block) (UINavigationBar, Bool) -> Void = { (obj, newValue) in
                        objc_setAssociatedObject(obj, &AssociationKey.isHidden, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                        obj.customizedBar?.isHidden = newValue
                    }
                    let setterIMP = imp_implementationWithBlock(setterBLK)
                    let setterENC = method_getTypeEncoding(class_getInstanceMethod(OldClass, setterSEL)!)
                    class_addMethod(NewClass, setterSEL, setterIMP, setterENC)
                }
                
                do {
                    let getterSEL = #selector(getter: OldClass.isHidden)
                    let getterBLK: @convention(block) (_: NSObject) -> Bool = {(obj: NSObject) -> Bool in
                        if let isHidden = objc_getAssociatedObject(obj, &AssociationKey.isHidden) as? Bool {
                            return isHidden
                        }
                        return false // 与导航条当前状态相同。
                    }
                    let getterIMP = imp_implementationWithBlock(getterBLK)
                    let getterENC = method_getTypeEncoding(class_getInstanceMethod(OldClass, getterSEL)!)
                    class_addMethod(NewClass, getterSEL, getterIMP, getterENC)
                }
            }
            
            do { // 重写自定义类的 isTranslucent 属性，使其 isTranslucent 属性不再控制导航条的透明。
                let setterSEL = #selector(setter: OldClass.isTranslucent)
                let setterBLK: @convention(block) (UINavigationBar, Bool) -> Void = { (obj, newValue) in
                    objc_setAssociatedObject(obj, &AssociationKey.isTranslucent, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                    obj.customizedBar?.isTranslucent = newValue
                }
                let setterIMP = imp_implementationWithBlock(setterBLK)
                let setterENC = method_getTypeEncoding(class_getInstanceMethod(OldClass, setterSEL)!)
                class_addMethod(NewClass, setterSEL, setterIMP, setterENC)
                
                let getterSEL = #selector(getter: OldClass.isTranslucent)
                let getterBLK: @convention(block) (_: NSObject) -> Bool = {(obj: NSObject) -> Bool in
                    if let isTranslucent = objc_getAssociatedObject(obj, &AssociationKey.isTranslucent) as? Bool {
                        return isTranslucent
                    }
                    return true // 与导航条当前状态相同。
                }
                let getterIMP = imp_implementationWithBlock(getterBLK)
                let getterENC = method_getTypeEncoding(class_getInstanceMethod(OldClass, getterSEL)!)
                class_addMethod(NewClass, getterSEL, getterIMP, getterENC)
            }
            
            if #available(iOS 11.0, *) { // 重写 prefersLargeTitles setter
                class __Bar: UINavigationBar {
                    override var prefersLargeTitles: Bool {
                        get { return super.prefersLargeTitles }
                        set { super.prefersLargeTitles = newValue; customizedBar?.prefersLargeTitles = newValue }
                    }
                }
                let sel = #selector(setter: OldClass.prefersLargeTitles)
                let imp = class_getMethodImplementation(__Bar.self, sel)!
                let enc = method_getTypeEncoding(class_getInstanceMethod(OldClass, sel)!)
                class_addMethod(NewClass, sel, imp, enc)
            }
            
            //do { // 不可交互。原有导航条上的按钮有可能也会接收到事件，原因可能是，虽然系统导航栏实际是隐藏的，但是对外属性却表明它不是隐藏的，所以事件会发送给它。
            //    let getterSEL = #selector(getter: OldClass.isUserInteractionEnabled)
            //    let getterBLK: @convention(block) (_: NSObject) -> Bool = {(obj: NSObject) -> Bool in
            //        return false
            //    }
            //    let getterIMP = imp_implementationWithBlock(getterBLK)
            //    let getterENC = method_getTypeEncoding(class_getInstanceMethod(OldClass, getterSEL)!)
            //    class_addMethod(NewClass, getterSEL, getterIMP, getterENC)
            //}
            
            do { // 同步 tintColor ，避免动画过程中，因为自定义导航条不在原生导航条上，由 tintColor 引起的外观不一致问题。
                let getterSEL = #selector(OldClass.tintColorDidChange)
                let getterBLK: @convention(block) (_: UINavigationBar) -> Void = {(obj: UINavigationBar) -> Void in
                    super.tintColorDidChange()
                    obj.customizedBar?.tintColor = obj.tintColor
                }
                let getterIMP = imp_implementationWithBlock(getterBLK)
                let getterENC = method_getTypeEncoding(class_getInstanceMethod(OldClass, getterSEL)!)
                class_addMethod(NewClass, getterSEL, getterIMP, getterENC)
            }
            
            do { // 不可设置导航条背景。
                let sel = #selector(OldClass.setBackgroundImage(_:for:barMetrics:))
                let blc: @convention(block) (UINavigationBar, UIImage, UIBarPosition, UIBarMetrics) -> Void = { (_, _, _, _) in
                    print("因为导航条已自定义，设置原生导航条样式将不再起作用。")
                }
                let imp = imp_implementationWithBlock(blc)
                let enc = method_getTypeEncoding(class_getInstanceMethod(OldClass, sel)!)
                class_addMethod(NewClass, sel, imp, enc)
            }
            
            do {
                let sel = #selector(OldClass.layoutSubviews)
                let blc: @convention(block) (UINavigationBar) -> Void = { (navigationBar) in
                    super.layoutSubviews()
                    guard let customNavigationBar = navigationBar.customizedBar else { return }
                    customNavigationBar.frame = navigationBar.bounds
                    customNavigationBar.setNeedsLayout()
                }
                
                let imp = imp_implementationWithBlock(blc)
                let enc = method_getTypeEncoding(class_getInstanceMethod(OldClass, sel)!)
                class_addMethod(NewClass, sel, imp, enc)
            }
            
            objc_registerClassPair(NewClass)
            _ = object_setClass(self, NewClass)
            
            // 记录已自自定义的类，以便在下次时使用。
            objc_setAssociatedObject(OldClass, &AssociationKey.NewClass, NewClass, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
}

private struct AssociationKey {
    static var isCustomizable = "isCustomizable"
    static var isTranslucent  = "isTranslucent"
    static var isHidden       = "isHidden"
    static var NewClass       = "NewClass"
    static var customizedBar  = "customizedBar"
}

