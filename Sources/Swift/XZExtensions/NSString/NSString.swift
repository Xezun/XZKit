//
//  NSString.swift
//  XZKit
//
//  Created by Xezun on 2025/6/23.
//

import Foundation

extension String {
    
    /// 支持 `%@` 作为任意类型数据的格式化占位符的构造字符串方法，且不限制变量必须为 ``CVarArg`` 类型。
    ///
    /// - Parameters:
    ///   - format: 字符串格式
    ///   - arguments: 参数列表
    public init(formal format: String, _ arguments: Any? ...) {
        self.init(formal: format, arguments: arguments)
    }
    
    /// 支持 `%@` 作为任意类型数据的格式化占位符的构造字符串方法，且不限制变量必须为 ``CVarArg`` 类型。
    /// - Parameters:
    ///   - format: 字符串格式
    ///   - arguments: 参数数组
    public init(formal format: String, arguments: [Any?]) {
        if arguments.isEmpty {
            self = format
            return
        }
        
        var start = false // 是否遇到格式化占位符 % 标记
        var index = 0;    // 当前处理的参数
        var parameters = [CVarArg]() // 替换后的参数
                
        // 遍历所有格式占位符：
        // 1. 占位符 %@ 对应的参数替换为对应的字符串；
        // 2. 占位符对应的参数不是 CVarArg 类型，替换为对应的字符串；
        // 3. nil 替换为字符串 "nil"。
        for charactor in format {
            // 占位符开始符号
            if charactor == "%" {
                start = !start
            } else if start { // 当前字符是格式化占位符
                start = false
                
                if let value = arguments[index] {
                    if charactor == "@" {
                        parameters.append(String(describing: value))
                    } else if let cValue = value as? CVarArg {
                        parameters.append(cValue)
                    } else {
                        parameters.append(String(describing: value))
                    }
                } else {
                    parameters.append("nil")
                }
                
                // 下一个参数，如果已经匹配所有参数，则结束循环。
                index += 1
                
                if index >= arguments.count {
                    break
                }
            }
        }
        
        self.init(format: format, arguments: parameters)
    }
    
}

/// 字符的书写顺序控制字符枚举。
/// - Note: 书写方向不同的语言在一起拍版时，需要特殊的字符来控制它们的书写方向：
/// - 自左向右：\u{2066}
/// - 自右向左：\u{2067}
/// - 以第一个字符为准：\u{2068}
/// - 结束字符：\u{2069}
public enum XZLanguageDirectionIsolates: String {
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

extension String {
    
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
    public func applyingLanguageDirection(with isolates: XZLanguageDirectionIsolates) -> String {
        return isolates.rawValue + self + isolates.terminator
    }
    
}

extension String {
    
    /// 中文文字转拼音。 transformingMandarinToLatin / mandarinToLatinTransformed.
    public var transformingMandarinToLatin: String {
        return (self as NSString).transformingMandarinToLatin
    }

    /// 当前字符串 URL 编码后的字符串。
    /// - Note: 字符集合 CharacterSet.urlFragmentAllowed 中的字符不会被转义。
    public var addingURIEncoding: String? {
        return (self as NSString).addingURIEncoding
    }
    
    /// 当前字符串 URL 编码后的字符串。
    /// - Note: 转义除字符集合 .alphanumerics 以外的所有字符。
    public var addingURIComponentEncoding: String? {
        return (self as NSString).addingURIComponentEncoding
    }
    
    /// 当前字符串 URL 解码后的字符串。
    /// - Note: 在 iOS 平台，与 decodedURIComponent 相同。
    public var removingURIEncoding: String? {
        return (self as NSString).removingURIEncoding;
    }
    
    /// 当前字符串 URL 解码后的字符串。
    /// - Note: 当前字符串 URL 解码后的字符串。
    public var removingURIComponentEncoding: String? {
        return (self as NSString).removingURIComponentEncoding
    }
    
}

extension String {
    
    /// 使用标记符格式模版，创建字符串。
    /// - Parameters:
    ///   - markup: 格式模版中，用来标记参数的标记符
    ///   - format: 格式模版
    ///   - arguments: 参数
    public init(markup: XZStringMarkup, format: String, arguments: [Any?]) {
        // 将形如 {2%.2f} 的格式解析为 {index: 2, format: ".2f"} 元组
        func markupFormatInfo(from matchedString: String) -> (index: Int, format: String?)? {
            if let index = matchedString.firstIndex(of: "%") {
                guard let n = Int(matchedString[..<index]) else {
                    return nil
                }
                let index = matchedString.index(after: index)
                let format = matchedString[index...]
                if format.isEmpty {
                    return (n, nil)
                }
                return (n, String(format))
            }
            if let n = Int(matchedString) {
                return (n, nil)
            }
            return nil
        }
        
        // 记录已经解析的格式，以供复用。key 为参数的 index
        var cachedFormats = [Int: String]()
        
        // 将模版中形如 {2%.2f} 的标记格式，转换为形如 %2$.2f 的标准格式。
        let format = (format as NSString).replacingOccurrences(with: markup, using: { matchedString in
            // 不合法的参数占位，直接移除（保留的话，可能会影响下面使用标准格式创建字符串）
            guard let info = markupFormatInfo(from: matchedString) else { return "" }
            guard info.index > 0, info.index <= arguments.count else { return "" }
            
            let index = info.index
            guard let format = (info.format ?? cachedFormats[index]) else {
                return "%\(index)$@"
            }
            
            guard arguments[index - 1] is CVarArg else {
                return "%\(index)$@"
            }
            
            cachedFormats[index] = format
            return "%\(index)$\(format)"
        })
        
        // 将参数转换为 CVarArg 类型。
        let arguments = arguments.map({ (value) -> CVarArg in
            // 值为 nil 的参数，转换为空字符串
            guard let value = value else {
                return ""
            }
            // 非 C 类型的参数转换为字符串
            guard let value = value as? CVarArg else {
                return String(describing: value)
            }
            // 可以直接使用的 C 类型参数
            return value
        })
        
        // 使用标准格式模版函数创建字符串。
        self.init(format: format, arguments: arguments)
    }
    
    /// 使用标记符格式模版，创建字符串。
    /// - Parameters:
    ///   - markup: 格式模版中，用来标记参数的标记符
    ///   - format: 格式模版
    ///   - arguments: 参数
    public init(markup: XZStringMarkup, format: String, _ arguments: Any? ...) {
        self.init(markup: markup, format: format, arguments: arguments)
    }
    
    /// 使用花括号格式模版，创建字符串。
    /// - Parameters:
    ///   - format: 使用花括号标记参数的格式模版
    ///   - arguments: 参数
    public init(braces format: String, _ arguments: Any? ...) {
        self.init(markup: .braces, format: format, arguments: arguments)
    }
    
}
