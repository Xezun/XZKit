//
//  XZAppLanguage.swift
//  XZKit
//
//  Created by Xezun on 2018/7/26.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

extension AppLanguage {
    
    /// App 的第一偏好语言设置。
    public static var preferred: AppLanguage {
        get { return UserDefaults.standard.preferredLanguage     }
        set { UserDefaults.standard.preferredLanguage = newValue }
    }
    
}

extension AppLanguage: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
}

/// 函数 `NSLocalizedString` 的增强函数：支持使用 `{n}` 占位符指定参数。
/// - 动态参数使用 String.init(describing:) 转化为字符串。
/// - 动态参数的索引起始为 0 。
///
/// ```
/// // 如果有国际化配置键 CountOfLikesKey 对应的语言配置为：
/// // 英文: "{0} Likes" = "{0} Likes";
/// // 中文: "{0} Likes" = "喜欢（{0}）";
///
/// print(LocalizedString("{0} Likes", 1342, comment: "The count of likes."))
///
/// // 那么在不同语言下，输出内容分别为：
/// // 英文："1342 Likes"
/// // 中文："喜欢（1342）"
/// ```
///
/// - SeeAlso: NSLocalizedString
/// - Parameters:
///   - key: 国际化字符串键。
///   - arguments: 动态参数，用于替换国际化字符串中的占位符。
///   - surroundings: 动态参数界定字符，默认 ("{", "}")。
///   - comment: 描述 `key` 文本。
/// - Returns: 国际化字符串。
public func LocalizedString(_ key: String, _ arguments: Any ..., predicate: String.ReplcingFormatPredicate = .default, comment: String) -> String {
    return LocalizedString(key, arguments: arguments, predicate: predicate, comment: comment)
}

/// 函数 `NSLocalizedString` 的增强函数：支持使用 `{n}` 占位符指定参数。
/// - 动态参数使用 String.init(describing:) 转化为字符串。
/// - 动态参数的索引起始为 0 。
///
/// ```
/// // 如果有国际化配置键 CountOfLikesKey 对应的语言配置为：
/// // 英文: "{0} Likes" = "{0} Likes";
/// // 中文: "{0} Likes" = "喜欢（{0}）";
///
/// print(LocalizedString("{0} Likes", arguments: [1342], comment: "The count of likes."))
///
/// // 那么在不同语言下，输出内容分别为：
/// // 英文："1342 Likes"
/// // 中文："喜欢（1342）"
/// ```
///
/// - SeeAlso: NSLocalizedString
/// - Parameters:
///   - key: 国际化字符串键。
///   - arguments: 动态参数，用于替换国际化字符串中的占位符。
///   - surroundings: 动态参数界定字符，默认 ("{", "}")。
///   - comment: 描述 `key` 文本。
/// - Returns: 国际化字符串。
public func LocalizedString(_ key: String, arguments: [Any], predicate: String.ReplcingFormatPredicate = .default, comment: String) -> String {
    if arguments.isEmpty {
        return NSLocalizedString(key, comment: comment)
    }
    let formats = NSLocalizedString(key, comment: comment)
    return String.init(formats: formats, predicate: predicate, replacing:arguments)
}
