//
//  WKWebView.swift
//  XZKit
//
//  Created by mlibai on 2017/5/17.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit
import WebKit

extension WKWebView {
    
    /// 在 UserDefaults 中记录原始 UserAgent 所用的键。
    public static let defaultUserAgentUserDefaultsKey = "com.mlibai.XZKit.userAgent.default"
    
    /// 在 UserDefaults 中记录已设置的 UserAgent 所用的键。
    public static let currentUserAgentUserDefaultsKey = "com.mlibai.XZKit.userAgent.current"
    
    /// 默认的 UserAgent 。
    /// - Note: WKWebView 在 iOS 9.0 以后，默认设置属性 customUserAgent 或 configuration.applicationNameForUserAgent 所覆盖。
    /// - Note: 此属性在第一次调用时，可能耗时较长，建议在启动是预调用一次。
    @objc(xz_defaultUserAgent) open class var defaultUserAgent: String {
        get {
            if let userAgent = objc_getAssociatedObject(self, &AssociationKey.userAgent) as? String {
                return userAgent
            }
            if let userAgent = UserDefaults.standard.volatileDomain(forName: UserDefaults.registrationDomain)["UserAgent"] as? String {
                objc_setAssociatedObject(self, &AssociationKey.userAgent, userAgent, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                return userAgent
            }
            if let userAgent = UserDefaults.standard.string(forKey: WKWebView.currentUserAgentUserDefaultsKey) {
                objc_setAssociatedObject(self, &AssociationKey.userAgent, userAgent, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
                return userAgent
            }
            if let userAgent = UserDefaults.standard.string(forKey: WKWebView.defaultUserAgentUserDefaultsKey) {
                objc_setAssociatedObject(self, &AssociationKey.userAgent, userAgent, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
                return userAgent
            }
            if let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "window.navigator.userAgent") {
                objc_setAssociatedObject(self, &AssociationKey.userAgent, userAgent, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
                UserDefaults.standard.set(userAgent, forKey: WKWebView.defaultUserAgentUserDefaultsKey)
                return userAgent
            }
            let systemVersion = UIDevice.current.systemVersion
            let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(systemVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
            objc_setAssociatedObject(self, &AssociationKey.userAgent, userAgent, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
            return userAgent;
        }
        set {
            objc_setAssociatedObject(self, &AssociationKey.userAgent, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            UserDefaults.standard.set(newValue, forKey: WKWebView.currentUserAgentUserDefaultsKey)
            UserDefaults.standard.register(defaults: ["UserAgent": newValue])
        }
    }
    
}

extension UIWebView {
    
    /// 与 WKWebView.defaultUserAgent 相同。
    @objc(xz_userAgent) open class var userAgent: String {
        get {
            return WKWebView.defaultUserAgent
        }
        set {
            WKWebView.defaultUserAgent = newValue
        }
    }
    
}


private struct AssociationKey {
    static var userAgent = 0
}
