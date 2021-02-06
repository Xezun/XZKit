//
//  XZKit+UIView.swift
//  XZKit
//
//  Created by 徐臻 on 2019/3/29.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

import Foundation

extension UIView {
    
    /// 当前视图的布局方向。
    /// - 默认返回 UIApplication.shared.userInterfaceLayoutDirection
    /// - iOS 9 以上返回视图调用 UIView.userInterfaceLayoutDirection(for:) 方法。
    /// - iOS 10 以上返回视图 effectiveUserInterfaceLayoutDirection 属性。
    @objc(xz_userInterfaceLayoutDirection)
    open var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        if #available(iOS 10.0, *) {
            return self.effectiveUserInterfaceLayoutDirection
        }
        if #available(iOS 9.0, *) {
            return type(of: self).userInterfaceLayoutDirection(for: self.semanticContentAttribute)
        }
        return UIApplication.shared.userInterfaceLayoutDirection
    }
    
    /// XZKit 通过在视图上添加 `BrightnessView` 来实现改变视图的亮度。
    /// - BrightnessView 为黑色背景，其 alpha = 1.0 - brightness 。
    /// - 取值范围 0 ~ 1.0 ，其它范围的值无效。
    @objc(xz_brightness)
    open var brightness: CGFloat {
        get {
            if let shadeView = self.brightnessViewIfLoaded {
                return 1.0 - shadeView.alpha
            }
            return 1.0
        }
        set {
            switch newValue {
            case 0 ..< 1.0:
                self.brightnessView.isHidden = false
                self.brightnessView.alpha    = 1.0 - newValue
                
            case 1.0:
                self.brightnessViewIfLoaded?.isHidden = true
                self.brightnessViewIfLoaded?.alpha    = 0
                
            default:
                break
            }
        }
    }
    
    /// 获取控制明亮度的视图，如果已创建的话。
    @objc(xz_brightnessViewIfLoaded)
    open var brightnessViewIfLoaded: UIImageView? {
        return (objc_getAssociatedObject(self, &AssociationKey.brightnessView) as? UIImageView)
    }
    
    /// 控制视图明亮度的视图。
    /// - Note: 一般情况下，需保持亮度视图在所有子视图顶部。
    @objc(xz_brightnessView)
    open var brightnessView: UIImageView {
        if let brightnessView = self.brightnessViewIfLoaded {
            return brightnessView
        }
        let brightnessView = BrightnessView(frame: bounds)
        addSubview(brightnessView)
        objc_setAssociatedObject(self, &AssociationKey.brightnessView, brightnessView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return brightnessView
    }
    
}

private struct AssociationKey {
    static var brightnessView: Int = 0
}

extension UIView {
    
    /// UIView 亮度遮罩，不限制使用者自定义亮度的颜色或者图片，默认为黑色图片。
    public class BrightnessView: UIImageView {
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            
            super.isUserInteractionEnabled = false
            super.backgroundColor          = UIColor.black
            super.isOpaque                 = true
            super.autoresizingMask         = [.flexibleHeight, .flexibleWidth]
        }
        
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            super.isUserInteractionEnabled = false
            super.backgroundColor          = UIColor.black
            super.isOpaque                 = true
            super.autoresizingMask         = [.flexibleHeight, .flexibleWidth]
        }
        
    }
}
