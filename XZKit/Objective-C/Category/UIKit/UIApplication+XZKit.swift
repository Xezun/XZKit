//
//  UIApplication.swift
//  XZKit
//
//  Created by Xezun on 2017/4/24.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// 应用图标。
    public enum Icon: Int, CustomStringConvertible {
        
        /// 推送图标
        case notification   = 20
        
        /// 系统设置
        case settings       = 29
        
        /// Spotlight 列表
        case spotlight      = 40
        
        /// 应用图标
        case application    = 60
        
        /// 获取图标图片资源
        public var image: UIImage? {
            return UIImage(named: "AppIcon\(rawValue)x\(rawValue)")
        }
        
        // 图标文件名
        public var description: String {
            switch self {
            case .notification:
                return "AppIcon.notification"
            case .settings:
                return "AppIcon.settings"
            case .spotlight:
                return "AppIcon.spotlight"
            case .application:
                return "AppIcon.application"
            }
        }
        
        // 图标文件路径
        public var path: String {
            let scale = Int(UIScreen.main.scale)
            let path = Bundle.main.path(forResource: "AppIcon\(rawValue)x\(rawValue)@\(scale)x", ofType: "png")!
            return "file://" + path
        }
        
    }
    
}


extension UIApplication {
    
    /// 指定设备的启动图。
    ///
    /// - Parameters:
    ///   - device: 设备。
    ///   - orientation: 方向。
    /// - Returns: 启动图。
    public func launchImage(for screenSize: CGSize, orientation: UIDeviceOrientation) -> UIImage? {
        guard let launchImageInfos = Bundle.main.infoDictionary?["UILaunchImages"] as? [[String: String]] else { return nil }
        let orientationString = (orientation.isLandscape ? "Landscape" : "Portrait")
        for imageInfo in launchImageInfos {
            guard let imageSizeString   = imageInfo["UILaunchImageSize"] else { continue }
            guard let imageOrientation  = imageInfo["UILaunchImageOrientation"] else { continue }
            let imageSize = NSCoder.cgSize(for: imageSizeString)
            if imageSize == screenSize && imageOrientation == orientationString  {
                guard let imageName = imageInfo["UILaunchImageName"] else { continue }
                return UIImage(named: imageName)
            }
        }
        return nil
    }
    
    /// 当前设备启动图。
    ///
    /// - Parameter orientation: 方向。
    /// - Returns: 启动图
    public func launchImage(for orientation: UIDeviceOrientation) -> UIImage? {
        return launchImage(for: UIScreen.main.bounds.size, orientation: orientation)
    }
    
    /// App 启动图，屏幕当前方向的启动图。
    /// - 如果当前无法获取屏幕方向，默认使用竖屏方向。
    @objc(xz_launchImage) public var launchImage: UIImage? {
        return launchImage(for: UIScreen.main.bounds.size, orientation: UIDevice.current.orientation)
    }
    
    /// 状态栏样式是否由控制器管理的。
    /// - Note: 读取 Info.plist 文件中的 UIViewControllerBasedStatusBarAppearance 设置。
    @objc(xz_isViewControllerBasedStatusBarAppearance) public var isViewControllerBasedStatusBarAppearance: Bool {
        guard let value = Bundle.main.infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool else {
            return true;
        }
        return value;
    }
    
    
}


