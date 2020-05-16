//
//  URL.swift
//  XZKit
//
//  Created by mlibai on 2017/5/3.
//
//

import Foundation

extension URL {
    
    /// 获取该属性将生成一个针对当前 URL 的 URLQueryComponent 对象。
    /// - Note: 这是一个计算属性。
    /// - Note: 如果 URL 不合法，那么该属性返回 nil 。
    public var queryComponent: URLQueryComponent? {
        get {
            return URLQueryComponent.init(self)
        }
        set {
            guard let url = newValue?.url else { return }
            self = url
        }
    }
    
}

/// 通过 URLQueryComponent 对象，可以像字典一样，用键值来直接管理 URL.query 内容。
public struct URLQueryComponent: CustomStringConvertible {
    
    /// 当前 URLQueryComponent 所属的 URL 。
    public var url: URL? {
        return components.url
    }
    
    private var components: URLComponents
    
    /// 为指定 URL 构造一个处理 query 的 URLQueryComponent 对象。
    /// - Note: URL 可以没有 query 部分，但是不合法的 URL 无法构造 URLQueryComponent 对象。
    /// - Parameter url: URL
    public init?(_ url: URL) {
        guard let components = URLComponents(string: url.absoluteString) else {
            return nil
        }
        self.components = components
    }
    
    /// URL.query 的字典形式，字典的值为 String? 或者 [String?] 类型
    public var keyedValues: [String: Any?]? {
        guard let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: Any?](), { (result, queryItem) in
            if let value = result[queryItem.name] {
                if let values = value as? [Any?] {
                    result[queryItem.name] = values + [queryItem.value]
                } else {
                    result[queryItem.name] = [value, queryItem.value]
                }
            } else {
                result.updateValue(queryItem.value, forKey: queryItem.name)
            }
        })
    }
    
    /// 设置字段的值，**同名已有字段会被覆盖**。
    /// - Parameters:
    ///   - value: query 字段值，可为 String? 或者 [String?] 类型。
    ///   - key: query 字段名。
    public mutating func setValue(_ value: Any?, forKey key: String) {
        var queryItems = components.queryItems ?? []
        setValue(value, forKey: key, queryItems: &queryItems)
        components.queryItems = queryItems
    }
    
    private func setValue(_ value: Any?, forKey key: String, queryItems: inout [URLQueryItem]) {
        var index = 0
        
        // 更新已有的。
        func setValue(_ value: Any?, forKey key: String, index: inout Int, queryItems: inout [URLQueryItem]) {
            while index < queryItems.count {
                if queryItems[index].name == key {
                    queryItems[index].value = String(casting: value)
                    break
                }
                index += 1
            }
            if index >= queryItems.count {
                queryItems.append(URLQueryItem(name: key, value: String(casting: value)))
            }
            index += 1
        }
        
        if let values = value as? [Any] {
            for value in values {
                setValue(value, forKey: key, index: &index, queryItems: &queryItems)
            }
        } else {
            setValue(value, forKey: key, index: &index, queryItems: &queryItems)
        }
        
        // 删除多余的。
        while index < queryItems.count {
            if queryItems[index].name == key {
                queryItems.remove(at: index)
            } else {
                index += 1;
            }
        }
    }
    
    /// 添加字段。
    /// - Parameters:
    ///   - value: query 字段值，可为 String? 或者 [String?] 类型。
    ///   - key: query 字段名。
    public mutating func addValue(_ value: Any?, forKey key: String) {
        var queryItems = components.queryItems ?? []
        addValue(value, forKey: key, queryItems: &queryItems)
        components.queryItems = queryItems
    }
    
    private func addValue(_ value: Any?, forKey key: String, queryItems: inout [URLQueryItem]) {
        if let values = value as? [Any] {
            for value in values {
                queryItems.append(URLQueryItem(name: key, value: String(casting: value)))
            }
        } else {
            queryItems.append(URLQueryItem(name: key, value: String(casting: value)))
        }
    }
    
    /// 获取字段值。
    /// - Parameter key: 字段名。
    /// - Returns: 字段值，为 String? 或者 [String?] 类型。
    public func value(forKey key: String) -> Any? {
        guard let queryItems = components.queryItems else {
            return nil
        }
        var result = [String?]()
        
        for queryItem in queryItems {
            if queryItem.name == key {
                result.append(queryItem.value)
            }
        }
        
        if result.count > 1 {
            return result
        }
        
        return result.first as? String
    }
    
    /// 移除指定字段名下的字段值。
    /// - Parameters:
    ///   - value: 字段值。
    ///   - key: 字段名。
    public mutating func removeValue(_ value: Any?, forKey key: String) {
        guard var queryItems = components.queryItems else {
            return
        }
        
        func removeValue(_ value: String?, forKey key: String, queryItems: inout [URLQueryItem]) {
            queryItems.removeAll(where: { (queryItem) -> Bool in
                return (queryItem.name == key && queryItem.value == value)
            })
        }
        
        if let values = value as? [Any] {
            for value in values {
                removeValue(String(casting: value), forKey: key, queryItems: &queryItems)
            }
        } else {
            removeValue(String(casting: value), forKey: key, queryItems: &queryItems)
        }
        
        components.queryItems = queryItems;
    }
    
    /// 移除指定字段名的所有字段。
    /// - Parameter key: 字段名。
    public mutating func removeValue(forKey key: String) {
        guard var queryItems = components.queryItems else {
            return
        }
        
        queryItems.removeAll(where: { (queryItem) -> Bool in
            return (queryItem.name == key)
        })
        
        components.queryItems = queryItems;
    }
    
    /// 移除所有字段。
    public mutating func removeAll() {
        components.queryItems = nil;
    }
    
    /// 是否包含指定字段。
    /// - Parameter key: 字段名。
    /// - Returns: 是否包含。
    public func contains(key: String) -> Bool {
        guard let queryItems = components.queryItems else {
            return false
        }
        return queryItems.contains(where: { (queryItem) -> Bool in
            return queryItem.name == key
        })
    }
    
    /// 添加字段，支持 String、[String: Any?]、[Any?] 类型。
    /// - Parameter value: 字段值（名）。
    public mutating func addValuesForKeys(from value: Any?) {
        guard let value = value else { return }
        var queryItems = components.queryItems ?? []
        
        if let keyedValues = value as? [String: Any?] {
            for item in keyedValues {
                addValue(item.value, forKey: item.key, queryItems: &queryItems)
            }
        } else if let values = value as? [Any] {
            for value in values {
                if let name = String(casting: value) {
                    addValue(nil, forKey: name, queryItems: &queryItems)
                }
            }
        } else if let name = String(casting: value) {
            addValue(nil, forKey: name, queryItems: &queryItems)
        }
        
        components.queryItems = queryItems
    }
    
    /// 更新字段，支持 String、[String: Any?]、[Any?] 类型，**同名字段将被覆盖**。
    /// - Parameter value: 字段值（名）。
    public mutating func updateValuesForKeys(from value: Any?) {
        guard let value = value else { return }
        var queryItems = components.queryItems ?? []
        
        if let keyedValues = value as? [String: Any?] {
            for item in keyedValues {
                setValue(item.value, forKey: item.key, queryItems: &queryItems)
            }
        } else if let values = value as? [Any] {
            for value in values {
                if let name = String(casting: value) {
                    setValue(nil, forKey: name, queryItems: &queryItems)
                }
            }
        } else if let name = String(casting: value) {
            setValue(nil, forKey: name, queryItems: &queryItems)
        }
        
        components.queryItems = queryItems
    }
    
    /// 添加字段，并生成新的 URLQueryComponent 对象，支持 String、[String: Any?]、[Any?] 类型。
    /// - Parameter value: 字段。
    /// - Returns: 新的 URLQueryComponent 对象。
    public func addingValuesForKeys(from value: Any?) -> URLQueryComponent {
        var queryComponent = self
        queryComponent.addValuesForKeys(from: value)
        return queryComponent
    }
    
    /// 更新字段，并生成新的 URLQueryComponent 对象，支持 String、[String: Any?]、[Any?] 类型，**同名字段将被覆盖**。
    /// - Parameter value: 字段。
    /// - Returns: 新的 URLQueryComponent 对象。
    public func updatingValuesForKeys(from value: Any?) -> URLQueryComponent {
        var queryComponent = self
        queryComponent.updateValuesForKeys(from: value)
        return queryComponent
    }
    
    public var description: String {
        return components.description
    }
}
