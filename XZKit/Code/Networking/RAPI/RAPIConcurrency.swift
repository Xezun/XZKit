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
    
    case `default`
    
    case cancelOthers
    
    case ignoreCurrent
    
    case wait(priority: Priority)
    
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
    
    public static let low       = RAPIConcurrency.Priority(rawValue: .min)
    
    public static let `default` = RAPIConcurrency.Priority(rawValue: 0)
    
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



