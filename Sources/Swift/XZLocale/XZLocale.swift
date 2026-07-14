//
//  XZLocale.swift
//  XZKit
//
//  Created by Xezun on 2026/6/12.
//

import Foundation

extension XZLocale.Language: @retroactive CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
    
}

/// 通过键查找本地化字符串。
public func XZLocalizedString(_ key: String, table: String? = nil, bundle: Bundle = .main, defaultValue: String = "", comment: String) -> String {
    return NSLocalizedString(key, tableName: table, bundle: bundle, value: defaultValue, comment: comment)
}

/// 使用花括号标记的格式化模版，创建本地化字符串。
/// - Parameters:
///   - key: 查找本地化的格式模版的键
///   - table: 模版所在的表
///   - bundle: 模版字所在的包
///   - defaultValue: 默认值
///   - comment: 描述
///   - arguments: 参数列表
/// - Returns: 本地化的字符串
public func XZLocalizedString(_ key: String, table: String? = nil, bundle: Bundle = .main, defaultValue: String = "", _ arguments: Any?...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: bundle, value: defaultValue, comment: "")
    if arguments.isEmpty {
        return format
    }
    return String(markup: .braces, format: format, arguments: arguments)
}
