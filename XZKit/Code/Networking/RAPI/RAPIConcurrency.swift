//
//  RAPIConcurrency.swift
//  XZKit
//
//  Created by Xezun on 2020/6/29.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

/// 并发策略。
public enum RAPIConcurrency: Equatable {
    
    /// 默认并发策略，所有请求之间互不影响。
    case `default`
    
    /// 当发送新的请求时，先取消目前所有的请求。
    /// - Note: 请求被取消会产生 APIError.canceled 错误。
    case cancelOthers
    
    /// 发送请求时，如果当前已有请求，那么忽略本次请求。
    /// - Note: 请求被忽略会产生 APIError.ignored 错误。
    case ignoreCurrent
    
    /// 当发送新请求时，如果当前有正在进行的请求，则按并发优先级等待执行。
    /// 优先级改变不会影响已经列队的请求。
    case wait(priority: Priority)
    
    
    /// API 并发优先级。
    public var priority: RAPIConcurrency.Priority {
        if case let .wait(priority) = self {
            return priority
        }
        return .default
    }
    
    public struct Priority: RawRepresentable {
        public typealias RawValue = Int
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
}

extension RAPIConcurrency.Priority {
    /// 最低优先级 Int.min 。
    public static let low       = RAPIConcurrency.Priority(rawValue: .min)
    /// 默认优先级 0 。
    public static let `default` = RAPIConcurrency.Priority(rawValue: 0)
    /// 最高优先级 Int.max 。
    public static let high      = RAPIConcurrency.Priority(rawValue: .max)
}


extension RAPIConcurrency.Priority: ExpressibleByIntegerLiteral, Comparable, CustomStringConvertible {
    
    public static func < (lhs: RAPIConcurrency.Priority, rhs: RAPIConcurrency.Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func <= (lhs: RAPIConcurrency.Priority, rhs: RAPIConcurrency.Priority) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }

    public static func >= (lhs: RAPIConcurrency.Priority, rhs: RAPIConcurrency.Priority) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    public static func > (lhs: RAPIConcurrency.Priority, rhs: RAPIConcurrency.Priority) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
    
    public var description: String {
        return rawValue.description
    }
    
}
