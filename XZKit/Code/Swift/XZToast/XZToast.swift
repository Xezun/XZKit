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
    
    /// 全局共享的提示消息。
    /// - Parameters:
    ///   - style: 消息样式
    ///   - text: 消息文本
    ///   - image: 消息图片
    /// - Returns: 提示消息对象
    public class func shared(_ style: XZToast.Style, text: String?, image: UIImage? = nil) -> Self {
        return Self.init(shared: style, text: text, image: image)
    } 
    
    /// 通过 view 构造 XZToast 对象。
    /// - Parameter view: 呈现提示的视图
    /// - Returns: 提示消息对象
    public class func view(_ view: UIView & XZToastView) -> Self {
        return Self.init(view: view)
    }
    
    /// 构造文本消息的 XZToast 对象。
    /// - Parameter text: 待呈现的文本内容
    /// - Returns: 提示消息对象
    public class func message(_ text: String) -> Self {
        return Self.init(message: text)
    }
    
    /// 构造表示加载过程的 XZToast 对象。
    /// - Parameter text: 加载过程的描述文案
    /// - Returns: 提示消息对象
    public class func loading(_ text: String?) -> Self {
        return Self.init(loading: text)
    }
    
    /// 带成功图片的提示消息。
    /// - Parameter text: 消息文本
    /// - Returns: 提示消息对象
    public class func success(_ text: String?) -> Self {
        return Self.init(success: text)
    }
    
    /// 带失败图片的提示消息。
    /// - Parameter text: 消息文本
    /// - Returns: 提示消息对象
    public class func failure(_ text: String?) -> Self {
        return Self.init(failure: text)
    }
    
    /// 带警告图片的提示消息。
    /// - Parameter text: 消息文本
    /// - Returns: 提示消息对象
    public class func warning(_ text: String?) -> Self {
        return Self.init(warning: text)
    }
    
    /// 带等待图片的提示消息。
    /// - Parameter text: 消息文本
    /// - Returns: 提示消息对象
    public class func waiting(_ text: String?) -> Self {
        return Self.init(waiting: text)
    }
    
}

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
    public func hideToast(_ toast: __XZToast? = nil, completion: (()->Void)? = nil) {
        __hideToast(toast, completion: completion)
    }
    
}
