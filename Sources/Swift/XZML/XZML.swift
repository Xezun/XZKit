//
//  XZML.swift
//  XZKit
//
//  Created by Xezun on 2025/7/29.
//

import Foundation

extension NSAttributedString.Key {
    
    /// XZML 支持的富文本属性。
    public static let XZML = (
        /// 字体。
        font: __XZMLFontAttributeName,
        /// 前景色。
        foregroundColor: __XZMLForegroundColorAttributeName,
        /// 文本修饰。
        decoration: __XZMLDecorationAttributeName,
        /// 安全模式。
        securityMode: __XZMLSecurityModeAttributeName,
        /// 超链接。
        link: __XZMLLinkAttributeName,
        /// 段落行高。
        lineHeight: __XZMLLineHeightAttributeName
    );
    
}


