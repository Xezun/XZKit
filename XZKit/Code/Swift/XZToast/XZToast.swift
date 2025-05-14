//
//  XZToast.swift
//  ChatGPT
//
//  Created by Xezun on 2023/12/11.
//

import UIKit
import XZGeometry
import XZTextImageView

#if SWIFT_PACKAGE
@_exported import XZToastObjC

extension XZToast.Position: @retroactive CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .top:
            return "top"
        case .middle:
            return "middle"
        case .bottom:
            return "bottom"
        @unknown default:
            return "unknown"
        }
    }
    
}
#else
extension XZToast: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    /// 实现字符字面量构造 `XZToast` 的方法，实际调用 `init(message:)` 方法的便利方法。
    public required convenience init(stringLiteral value: String) {
        self.init(message: value)
    }
    
}

extension XZToast.Position: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .top:
            return "top"
        case .middle:
            return "middle"
        case .bottom:
            return "bottom"
        @unknown default:
            return "unknown"
        }
    }
    
}
#endif

extension XZToast {
    
    @objc public class func shared(for style: XZToast.Style, text: String? = nil, image: UIImage? = nil) -> Self {
        return Self.init(shared: style, text: text, image: image);
    }
    
    /// 通过 view 构造 XZToast 对象。
    /// - Parameter view: 呈现提示的视图
    /// - Returns: XZToast 对象
    @objc public class func view(_ view: UIView & XZToastViewProtocol) -> Self {
        return Self.init(view: view)
    }
    
    /// 构造文本消息的 XZToast 对象。
    /// - Parameter text: 待呈现的文本内容
    /// - Returns: XZToast 对象
    @objc public class func message(_ text: String) -> Self {
        return Self.init(message: text)
    }
    
    /// 构造带图片、文本消息的 XZToast 对象。
    /// - Parameter text: 待呈现的文本内容
    /// - Returns: XZToast 对象
    @objc public class func message(_ text: String, image: UIImage?) -> Self {
        return Self.init(message: text, image: image)
    }
    
    /// 构造表示加载过程的 XZToast 对象。
    /// - Parameter text: 加载过程的描述文案
    /// - Returns: XZToast 对象
    @objc public static func loading(_ text: String?) -> Self {
        return Self.init(loading: text)
    }
    
    @objc public static func success(_ text: String?) -> Self {
        return Self.init(success: text)
    }
    
    @objc public static func failure(_ text: String?) -> Self {
        return Self.init(failure: text)
    }
    
    @objc public static func warning(_ text: String?) -> Self {
        return Self.init(warning: text)
    }
    
    @objc public static func waiting(_ text: String?) -> Self {
        return Self.init(waiting: text)
    }
}





