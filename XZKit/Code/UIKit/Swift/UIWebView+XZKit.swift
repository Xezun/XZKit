//
//  UIWebView.swift
//  XZKit
//
//  Created by mlibai on 2017/5/17.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit


extension UIWebView {
    
    /// 设置 UIWebView 的 User-Agent ，对于已创建的对象，该设置可能不会生效。
    /// - Note: 一般情况下，建议在 AppDelegate 中处理。
    @objc(xz_userAgent)
    public static var userAgent: String {
        get {
            if let userAgent = UserDefaults.standard.volatileDomain(forName: UserDefaults.registrationDomain)["UserAgent"] as? String {
                return userAgent
            }
            let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "window.navigator.userAgent") ?? ""
            UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
            return userAgent
        }
        set {
            UserDefaults.standard.register(defaults: ["UserAgent": newValue])
        }
    }
    
}
