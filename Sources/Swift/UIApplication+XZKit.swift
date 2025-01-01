//
//  UIApplication.swift
//  XZKit
//
//  Created by Xezun on 2017/4/24.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit

/// 应用图标。
public enum AppIcon: CGFloat {
    
    /// 推送图标
    case notification   = 20.0
    
    /// 系统设置
    case settings       = 29.0
    
    /// Spotlight 列表
    case spotlight      = 40.0
    
    /// 应用图标
    case application    = 60.0 // iPad = 76.0 iPad Pro = 83.5
    
    /// 获取图标图片资源
    public var image: UIImage? {
        let name = String(format: "AppIcon%gx%g", rawValue, rawValue);
        return UIImage(named: name)
    }
    
    // 图标文件路径
    public var path: String {
        let scale = Int(UIScreen.main.scale)
        let path = Bundle.main.path(forResource: "AppIcon\(rawValue)x\(rawValue)@\(scale)x", ofType: "png")!
        return "file://" + path
    }
    
}

extension UIApplication {
    
    /// 状态栏样式是否基于控制器。
    /// - Note: 读取 Info.plist 文件中的 UIViewControllerBasedStatusBarAppearance 设置。
    @objc(xz_isViewControllerBasedStatusBarAppearance)
    public var isViewControllerBasedStatusBarAppearance: Bool {
        if let value = Bundle.main.infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool {
            return value
        }
        return true;
    }
    
}


