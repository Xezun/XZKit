//
//  XZLog.swift
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//
//  dependency:

import Foundation

/// 仅在 **XZKitDEBUG** 模式下，才在控制台输出指定信息。
/// - Note: 该方法只是控制控制台文本输出，并不会减少构建 message 参数的运算。
/// - Note: 在输出比较消耗资源的内容时，最好还是使用 DEBUG 宏来控制，保证在正式环境中输出内容不被编译。
/// - Note: 使用 format 的方式，以减少在正式环境构造字符串带来额外的资源消耗。
/// - Note: 可以 `%@` 作为任意数据类型的格式占位符，同时也兼容 Objective-C 占位符格式。
///
/// ```swift
/// XZLog("%@", false) // 输出：false
/// XZLog("%d", true)  // 输出：1
/// XZLog("%@ is %@ year(s) old.", "Xiao Ming", 12);
/// // 输出：Xiao Ming is 12 year(s) old.
/// XZLog("%@ is %.2f meter(s) in height.", "Xiao Ming", 1.512);
/// // 输出：Xiao Ming is 1.51 meter(s) in height.
/// ```
///
/// - Parameters:
///   - format: 输出格式。
///   - arguments: 参数。
///   - file: 文件名，可选。
///   - function: 函数名，可选。
///   - line: 行数，可选。
public func XZLog(_ format: String, file: String = #file, function: String = #function, line: Int = #line, _ arguments: Any? ...) {
    guard isDebugMode else {
        return
    }
    
    let date    = XZLogDateFormatter.string(from: Date())
    let comment = "§ \(file.split(separator: "/").last!)(\(line)) § \(function) § \(date) §"
    let line    = String.init(repeating: "-", count: comment.count)
    let message = String.init(formats: format, arguments: arguments)
    
    print("\(line)\n\(comment)\n\(line)\n\(message)\n")
}

/// XZLog 日期格式化。
fileprivate let XZLogDateFormatter = { () -> DateFormatter in
    let dateFormatter = DateFormatter.init()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return dateFormatter
}()


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
        if arguments.isEmpty {
            self = format;
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

