//
//  URL.swift
//  XZKit
//
//  Created by mlibai on 2017/5/3.
//
//

import Foundation

extension URL {
    
    /// URL 的查询字段。
    public var queryItems: [URLQueryItem]? {
        get {
            return URLComponents.init(string: self.absoluteString)?.queryItems
        }
        set {
            guard var components = URLComponents.init(string: self.absoluteString) else { return }
            components.queryItems = newValue
            guard let newURL = components.url else { return }
            self = newURL
        }
    }
    
    /// URL 的查询字段的字典形式。
    public var queryValues: [String: [String?]]? {
        guard var queryItems = self.queryItems, queryItems.count > 0 else { return nil }
        var queryValues = [String: [String?]]()
        
        while !queryItems.isEmpty {
            let queryItem = queryItems.removeLast()
            
            let queryKey = queryItem.name
            
            var queryValue = [queryItem.value]
            queryItems.removeAll(where: { (item) -> Bool in
                guard item.name == queryKey else {
                    return false
                }
                queryValue.append(item.value)
                return true
            })
            
            queryValues[queryKey] = queryValue;
        }
        return queryValues
    }
    
    /// 设置查询字段的值，该方法删除所有已设置的同名查询字段，然后再添加新的字段。
    /// - Note: 设置 nil 不会删除查询字段，请使用 remove 方法。
    ///
    /// - Parameters:
    ///   - value: 查询字段值。
    ///   - name: 查询字段名。
    public mutating func setQueryValue(_ queryValue: Any?, forKey queryKey: String) {
        var queryItems = self.queryItems?.filter({ $0.name != queryKey }) ?? []
        if let queryValue = queryValue {
            if let queryValues = queryValue as? [Any] {
                for queryValue in queryValues {
                    queryItems.append(.init(name: queryKey, value: String(queryValue)))
                }
            } else {
                queryItems.append(.init(name: queryKey, value: String(queryValue)))
            }
        } else {
            queryItems.append(URLQueryItem.init(name: queryKey, value: nil))
        }
        self.queryItems = queryItems
    }
    
    /// 添加一个查询字段。
    ///
    /// - Parameters:
    ///   - value: 查询字段值。
    ///   - name: 查询字段名。
    public mutating func addQueryValue(_ queryValue: Any?, forKey queryKey: String) {
        var queryItems = self.queryItems ?? []
        if let queryValue = queryValue {
            if let queryValues = queryValue as? [Any] {
                for queryValue in queryValues {
                    queryItems.append(.init(name: queryKey, value: String(queryValue)))
                }
            } else {
                queryItems.append(.init(name: queryKey, value: String(queryValue)))
            }
        } else {
            queryItems.append(URLQueryItem.init(name: queryKey, value: nil))
        }
        self.queryItems = queryItems
    }
    
    /// 获取 URL 中查询字段值，String? 或者 [String?]。
    ///
    /// - Parameter name: 查询字段名。
    /// - Returns: 查询字段值。
    public func queryValue(forKey name: String) -> [String?]? {
        guard let queryItems = self.queryItems else { return nil }
        
        var value: [String?]? = nil
        
        for queryItem in queryItems {
            guard queryItem.name == name else { continue }
            if value == nil {
                value = [queryItem.value]
            } else {
                value!.append(queryItem.value)
            }
        }

        return value
    }
    
    /// 移除指定查询字段。
    ///
    /// - Parameter name: 查询字段名。
    public mutating func removeQueryValue(forKey name: String) {
        guard let queryItems = self.queryItems else { return }
        self.queryItems = queryItems.filter({ (item) -> Bool in
            return item.name != name
        })
    }
    
    /// 判断 URL 的 Query 是否有某个查询字段。
    ///
    /// - Parameter name: 查询字段。
    /// - Returns: 是否包含。
    public func containsQueryValue(forKey name: String) -> Bool {
        guard let queryItems = self.queryItems else { return false }
        return queryItems.contains(where: { $0.name == name })
    }
    
    /// 将值添加到查询字符串中。
    /// - Note: 除字典、数组以外其它的值都将作为单个值。
    ///
    /// - Parameter keyedValues: 带添加的键值字典。
    public mutating func addQueryValues(from value: Any?) {
        self = self.addingQueryValues(from: value)
    }
    
    public func addingQueryValues(from value: Any?) -> URL {
        guard let value = value else { return self }
        
        var newQueryItems: [URLQueryItem]! = nil
        if let keyedValues = value as? [String: Any?] {
            newQueryItems = keyedValues.map { (item) -> URLQueryItem in
                return URLQueryItem.init(name: item.key, value: String.init(item.value))
            }
        } else if let values = value as? [Any] {
            for item in values {
                guard let aString = String.init(item) else { continue }
                if newQueryItems == nil {
                    newQueryItems = [URLQueryItem.init(name: aString, value: nil)]
                } else {
                    newQueryItems.append(URLQueryItem.init(name: aString, value: nil))
                }
            }
        } else if let aString = String.init(value) {
            newQueryItems = [URLQueryItem.init(name: aString, value: nil)]
        } else {
            return self
        }
        
        var urlComponents = URLComponents.init(string: self.absoluteString)!
        if let queryItems = urlComponents.queryItems {
            urlComponents.queryItems = queryItems + newQueryItems
        } else {
            urlComponents.queryItems = newQueryItems
        }
        
        return urlComponents.url!
    }
    
}










