//
//  JSON.swift
//  XZKit
//
//  Created by Xezun on 2017/8/17.
//
//

import Foundation

/// 让对象支持与 JSON 之间互相转换。
public protocol JSONConvertible  {
    
    /// 将 JSON 反序列化为对象。
    /// - Parameters:
    ///   - data: JSON Data
    ///   - options: 反序列化选项
    init?(JSON data: Data, options: JSONSerialization.ReadingOptions)
    
    /// 对象序列化成 JSON 数据。
    /// - Parameter options: 序列化选项
    func JSON(with options: JSONSerialization.WritingOptions) -> Data?
    
}

extension JSONConvertible {
    
    public init?(JSON data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) {
        guard let value = try? JSONSerialization.jsonObject(with: data, options: options) as? Self else { return nil }
        
        self = value
    }
    
    /// 字符串形式的 JSON 数据转换为对象。
    /// - Parameters:
    ///   - string: JSON string
    ///   - encoding: 字符串的编码格式
    ///   - options: 反序列化选项
    public init?(JSON string: String?, using encoding: String.Encoding = .utf8, options: JSONSerialization.ReadingOptions) {
        guard let data = string?.data(using: encoding) else { return nil }
        self.init(JSON: data, options: options)
    }
    
    /// 将 JSON 数据或字符串转换为对象。
    /// - Parameters:
    ///   - value: JSON string or data
    ///   - options: 反序列化选项
    public init?(JSON value: Any?, options: JSONSerialization.ReadingOptions = .allowFragments) {
        if let data = value as? Data {
            self.init(JSON: data, options: options)
        } else if let string = value as? String {
            self.init(JSON: string, using: .utf8, options: options)
        } else {
            return nil
        }
    }
    
    /// 对象序列化为 JSON 数据。
    /// - Parameter options: 序列化选项
    /// - Returns: JSON
    public func JSON(with options: JSONSerialization.WritingOptions = .fragmentsAllowed) -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    /// 对象数列化为 JSON 字符串。
    /// - Parameters:
    ///   - options: 序列化选项
    ///   - encoding: 字符串编码
    /// - Returns: JSON
    public func JSON(with options: JSONSerialization.WritingOptions = .fragmentsAllowed, encoding: String.Encoding) -> String? {
        guard let data = JSON(with: options) else { return nil }
        return String.init(data: data, encoding: encoding)
    }
    
}

extension Dictionary: JSONConvertible {
    
}

extension Array: JSONConvertible {
    
}

