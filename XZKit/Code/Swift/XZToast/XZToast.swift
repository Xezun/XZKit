//
//  XZToast.swift
//  ChatGPT
//
//  Created by Xezun on 2023/12/11.
//

import UIKit
import XZGeometry
#if SWIFT_PACKAGE
@_exported import XZToastCore
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
    
    public override required init(view: UIView) {
        super.init(view: view)
    }
    
    // MARK: - ExpressibleByStringLiteral
    
    public typealias StringLiteralType = String
    
    public required convenience init(stringLiteral value: String) {
        self.init(style: .message, text: value, image: nil)
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

extension UIResponder {
    
    /// 展示提示消息。
    /// - Parameters:
    ///   - toast: 提示消息
    ///   - duration: 展示时长，0 表示永久，默认 1.0 秒
    ///   - position: 展示位置
    ///   - exclusive: 是否独占
    ///   - completion: 提示消息结束展示后执行的回调
    /// - Returns: 控制展示提示消息的对象
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval = 1.0, position: XZToast.Position = .middle, exclusive: Bool = false, completion: XZToast.Completion? = nil) -> XZToast.Task? {
        return __showToast(toast, duration: duration, position: position, exclusive: exclusive, completion: completion)
    }
    
    /// 隐藏指定或者所有提示消息。
    /// - Parameters:
    ///   - toast: 提示消息
    ///   - completion: 提示消息完成隐藏后执行的回调
    public func hideToast(_ toast: XZToast.Task? = nil, completion: (()->Void)? = nil) {
        __hideToast(toast, completion: completion)
    }
    
}
