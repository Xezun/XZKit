//
//  RAPIMethod.swift
//  XZKit
//
//  Created by Xezun on 2020/6/29.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

extension RAPIMethod {
    
    public static let GET: RAPIMethod     = "GET"
    
    public static let POST: RAPIMethod    = "POST"
    
    public static let HEAD: RAPIMethod    = "HEAD"
    
    public static let PUT: RAPIMethod     = "PUT"
    
    public static let DELETE: RAPIMethod  = "DELETE"
    
    public static let TRACE: RAPIMethod   = "TRACE"
    
    public static let CONNECT: RAPIMethod = "CONNECT"
    
}


/// RAPI 请求方式。
public struct RAPIMethod: RawRepresentable, Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
    
    public typealias RawValue = String
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public static func ==(lhs: RAPIMethod, rhs: RAPIMethod) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public var description: String {
        return rawValue
    }
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
