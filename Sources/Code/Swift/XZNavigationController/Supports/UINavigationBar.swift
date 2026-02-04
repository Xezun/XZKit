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
    
    /// 导航条是否已开启自定义。
    public internal(set) var supportsXZNavigationBar: Bool {
        get {
            return (objc_getAssociatedObject(self, &_supportsCustomization) as? Bool) ?? false
        }
        set {
            let oldValue = self.supportsXZNavigationBar
            guard newValue != oldValue else {
                return
            }
            if newValue {
                let oldClass = type(of: self);
                if let newClass = objc_getAssociatedObject(oldClass, &_navigationBarClass) as? AnyClass {
                    object_setClass(self, newClass);
                } else {
                    let newClass = createNavigationBarClass(oldClass);
                    objc_setAssociatedObject(oldClass, &_navigationBarClass, newClass, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    object_setClass(self, newClass);
                }
                objc_setAssociatedObject(self, &_supportsCustomization, true, .OBJC_ASSOCIATION_COPY_NONATOMIC);
            } else {
                object_setClass(self, type(of: self).superclass()!)
            }
        }
    }
    
}



/// 同步导航状态
private class XZNavigationUINavigationBar: UINavigationBar {
    
    open override var frame: CGRect  {
        get {
            fatalError()
        }
        set {
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.frame), newValue)
            if let navigationBar = self.xzNavigationBar {
                navigationBar.frame = newValue;
                #XZLog("xzNavigationBar.frame = \(newValue)")
            }
        }
    }
    
    open override var bounds: CGRect {
        get {
            fatalError()
        }
        set {
            xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.bounds), newValue)
//            if let navigationBar = self.xzNavigationBar {
//                navigationBar.bounds = newValue;
//                #XZLog("xzNavigationBar.bounds = \(newValue)")
//            }
        }
    }
    
    open override var isHidden: Bool {
        get {
            return xz_objc_msgSendSuper_bool(self, type(of: self), #selector(getter: self.isHidden))
        }
        set {
            if let navigationBar = self.xzNavigationBar {
                navigationBar.isHidden = newValue
            } else {
                xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.isHidden), newValue)
            }
        }
    }
    
    open override var isTranslucent: Bool {
        get {
            return xz_objc_msgSendSuper_bool(self, type(of: self), #selector(getter: self.isTranslucent))
        }
        set {
            if let navigationBar = self.xzNavigationBar {
                navigationBar.isTranslucent = newValue
            } else {
                xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.isTranslucent), newValue)
            }
        }
    }
    
    @available(iOS 11.0, *)
    open override var prefersLargeTitles: Bool {
        get {
            return xz_objc_msgSendSuper_bool(self, type(of: self), #selector(getter: self.prefersLargeTitles))
        }
        set {
            if let navigationBar = self.xzNavigationBar {
                navigationBar.prefersLargeTitles = newValue
            } else {
                xz_objc_msgSendSuper_void(self, type(of: self), #selector(setter: self.prefersLargeTitles), newValue)
            }
        }
    }
    
    open override func layoutSubviews() {
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(layoutSubviews))

        if let navigationBar = self.xzNavigationBar {
            let bounds = self.bounds
            navigationBar.frame = bounds
        }
    }
    
    override func safeAreaInsetsDidChange() {
        xz_objc_msgSendSuper_void(self, type(of: self), #selector(safeAreaInsetsDidChange))
        guard let navigationBar = self.xzNavigationBar else {
            return
        }
        // 横屏时，状态栏不显示
        // 从横屏恢复竖屏，原生导航条初始位置，可能还没有适配 safeArea 边距，
        // 而后续原生导航条再调整位置，可能不会触发自定义导航条的 layoutSubviews 方法，
        // 因为自定义导航条相对原生导航条，没有任何改变。
        navigationBar.setNeedsLayout()
    }
}

/// 以
private func createNavigationBarClass(_ superClass: UINavigationBar.Type) -> UINavigationBar.Type {
    return xz_objc_createClass(superClass) { NewClass in
        let SourceClass = XZNavigationUINavigationBar.self;
        xz_objc_class_addMethod(
            NewClass, #selector(setter: UINavigationBar.frame),
            SourceClass, nil, #selector(setter: UINavigationBar.frame), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(setter: UINavigationBar.bounds),
            SourceClass, nil, #selector(setter: UINavigationBar.bounds), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(getter: UINavigationBar.isHidden),
            SourceClass, nil, #selector(getter: UINavigationBar.isHidden), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(setter: UINavigationBar.isHidden),
            SourceClass, nil, #selector(setter: UINavigationBar.isHidden), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(getter: UINavigationBar.isTranslucent),
            SourceClass, nil, #selector(getter: UINavigationBar.isTranslucent), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(setter: UINavigationBar.isTranslucent),
            SourceClass, nil, #selector(setter: UINavigationBar.isTranslucent), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(getter: UINavigationBar.prefersLargeTitles),
            SourceClass, nil, #selector(getter: UINavigationBar.prefersLargeTitles), nil
        );
        xz_objc_class_addMethod(
            NewClass, #selector(setter: UINavigationBar.prefersLargeTitles),
            SourceClass, nil, #selector(setter: UINavigationBar.prefersLargeTitles), nil
        );
    } as! UINavigationBar.Type
}

@MainActor private var _navigationBar = 0
@MainActor private var _navigationBarClass = 0;
@MainActor private var _supportsCustomization = 0;
