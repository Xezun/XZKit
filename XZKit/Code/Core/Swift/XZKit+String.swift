//
//  String.swift
//  XZKit
//
//  Created by Xezun on 2017/4/24.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import Foundation

extension String {
    
    /// 格式化字符串，与原生的构造方法相比，本方法支持任意类型的参数。
    /// - Note: Swift 版本格式，可以使用 `%@` 作为任意类型的变量的占位符。
    /// - Note: 值 nil 将输出字符串 `"nil"` 。
    /// - Note: 该构造方法的性能尚未验证。
    ///
    /// - Parameters:
    ///   - format: 字符串格式。
    ///   - arguments: 参数列表。
    public init(formats format: String, _ arguments: Any? ...) {
        self.init(formats: format, arguments: arguments)
        
    }
    
    /// 格式化字符串，与原生的构造方法相比，本方法支持任意类型的参数。
    /// - Note: Swift 版本格式，可使用 `%@` 作为任意类型的变量的占位符。
    /// - Note: 值 nil 将输出字符串 `"nil"` 。
    /// - Note: 该构造方法的性能尚未验证。
    ///
    /// - Parameters:
    ///   - format: 字符串格式。
    ///   - arguments: 参数数组。
    public init(formats format: String, arguments: [Any?]) {
        // 遍历 format 中的所有格式占位符，将所有 %@ 占位符和不能转化为 CVarArg 其他占位符参赛都转换成 String 值。
        var meetStart = false
        var parameters = [CVarArg]()
        var index = 0;
        for charactor in format {
            if charactor == "%" {
                meetStart = !meetStart
            } else if meetStart { // 匹配到占位符
                meetStart = false
                let value = arguments[index]
                // %@ 适配所有类型。
                // 如果值对应的占位符不为 %@ ，且其可以转换成 CVarArg ，则使用其 CVarArg 值，否则将其转换成 String 值。
                if charactor != "@", let cValue = value as? CVarArg {
                    parameters.append(cValue)
                } else if let string = value {
                    parameters.append(String.init(describing: string))
                } else {
                    parameters.append("nil")
                }
                // 下一个参数，如果已经匹配所有参数，则结束循环。
                index += 1
                guard index < arguments.count else {
                    break
                }
            }
        }
        
        self.init(format: format, arguments: parameters)
    }
}

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
    public enum IsolateDirection: String {
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
    ///   - string: 待指定的字符。
    ///   - direction: 书写方向。
    public init(isolating string: String, direction: String.IsolateDirection) {
        self = direction.rawValue + string + direction.terminator
    }
    
}

extension String {
    
    // 字符串替换匹配规则：在指定边界字符之间的字符（包括边界字符）。
    public struct IsolateBoundary: ExpressibleByStringLiteral {
        
        public static let `default` = IsolateBoundary(start: "{", end: "}")
        
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
                self = IsolateBoundary(start: value.first!, end: value.last!)
            }
        }
    }
    
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
    public init(replacing format: String, with transform: (_ match: String) -> String, predicate: String.IsolateBoundary = .default) {
        var result = String.init()
        var match = String.init()
        var isMatching = false
        for char in format {
            switch char {
            case predicate.start:
                if !isMatching {
                    // 当前非数字识别模式，则开始数字识别模式。
                    isMatching = true;
                } else if predicate.start == predicate.end { // 如果开始边界符与结束边界符相等，则结束数字识别。
                    isMatching = false
                    result.append(transform(match))
                    match.removeAll() // 清除已识别的字符
                } else { // 开始边界符与结束边界符不相等，且当前已经是数字识别模式，则结束当前的，开始新的。
                    result.append(predicate.start)  // 追加开始符。
                    result.append(match)            // 将待识别的字符到字符串。
                    match.removeAll()               // 清除待识别的字符。
                }
                
            case predicate.end:
                if isMatching { // 当前为数字识别模式，则结束数字识别。
                    isMatching = false
                    result.append(transform(match))
                    match.removeAll() // 清除已识别的字符
                } else { // 当前是非数字识别模式，直接将字符添加到新字符串中。
                    result.append(char)
                }
                
            default:
                if isMatching {
                    match.append(char)
                } else {
                    result.append(char)
                }
            }
        }
        
        if isMatching {
            // 遍历字符串结束时，仍然处于识别状态，则将未识别出的字符添加到字符串。
            result.append(predicate.start)
            result.append(match)
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
    public init(replacing format: String, with dictionary: [String: Any], predicate: String.IsolateBoundary = .default) {
        self.init(replacing: format, with: { (match) -> String in
            if let value = dictionary[match] {
                return String.init(describing: value)
            }
            return match
        }, predicate: predicate)
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
    public init(replacing format: String, with array: [Any], predicate: String.IsolateBoundary = .default) {
        self.init(replacing: format, with: { (match) -> String in
            guard let index = Int(match) else { return match }
            guard index < array.count else {
                return match
            }
            return String.init(describing: array[index])
        }, predicate: predicate)
    }
    
    /// 将格式字符串中，符合匹配条件的数字，替换为对应顺序的参数值。
    /// ```
    /// print(String(replacing: "This is a {0}.", "pen", predicate: ("{", "}")))
    /// // 输出：This is a pen.
    /// ```
    ///
    /// - Parameters:
    ///   - format: 格式字符串。
    ///   - arguments: 参数。
    ///   - predicate: 匹配条件，匹配字符的首尾字符，默认 ("{", "}")。
    /// - Returns: 字符串。
    public init(replacing format: String, _ arguments: Any..., predicate: String.IsolateBoundary = .default) {
        self.init(replacing: format, with: arguments, predicate: predicate)
    }
    
    public func replacingOccurrences(of predicate: String.IsolateBoundary, with replacement: Any...) -> String {
        return String.init(replacing: self, with: replacement, predicate: predicate)
    }
    
    public func replacingOccurrences(of predicate: String.IsolateBoundary, with replacement: (String) -> String ) -> String {
        return String.init(replacing: self, with: replacement, predicate: predicate)
    }
    
    public func replacingOccurrences(of predicate: String.IsolateBoundary, with replacement: [String: Any]) -> String {
        return String.init(replacing: self, with: replacement, predicate: predicate)
    }
    
    public func replacingOccurrences(of predicate: String.IsolateBoundary, with replacement: [Any]) -> String {
        return String.init(replacing: self, with: replacement, predicate: predicate)
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
