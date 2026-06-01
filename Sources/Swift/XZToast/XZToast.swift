//
//  XZToast.swift
//  XZKit
//
//  Created by Xezun on 2023/12/11.
//

import UIKit

/// 由于无法在 Swift 中为 XZToast 拓展 ExpressibleByStringLiteral 协议而使用了子类。
///
/// 不能将名字指定为 `__XZToast` 会触发 circular reference 编译错误。
@objc(_Swift_XZToast) open class XZToast: __XZToast, ExpressibleByStringLiteral {
    
    public typealias Position   = __XZToastPosition
    public typealias Completion = __XZToastCompletion
    public typealias Style      = __XZToastStyle
    public typealias Task       = __XZToastTask
    
    /// 转场动画时长。
    public static var animationDuration: TimeInterval {
        return __XZToastAnimationDuration;
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
        return __NSStringFromXZToastPosition(self)
    }
    
}
extension XZToast.Style: @retroactive CustomStringConvertible {
    public var description: String {
        return __NSStringFromXZToastStyle(self)
    }
}
#else
extension XZToast.Position: CustomStringConvertible {
    
    public var description: String {
        return __NSStringFromXZToastPosition(self)
    }
    
}
extension XZToast.Style: CustomStringConvertible {
    public var description: String {
        return __NSStringFromXZToastStyle(self)
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
    public func showToast(_ toast: XZToast, duration: TimeInterval, position: XZToast.Position, exclusive: Bool, completion: XZToast.Completion?) -> XZToast.Task {
        return __showToast(toast, duration: duration, position: position, exclusive: exclusive, completion: completion)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval, position: XZToast.Position, exclusive: Bool) -> XZToast.Task {
        return __showToast(toast, duration: duration, position: position, exclusive: exclusive)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval, position: XZToast.Position, completion: XZToast.Completion?) -> XZToast.Task {
        return __showToast(toast, duration: duration, position: position, completion: completion)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval, exclusive: Bool, completion: XZToast.Completion?) -> XZToast.Task {
        return __showToast(toast, duration: duration, exclusive: exclusive, completion: completion)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, position: XZToast.Position, exclusive: Bool, completion: XZToast.Completion?) -> XZToast.Task {
        return __showToast(toast, position: position, exclusive: exclusive, completion: completion)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval, position: XZToast.Position) -> XZToast.Task {
        return __showToast(toast, duration: duration, position: position)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval, exclusive: Bool) -> XZToast.Task {
        return __showToast(toast, duration: duration, exclusive: exclusive)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval, completion: XZToast.Completion?) -> XZToast.Task {
        return __showToast(toast, duration: duration, completion: completion)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, position: XZToast.Position, exclusive: Bool) -> XZToast.Task {
        return __showToast(toast, position: position, exclusive: exclusive)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, position: XZToast.Position, completion: XZToast.Completion?) -> XZToast.Task {
        return __showToast(toast, position: position, completion: completion)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, exclusive: Bool, completion: XZToast.Completion?) -> XZToast.Task {
        return __showToast(toast, exclusive: exclusive, completion: completion)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, duration: TimeInterval) -> XZToast.Task {
        return __showToast(toast, duration: duration)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, position: XZToast.Position) -> XZToast.Task {
        return __showToast(toast, position: position)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, exclusive: Bool) -> XZToast.Task {
        return __showToast(toast, exclusive: exclusive)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast, completion: XZToast.Completion?) -> XZToast.Task {
        return __showToast(toast, completion: completion)
    }
    
    @discardableResult
    public func showToast(_ toast: XZToast) -> XZToast.Task {
        return __showToast(toast)
    }
    
    /// 隐藏指定或者所有提示消息。
    /// - Parameters:
    ///   - toast: 提示消息
    ///   - completion: 提示消息完成隐藏后执行的回调
    public func hideToast(_ toast: XZToast? = nil, completion: (()->Void)? = nil) {
        __hideToast(toast, completion: completion)
    }
    
}
