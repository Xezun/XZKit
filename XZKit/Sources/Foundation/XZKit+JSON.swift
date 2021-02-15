//
//  XZKit+JSON.swift
//  XZKit
//
//  Created by Xezun on 2017/8/17.
//
//

import Foundation


extension Dictionary: XZJSONable {
    
}

extension Array: XZJSONable {
    
}

/// 让对象支持与 JSON 之间互相转换。
public protocol XZJSONable  {
    
    /// 将 JSON 反序列化为对象。
    /// - Parameters:
    ///   - value: JSON Data or String
    ///   - options: 反序列化选项
    init?(JSON value: Any?, options: JSONSerialization.ReadingOptions)
    
    /// 对象序列化成 JSON 数据。
    /// - Parameter options: 序列化选项
    func JSON(with options: JSONSerialization.WritingOptions) -> Data?
    
}

extension XZJSONable {
    
    public init?(JSON value: Any?, options: JSONSerialization.ReadingOptions = .allowFragments) {
        var json: Data! = nil
        
        if let data = value as? Data {
            json = data
        } else if let string = value as? String {
            guard let data = string.data(using: .utf8) else { return nil }
            json = data
        } else {
            return nil
        }
        
        guard let value = try? JSONSerialization.jsonObject(with: json, options: options) as? Self else { return nil }
        
        self = value
    }
    
    public func JSON(with options: JSONSerialization.WritingOptions = .fragmentsAllowed) -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    public func JSON(with options: JSONSerialization.WritingOptions = .fragmentsAllowed, encoding: String.Encoding) -> String? {
        guard let data = JSON(with: options) else { return nil }
        return String.init(data: data, encoding: encoding)
    }
    
}
