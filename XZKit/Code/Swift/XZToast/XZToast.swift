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
//@_exported
import XZToastObjC

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



extension UIResponder {
    
    public func showToast(_ toast: XZToast, duration: TimeInterval = 1.0, position: XZToast.Position = .middle, exclusive: Bool = false, completion: XZToast.Completion? = nil) -> XZToast? {
        guard let task = __showToast(toast.rawValue, duration: duration, position: position, exclusive: exclusive, completion: completion) else {
            return nil
        }
        return XZToast.init(task)
    }
    
    public func hideToast(_ toast: XZToast? = nil, completion: (()->Void)? = nil) {
        __hideToast(toast?.rawValue, completion: completion)
    }
    
}

public struct XZToast {
    
    public typealias Position   = __XZToastPosition
    public typealias Completion = __XZToastCompletion
    public typealias Style      = __XZToastStyle
    
    public static var animationDuration: TimeInterval {
        return __XZToastAnimationDuration;
    }
    
    fileprivate let rawValue: __XZToast
    
    fileprivate init(_ objc: __XZToast) {
        self.rawValue = objc
    }
    
    public init(view: UIView & XZToastView) {
        rawValue = __XZToast.init(view: view)
    }
    
    public var view: UIView & XZToastView {
        return rawValue.view
    }
    
    public var text: String? {
        get {
            return rawValue.text
        }
        set {
            rawValue.text = newValue
        }
    }
    
}

extension XZToast: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        rawValue = __XZToast.init(message: value)
    }
}

extension XZToast {
    
    public static func shared(_ style: Style, text: String? = nil, image: UIImage? = nil) -> Self {
        return Self.init(__XZToast.init(shared: style, text: text, image: image));
    }
    
    /// 通过 view 构造 XZToast 对象。
    /// - Parameter view: 呈现提示的视图
    /// - Returns: XZToast 对象
    public static func view(_ view: UIView & XZToastView) -> Self {
        return Self.init(__XZToast.init(view: view))
    }
    
    /// 构造文本消息的 XZToast 对象。
    /// - Parameter text: 待呈现的文本内容
    /// - Returns: XZToast 对象
    public static func message(_ text: String) -> Self {
        return Self.init(__XZToast.init(message: text))
    }
    
    /// 构造带图片、文本消息的 XZToast 对象。
    /// - Parameter text: 待呈现的文本内容
    /// - Returns: XZToast 对象
    public static func message(_ text: String, image: UIImage?) -> Self {
        return Self.init(__XZToast.init(message: text, image: image))
    }
    
    /// 构造表示加载过程的 XZToast 对象。
    /// - Parameter text: 加载过程的描述文案
    /// - Returns: XZToast 对象
    public static func loading(_ text: String?) -> Self {
        return Self.init(__XZToast.init(loading: text))
    }
    
    public static func success(_ text: String?) -> Self {
        return Self.init(__XZToast.init(success: text))
    }
    
    public static func failure(_ text: String?) -> Self {
        return Self.init(__XZToast.init(failure: text))
    }
    
    public static func warning(_ text: String?) -> Self {
        return Self.init(__XZToast.init(warning: text))
    }
    
    public static func waiting(_ text: String?) -> Self {
        return Self.init(__XZToast.init(waiting: text))
    }
}

extension XZToast: ReferenceConvertible {
    
    public typealias ReferenceType = __XZToast
    
    public typealias _ObjectiveCType = __XZToast
    
    public func hash(into hasher: inout Hasher) {
        rawValue.hash(into: &hasher)
    }
    
    public static func ==(lhs: XZToast, rhs: XZToast) -> Bool {
        return false
    }
    
    public func _bridgeToObjectiveC() -> __XZToast {
        return rawValue
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __XZToast, result: inout XZToast?) {
        result = .init(source)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __XZToast, result: inout XZToast?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __XZToast?) -> XZToast {
        if let source = source {
            return .message(source.text ?? "未知错误")
        }
#if DEBUG
        return .message("<XZToast> 参数错误")
#else
        if #available(iOS 15, *) {
            return .message(String(localized: "未知信息"))
        }
        return .message(NSLocalizedString("未知信息", comment: "未知信息"));
#endif
    }
    
    public var debugDescription: String {
        return rawValue.debugDescription
    }
    
    public var description: String {
        return rawValue.description
    }

}





