//
//  XZMocoaKey.swift
//  XZKit
//
//  Created by Xezun on 2026/8/23.
//

import Foundation
#if SWIFT_PACKAGE
import XZKitObjC
extension XZMocoaKey: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
#else
extension XZMocoaKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
#endif

#if USES_SWIFT_MOCOA_KEY
@dynamicMemberLookup
public struct XZMocoaKey: Hashable, RawRepresentable, ExpressibleByStringLiteral, @unchecked Sendable {
    public typealias RawValue = String
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    /// @dynamicMemberLookup 支持点任意 key 的实现方法。
    public subscript(dynamicMember member: String) -> XZMocoaKey {
        return XZMocoaKey(rawValue: self.rawValue + ".\(member)")
    }
}

extension XZMocoaKey: _ObjectiveCBridgeable {
    
    // 映射的 Objective-C 类型（因为 XZMocoaKey 本质是 NSString）
    public typealias _ObjectiveCType = NSString
    
    // 1. 从 Swift 转换为 Objective-C
    public func _bridgeToObjectiveC() -> NSString {
        return rawValue as NSString
    }
    
    // 2. 从 Objective-C 转换为 Swift（强制转换时使用）
    public static func _forceBridgeFromObjectiveC(_ source: NSString, result: inout XZMocoaKey?) {
        result = XZMocoaKey(rawValue: source as String)
    }
    
    // 3. 从 Objective-C 转换为 Swift（条件转换时使用，如 as?）
    public static func _conditionallyBridgeFromObjectiveC(_ source: NSString, result: inout XZMocoaKey?) -> Bool {
        result = XZMocoaKey(rawValue: source as String)
        return true
    }
    
    // 4. 从 Objective-C 异步/不检查地转换为 Swift（通常直接复用强转）
    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSString?) -> XZMocoaKey {
        return XZMocoaKey(rawValue: (source ?? "") as String)
    }
    
}
#endif
