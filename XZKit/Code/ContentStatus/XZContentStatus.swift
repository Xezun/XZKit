//
//  ContentStatus.swift
//  XZKit
//
//  Created by mlibai on 2018/1/15.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

extension ContentStatus {

    /// 默认状态，没有 contentStatusView 的状态。
    /// - Note: 特殊的，此状态表示视图的默认状态。
    /// - Note: 一般情况下，请将此状态作为默认状态，不设置状态视图。
    public static let `default` = ContentStatus(rawValue: "default")

    /// 默认的内容状态值，表示对象或视图控件的内容为空。
    public static let empty     = ContentStatus(rawValue: "empty")

    /// 默认的内容状态值，表示对象或视图控件正在加载内容。
    public static let loading   = ContentStatus(rawValue: "loading")

    /// 默认的内容状态值，表示对象或视图控件加载内容失败。
    public static let error     = ContentStatus(rawValue: "error")

}

/// ContentStatus 用于描述对象的内容的状态。
/// - 判断内容状态是否相同唯一依据为 rawValue 属性。
public struct ContentStatus: RawRepresentable, CustomStringConvertible, Hashable, Equatable {

    public typealias RawValue = String

    /// 标识内容状态的原始值。
    public let rawValue: String

    /// 构造一个内容状态结构体。
    ///
    /// - Parameters:
    ///   - rawValue: 内容状态的原始值。
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// 描述当前内容状态的文本信息。
    public var description: String {
        return rawValue
    }
    
    /// 返回内容状态的原始值。
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    /// 比较两个内容状态是否相同，根据内容状态的原始值 rawValue 来判断。
    ///
    /// - Parameters:
    ///   - lhs: 待比较的状态。
    ///   - rhs: 被比较的状态。
    /// - Returns: 是否相同。
    public static func == (lhs: ContentStatus, rhs: ContentStatus) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
}

extension ContentStatus: ReferenceConvertible {
    
    public typealias ReferenceType = NSString
    
    public typealias _ObjectiveCType = NSString
    
    public func _bridgeToObjectiveC() -> NSString {
        return rawValue as NSString
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: NSString, result: inout ContentStatus?) {
        result = ContentStatus.init(rawValue: source as String)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: NSString, result: inout ContentStatus?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSString?) -> ContentStatus {
        if let rawValue = source {
            return ContentStatus.init(rawValue: rawValue as String)
        }
        return ContentStatus.default
    }
    
    public var debugDescription: String {
        return description
    }
    
}
