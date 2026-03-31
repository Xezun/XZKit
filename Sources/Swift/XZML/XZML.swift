//
//  XZML.swift
//  XZKit
//
//  Created by 徐臻 on 2025/7/29.
//

import Foundation

#if SWIFT_PACKAGE
@_exported import XZKitObjC
#endif

extension NSAttributedString.Key {
    
    /// 拓展 XZML 支持的富文本属性。
    public static let XZML = (
        /// ``XZMLFontAttributeName``
        font: __XZMLFontAttributeName,
        /// ``XZMLForegroundColorAttributeName``
        foregroundColor: __XZMLForegroundColorAttributeName,
        /// ``XZMLDecorationAttributeName``
        decoration: __XZMLDecorationAttributeName,
        /// ``XZMLSecurityModeAttributeName``
        securityMode: __XZMLSecurityModeAttributeName,
        /// ``XZMLLinkAttributeName``
        link: __XZMLLinkAttributeName,
        /// ``XZMLLineHeightAttributeName``
        lineHeight: __XZMLLineHeightAttributeName
    );
    
}


