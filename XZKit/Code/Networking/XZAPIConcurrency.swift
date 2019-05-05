//
//  APIConcurrency.swift
//  XZKit
//
//  Created by mlibai on 2018/2/27.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import Foundation

/// 接口并发。
public enum APIConcurrency {
    
    /// 并发策略。
    public enum Policy: Equatable {
        /// 默认并发策略，所有请求之间互不影响。
        case `default`
        
        /// 当发送新的请求时，先取消目前所有的请求。
        /// - Note: 被取消的请求会收到 APIError.canceled 错误。
        case cancelOthers
        
        /// 发送请求时，如果当前已有请求，那么忽略本次请求。
        /// - Note: 如果请求因为策略被忽略，将产生 .ignored 错误，以解决发送了请求却没有着陆点的问题。
        case ignoreCurrent
        
        /// 当发送新请求时，如果当前有正在进行的请求，则按并发优先级等待执行。
        /// 优先级改变不会影响已经列队的请求。
        case wait(priority: Priority)
    }
    
    /// API 并发优先级。
    public struct Priority: RawRepresentable {
        public typealias RawValue = Int
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
}

extension APIConcurrency.Policy {
    /// API 并发优先级。
    public var priority: APIConcurrency.Priority {
        if case let .wait(priority) = self {
            return priority
        }
        return .default
    }
}

extension APIConcurrency.Priority {
    /// 最低优先级 Int.min 。
    public static let low       = APIConcurrency.Priority.init(rawValue: .min)
    /// 默认优先级 0 。
    public static let `default` = APIConcurrency.Priority.init(rawValue: 0)
    /// 最高优先级 Int.max 。
    public static let high      = APIConcurrency.Priority.init(rawValue: .max)
}

extension APIConcurrency.Priority: ExpressibleByIntegerLiteral, Comparable, CustomStringConvertible {
    
    public static func < (lhs: APIConcurrency.Priority, rhs: APIConcurrency.Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func <= (lhs: APIConcurrency.Priority, rhs: APIConcurrency.Priority) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }

    public static func >= (lhs: APIConcurrency.Priority, rhs: APIConcurrency.Priority) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    public static func > (lhs: APIConcurrency.Priority, rhs: APIConcurrency.Priority) -> Bool {
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

