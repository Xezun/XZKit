//
//  XZToast.swift
//  ChatGPT
//
//  Created by Xezun on 2023/12/11.
//

import UIKit
import XZGeometry
import XZTextIconView
#if SWIFT_PACKAGE
@_exported import XZToastObjC
#endif

/// 由于无法在 Swift 中为 XZToast 拓展 ExpressibleByStringLiteral 协议而使用了子类。
@objc(XZToastSwift) open class XZToast: __XZToast, ExpressibleByStringLiteral {
    
    public typealias Position   = __XZToastPosition
    public typealias Completion = __XZToastCompletion
    public typealias Style      = __XZToastStyle
    public typealias Task       = __XZToastTask
    
    public static var animationDuration: TimeInterval {
        return __XZToastAnimationDuration;
    }
    
    public override required init(view: any UIView & XZToastView) {
        super.init(view: view)
    }
    
    // MARK: - ExpressibleByStringLiteral
    
    public typealias StringLiteralType = String
    
    public required convenience init(stringLiteral value: String) {
        self.init(message: value)
    }
    
}

#if SWIFT_PACKAGE
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
extension XZToast.Style: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .message:
            return "message"
        case .loading:
            return "loading"
        case .success:
            return "success"
        case .failure:
            return "failure"
        case .warning:
            return "warning"
        case .waiting:
            return "waiting"
        @unknown default:
            return "unknown"
        }
    }
}
#else
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
extension XZToast.Style: CustomStringConvertible {
    public var description: String {
        switch self {
        case .message:
            return "message"
        case .loading:
            return "loading"
        case .success:
            return "success"
        case .failure:
            return "failure"
        case .warning:
            return "warning"
        case .waiting:
            return "waiting"
        @unknown default:
            return "unknown"
        }
    }
}
#endif

extension XZToast {
    
    public class func shared(_ style: XZToast.Style, text: String? = nil, image: UIImage? = nil) -> Self {
        return Self.init(shared: style, text: text, image: image)
    }
    
    /// 通过 view 构造 XZToast 对象。
    /// - Parameter view: 呈现提示的视图
    /// - Returns: XZToast 对象
    public class func view(_ view: UIView & XZToastView) -> Self {
        return Self.init(view: view)
    }
    
    /// 构造文本消息的 XZToast 对象。
    /// - Parameter text: 待呈现的文本内容
    /// - Returns: XZToast 对象
    public class func message(_ text: String) -> Self {
        return Self.init(message: text)
    }
    
    /// 构造带图片、文本消息的 XZToast 对象。
    /// - Parameter text: 待呈现的文本内容
    /// - Returns: XZToast 对象
    public class func message(_ text: String, image: UIImage?) -> Self {
        return Self.init(message: text, image: image)
    }
    
    /// 构造表示加载过程的 XZToast 对象。
    /// - Parameter text: 加载过程的描述文案
    /// - Returns: XZToast 对象
    public class func loading(_ text: String?) -> Self {
        return Self.init(loading: text)
    }
    
    public class func success(_ text: String?) -> Self {
        return Self.init(success: text)
    }
    
    public class func failure(_ text: String?) -> Self {
        return Self.init(failure: text)
    }
    
    public class func warning(_ text: String?) -> Self {
        return Self.init(warning: text)
    }
    
    public class func waiting(_ text: String?) -> Self {
        return Self.init(waiting: text)
    }
    
}

extension UIResponder {
    
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval = 1.0, position: XZToast.Position = .middle, exclusive: Bool = false, completion: XZToast.Completion? = nil) -> XZToast.Task? {
        return __showToast(toast, duration: duration, position: position, exclusive: exclusive, completion: completion)
    }
    
    public func hideToast(_ toast: __XZToast? = nil, completion: (()->Void)? = nil) {
        __hideToast(toast, completion: completion)
    }
    
}
