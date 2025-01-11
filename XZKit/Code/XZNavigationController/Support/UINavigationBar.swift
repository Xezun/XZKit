//
//  UIKit.UINavigationBar.swift
//  XZKit
//
//  Created by Xezun on 2017/7/11.
//
//

import UIKit
import XZDefines
import ObjectiveC

extension UIKit.UINavigationBar {
    
    /// 记录了当前正在显示的自定义的导航条。在控制器转场过程中，此属性为 nil 。
    public internal(set) var navigationBar: UINavigationBar? {
        get {
            return objc_getAssociatedObject(self, &_navigationBar) as? UINavigationBar
        }
        set {
            // 移除旧的
            if let oldValue = self.navigationBar {
                oldValue.navigationBar = nil
                oldValue.removeFromSuperview()
            }
            
            // 记录新值
            objc_setAssociatedObject(self, &_navigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // 添加新的
            if let newValue = newValue {
                newValue.frame = bounds
                newValue.navigationBar = self
                // 使用 autoresizing 布局，自定义导航条的 frame 会在父视图变化时改变，
                // 而自定义导航条父视图，在转场时会发生改变。
                super.addSubview(newValue)
            }
        }
    }
    
    /// 导航条是否已开启自定义。
    public internal(set) var isCustomizable: Bool {
        get {
            return objc_getAssociatedObject(self, &_isCustomizable) != nil
        }
        set {
            if newValue == isCustomizable {
                return
            }
            
            if newValue {
                objc_setAssociatedObject(self, &_isCustomizable, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                
                let OldClass = type(of: self)
                
                if let CustomizableClass = objc_getAssociatedObject(OldClass, &_customizableClass) as? UIKit.UINavigationBar.Type {
                    _ = object_setClass(self, CustomizableClass)
                } else if let CustomizableClass = xz_objc_createClass(OldClass, { (CustomizableClass) in
                    xz_objc_class_copyMethods(XZNavigationControllerNavigationBar.self, CustomizableClass);
                }) as? UIKit.UINavigationBar.Type {
                    objc_setAssociatedObject(OldClass, &_customizableClass, CustomizableClass, .OBJC_ASSOCIATION_ASSIGN)
                    _ = object_setClass(self, CustomizableClass)
                } else {
                    fatalError("无法自定义\(OldClass)")
                }
            } else {
                objc_setAssociatedObject(self, &_isCustomizable, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                object_setClass(self, self.superclass!)
            }
        }
    }
    
    
    
}

private class XZNavigationControllerNavigationBar: UIKit.UINavigationBar {
    
    open override var isHidden: Bool {
        get {
            return xz_objc_msgSendSuper(self, b: #selector(getter: self.isHidden))
        }
        set {
            if let navigationBar = navigationBar {
                navigationBar.isHidden = newValue
            } else {
                xz_objc_msgSendSuper(self, v: #selector(setter: self.isHidden), b: newValue)
            }
        }
    }
    
    open override var isTranslucent: Bool {
        get {
            return xz_objc_msgSendSuper(self, b: #selector(getter: self.isTranslucent))
        }
        set {
            if let navigationBar = navigationBar {
                navigationBar.isTranslucent = newValue
            } else {
                xz_objc_msgSendSuper(self, v: #selector(setter: self.isTranslucent), b: newValue)
            }
        }
    }
    
    @available(iOS 11.0, *)
    open override var prefersLargeTitles: Bool {
        get {
            return xz_objc_msgSendSuper(self, b: #selector(getter: self.prefersLargeTitles))
        }
        set {
            if let navigationBar = navigationBar {
                navigationBar.prefersLargeTitles = newValue
            } else {
                xz_objc_msgSendSuper(self, v: #selector(setter: self.prefersLargeTitles), b: newValue)
            }
        }
    }
    
    open override func layoutSubviews() {
        xz_objc_msgSendSuper(self, v: #selector(layoutSubviews))

        if let navigationBar = navigationBar {
            let bounds = self.bounds
            navigationBar.frame = bounds
        }
    }
    
    override func safeAreaInsetsDidChange() {
        xz_objc_msgSendSuper(self, v: #selector(safeAreaInsetsDidChange))
        guard let navigationBar = navigationBar else {
            return
        }
        // 横屏时，状态栏不显示
        // 从横屏恢复竖屏，原生导航条初始位置，可能还没有适配 safeArea 边距，
        // 而后续原生导航条再调整位置，可能不会触发自定义导航条的 layoutSubviews 方法，
        // 因为自定义导航条相对原生导航条，没有任何改变。
        navigationBar.setNeedsLayout()
    }

    // 当原生导航条添加子视图时，保证自定义导航条始终显示在最上面。

    open override func addSubview(_ view: UIView) {
        xz_objc_msgSendSuper(self, v: #selector(addSubview(_:)), o: view)

        if let navigationBar = navigationBar, navigationBar != view {
            xz_objc_msgSendSuper(self, v: #selector(bringSubviewToFront(_:)), o: navigationBar)
        }
    }

    open override func bringSubviewToFront(_ view: UIView) {
        xz_objc_msgSendSuper(self, v: #selector(bringSubviewToFront(_:)), o: view)
        

        if let navigationBar = navigationBar, navigationBar != view {
            xz_objc_msgSendSuper(self, v: #selector(bringSubviewToFront(_:)), o: navigationBar)
        }
    }

    open override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        xz_objc_msgSendSuper(self, v: #selector(insertSubview(_:aboveSubview:)), o: view, o: siblingSubview)
        
        if siblingSubview == navigationBar {
            xz_objc_msgSendSuper(self, v: #selector(bringSubviewToFront(_:)), o: siblingSubview)
        }
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        xz_objc_msgSendSuper(self, v: #selector(insertSubview(_:at:)), o: view, i: index)

        if let navigationBar = navigationBar {
            xz_objc_msgSendSuper(self, v: #selector(bringSubviewToFront(_:)), o: navigationBar)
        }
    }

    open override func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        xz_objc_msgSendSuper(self, v: #selector(insertSubview(_:belowSubview:)), o: view, o: siblingSubview)
        
        if navigationBar == view {
            xz_objc_msgSendSuper(self, v: #selector(bringSubviewToFront(_:)), o: view)
        }
    }
    
}

@MainActor private var _navigationBar = 0
@MainActor private var _customizableClass = 0;
@MainActor private var _isCustomizable = 0;
