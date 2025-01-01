//
//  String.swift
//  XZKit
//
//  Created by Xezun on 2017/4/24.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import Foundation

extension String {
    
    /// 将任意值强转成 String 。
    /// - Note: 除 nil、NSNull 外，所有的值都使用 String.init(describing:) 转换为 String 对象。
    ///
    /// - Parameter value: 任意值。
    public init?(casting value: Any?) {
        guard let anyValue = value else {
            return nil
        }
        if anyValue is NSNull {
            return nil
        }
        self.init(describing: anyValue)
    }
    
}

extension String {
    
    /// 字符的书写顺序控制字符枚举。
    /// - Note: 书写方向不同的语言在一起拍版时，需要特殊的字符来控制它们的书写方向：
    /// - 自左向右：\u{2066}
    /// - 自右向左：\u{2067}
    /// - 以第一个字符为准：\u{2068}
    /// - 结束字符：\u{2069}
    public enum LanguageDirection: String {
        /// Treat the following text as isolated and left-to-right.
        case leftToRight = "\u{2066}"
        /// Treat the following text as isolated and right-to-left.
        case rightToLeft = "\u{2067}"
        /// Treat the following text as isolated and in the direction of its first strong directional character that is not inside a nested isolate.
        case firstStrong = "\u{2068}"
        /// The following character terminates the scope of the last LRI, RLI, or FSI whose scope has not yet been terminated,
        /// as well as the scopes of any subsequent LREs, RLEs, LROs, or RLOs whose scopes have not yet been terminated.
        public var terminator: String {
            return "\u{2069}"
        }
    }
    
    /// 将字符指定为独立的书写方向。
    /// - Note: 当阿语句子中包含其它自左向右语言符号时，其它语言可能显示不正常，
    ///         使用 \u{2066} 字符将自左向右的语言包裹起来，就可以就正常显示了。
    ///
    /// ```
    /// print("Price: $130")
    ///   // prints Price: $130
    /// print("السلع: $130")
    ///   // prints السلع: $130
    /// print("\u{2067}السلع: \u{2066}$130\u{2069}\u{2069}")
    ///   // prints ⁧السلع: ⁦$130⁩⁩
    /// ```
    /// - SeeAlso: [Unicode® Standard Annex #9](https://unicode.org/reports/tr9/#Explicit_Directional_Isolates)
    ///
    /// - Parameters:
    ///   - direction: 书写方向。
    public func isolating(_ direction: LanguageDirection) -> String {
        return direction.rawValue + self + direction.terminator
    }
    
}

extension String {
    
    /// 过滤掉字符串首尾指定字符。
    ///
    /// - Parameter aString: 被过滤的字符，默认 .whitespacesAndNewlines 字符。
    /// - Returns: 过滤后的字符串。
    public func trimmingCharacters(in aString: String? = nil) -> String {
        if let string = aString {
            return trimmingCharacters(in: CharacterSet.init(charactersIn: string))
        }
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// 中文文字转拼音。 transformingMandarinToLatin / mandarinToLatinTransformed.
    public var transformingMandarinToLatin: String {
        let string = self as CFString
        let mutableStringRef: CFMutableString! = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(string), string)
        CFStringTransform(mutableStringRef, nil, kCFStringTransformMandarinLatin, false);
        CFStringTransform(mutableStringRef, nil, kCFStringTransformStripDiacritics, false);
        return (mutableStringRef as String)
    }
    
    /// 当前字符串 URL 编码后的字符串。
    /// - Note: 字符集合 CharacterSet.urlFragmentAllowed 中的字符不会被转义。
    public var addingURIEncoding: String? {
        return addingPercentEncoding(withAllowedCharacters: .URIEncodingAllowed)
    }
    
    /// 当前字符串 URL 编码后的字符串。
    /// - Note: 转义除字符集合 .alphanumerics 以外的所有字符。
    public var addingURIComponentEncoding: String? {
        return addingPercentEncoding(withAllowedCharacters: .URIComponentEncodingAllowed)
    }
    
    /// 当前字符串 URL 解码后的字符串。
    /// - Note: 在 iOS 平台，与 decodedURIComponent 相同。
    public var removingURIEncoding: String? {
        return removingPercentEncoding;
    }
    
    /// 当前字符串 URL 解码后的字符串。
    /// - Note: 当前字符串 URL 解码后的字符串。
    public var removingURIComponentEncoding: String? {
        return removingPercentEncoding
    }
    
}

extension String {
    
    /// 字符串替换匹配规则：在指定边界字符之间的字符（包括边界字符）。
    public struct ReplcingFormatPredicate: ExpressibleByStringLiteral {
        
        /// 默认替换格式，匹配以左大括号`{`为开始边界，右大括号`}`结束边界的字符字符串。
        public static let `default` = ReplcingFormatPredicate(start: "{", end: "}")
        
        public let start: Character
        public let end: Character
        
        public typealias StringLiteralType = String

        public init(start: Character, end: Character) {
            self.start = start
            self.end = end
        }
        
        public init(stringLiteral value: String) {
            if value.isEmpty {
                self = .default
            } else {
                self = ReplcingFormatPredicate(start: value.first!, end: value.last!)
            }
        }
    }
    
    /// 根据条件匹配格式字符串中的字符并替换。
    /// ```
    /// print(String(replacing: "This is a {0}.", using: { (match) -> String in
    ///     return "pen"
    /// }, predicate: ("{", "}")))
    /// // 输出：This is a pen.
    /// ```
    ///
    /// - Parameters:
    ///   - format: 格式字符串。
    ///   - transform: 遍历所有匹配的字符并返回替换字符的闭包。
    ///   - match: 匹配字符。
    ///   - predicate: 匹配条件，匹配字符的首尾字符，默认 ("{", "}")。
    /// - Returns: 字符串。
    public init(formats: String, predicate: ReplcingFormatPredicate = .default, replacing: (_ match: String) -> String) {
        var result = String.init()
        
        var isMatching = false         // 遇到了开始字符，进入了匹配模式
        var matches    = String.init() // predicate 匹配到的字符
        
        if predicate.start == predicate.end {
            // 首尾边界字符相同
            for char in formats {
                if char == predicate.start {
                    if isMatching {
                        isMatching = false
                        result.append(replacing(matches))
                        matches.removeAll()
                    } else {
                        isMatching = true
                    }
                } else if isMatching {
                    matches.append(char)
                } else {
                    result.append(char)
                }
            }
        } else {
            // 首尾边界字符不相同
            for char in formats {
                switch char {
                case predicate.start:
                    // 当遍历到开始字符时：
                    // 1. 如果未进入识别模式，则进入识别模式；
                    // 2. 如果已进入识别模式，则重新进入识别模式。
                    if isMatching {
                        result.append(predicate.start)  // 追加开始符。
                        result.append(matches)            // 将待识别的字符到字符串。
                        matches.removeAll()               // 清除待识别的字符。
                    } else {
                        isMatching = true;
                    }
                    
                case predicate.end:
                    // 当遍历到开始字符时：
                    // 1. 如果未进入识别模式，则将结束字符当作普通字符；
                    // 2. 如果已进入识别模式，则获取替换字符。
                    if isMatching { // 当前为数字识别模式，则结束数字识别。
                        isMatching = false
                        result.append(replacing(matches))
                        matches.removeAll() // 清除已识别的字符
                    } else {
                        result.append(char)
                    }
                    
                default:
                    // 其它非边界字符：
                    // 1. 如果处于识别模式，则字符为待替换字符；
                    // 2. 如果处于非识别模式，则为普通字符。
                    if isMatching {
                        matches.append(char)
                    } else {
                        result.append(char)
                    }
                }
            }
        }
        
        if isMatching {
            // 遍历字符串结束时，仍然处于识别状态，则将未识别出的字符添加到字符串。
            result.append(predicate.start)
            result.append(matches)
        }
        
        self = result
    }
    
    /// 根据字典的 Key 以及匹配条件，在格式字符串中，替换匹配字符串为字典的 Value 。
    /// ```
    /// print(String(replacing: "This is a {0}.", using: ["0": "pen"], predicate: ("{", "}")))
    /// // 输出：This is a pen.
    /// ```
    ///
    /// - Parameters:
    ///   - format: 格式字符串。
    ///   - dictionary: 字典。
    ///   - predicate: 匹配条件，匹配字符的首尾字符，默认 ("{", "}")。
    /// - Returns: 字符串。
    public init(formats: String, predicate: ReplcingFormatPredicate = .default, replacing: [String: CustomStringConvertible]) {
        self.init(formats: formats, predicate: predicate, replacing: { (match) -> String in
            if let value = replacing[match] {
                return value.description
            }
            return match
        })
    }
    
    /// 根据数组索引以及匹配条件，在格式字符串中，替换匹配字符串为数组索引所对应的值。
    /// ```
    /// print(String(replacing: "This is a {0}.", using: ["pen"], predicate: ("{", "}")))
    /// // 输出：This is a pen.
    /// ```
    ///
    /// - Parameters:
    ///   - format: 格式字符串。
    ///   - array: 数组。
    ///   - predicate: 匹配条件，匹配字符的首尾字符，默认 ("{", "}")。
    /// - Returns: 字符串。
    public init(formats: String, predicate: ReplcingFormatPredicate = .default, replacing: [CustomStringConvertible]) {
        self.init(formats: formats, predicate: predicate, replacing: { (match) -> String in
            guard let index = Int(match) else { return match }
            guard index < replacing.count else {
                return match
            }
            return replacing[index].description
        })
    }
    
    /// 将格式字符串中，符合匹配条件的数字，替换为对应顺序的参数值。
    /// ```
    /// let string = String(formats: "This is a {0}.", "pen")
    /// print(string)
    /// // 输出：This is a pen.
    /// ```
    ///
    /// - Parameters:
    ///   - format: 格式字符串。
    ///   - arguments: 参数。
    ///   - predicate: 匹配条件，匹配字符的首尾字符，默认 ("{", "}")。
    /// - Returns: 字符串。
    public init(formats: String, predicate: ReplcingFormatPredicate = .default, replacing arguments: CustomStringConvertible...) {
        self.init(formats: formats, predicate: predicate, replacing: arguments)
    }
    
}

extension CharacterSet {
    
    public static let URIEncodingAllowed: CharacterSet = { () -> CharacterSet in
        return CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789;,/?:@&=+$-_.!~*'()#")
    }()
    
    public static let URIComponentEncodingAllowed: CharacterSet = { () -> CharacterSet in
        return CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789().!~*'-_")
    }()
    
}
