//
//  String+XZLog.swift
//  XZKit
//
//  Created by Xezun on 2021/3/3.
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
