//
//  APIMethod.swift
//  XZKit
//
//  Created by Xezun on 2018/2/27.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

extension APIMethod {
    
    /// HTTP GET 请求。
    public static let GET     = APIMethod.init(rawValue: "GET")
    /// HTTP POST 请求。
    public static let POST    = APIMethod.init(rawValue: "POST")
    /// HTTP HEAD 请求。
    public static let HEAD    = APIMethod.init(rawValue: "HEAD")
    /// HTTP PUT 请求。
    public static let PUT     = APIMethod.init(rawValue: "PUT")
    /// HTTP DELETE 请求。
    public static let DELETE  = APIMethod.init(rawValue: "DELETE")
    /// HTTP TRACE 请求。
    public static let TRACE   = APIMethod.init(rawValue: "TRACE")
    /// HTTP CONNECT 请求。
    public static let CONNECT = APIMethod.init(rawValue: "CONNECT")
    
}


/// HTTP 请求方法。
public struct APIMethod: RawRepresentable, Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
    
    public typealias RawValue = String
    
    /// 一般情况下，原始值即为 HTTP 请求方法名。
    public let rawValue: String
    
    /// 构造 APIMethod 。
    /// - Note: 建议使用 HTTP 请求方法名作为原始值。
    ///
    /// - Parameter rawValue: HTTP 请求方法名
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// 返回原始值的 hashValue 。
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    /// 比较两个 APIMethod 是否为同一个。
    public static func ==(lhs: APIMethod, rhs: APIMethod) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    /// 输出 APIMethod 的原始值。
    public var description: String {
        return rawValue
    }
    
    public typealias StringLiteralType = String
    
    /// 提供了通过字符串字面量构造 APIMethod 的方式。
    ///
    /// - Parameter value: HTTP 请求方式名。
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

