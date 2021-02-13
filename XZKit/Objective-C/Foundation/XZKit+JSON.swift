//
//  XZKit+JSON.swift
//  XZKit
//
//  Created by Xezun on 2017/8/17.
//
//

import Foundation

extension Data {
    
    /// 将对象转换成 JSON 数据。
    /// - Parameters:
    ///   - json: 对象
    ///   - options: 选项
    public init?(json: Any?, options: JSONSerialization.WritingOptions = .fragmentsAllowed) {
        guard let json = json else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: options) else { return nil }
        self = data;
    }
    
}

extension String {
    
    /// 将对象转换成 JSON 字符串。
    /// - Note: 使用 `JSONSerialization` 处理 `Array<Any>`、`Dictionary<String, Any>` 类型的数据。
    /// - Note: 其它对象使用 `String.init(describing:)` 方法。
    /// - Parameter value: JSON 对象，比如 Array、Dictionary 。
    public init?(json value: Any?, encoding: Encoding, options: JSONSerialization.WritingOptions = .fragmentsAllowed) {
        guard let data = Data.init(json: value, options: options) else { return nil }
        self.init(data: data, encoding: encoding)
    }
    
}

extension Dictionary {
    
    /// 解析 JSON 字符串，转换成字典。
    /// - Parameters:
    ///   - json: 字典格式的 JSON 字符串。
    ///   - encoding: 字符串的编码格式，默认 .utf8 。
    public init?(json: String?) {
        self.init(json: json?.data(using: .utf8))
    }
    
    /// 解析 JSON 数据，转换成字典。
    /// - Parameter json: 字典格式的 JSON 二进制数据。
    public init?(json: Data?, options: JSONSerialization.ReadingOptions = .allowFragments) {
        guard let json = json else { return nil }
        guard let dict = (try? JSONSerialization.jsonObject(with: json, options: options)) as? [Key: Value] else {
            return nil
        }
        self = dict
    }
    
}

extension Array {
    
    /// 将 JSON 字符串，转换成数组。
    /// - Parameters:
    ///   - json: 数组格式的 JSON 字符串。
    ///   - encoding: 字符串编码，默认 .utf8 。
    public init?(json: String?) {
        self.init(json: json?.data(using: .utf8))
    }
    
    /// 解析 JSON 数据，转换成数组。
    /// - Parameter json: 数组格式的 JSON 数据。
    public init?(json: Data?, options: JSONSerialization.ReadingOptions = .allowFragments) {
        guard let json = json else { return nil }
        guard let array = (try? JSONSerialization.jsonObject(with: json, options: options)) as? [Element] else {
            return nil
        }
        self = array
    }
    
}
