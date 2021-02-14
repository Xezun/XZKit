//
//  UIColor+XZKit.swift
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

import Foundation

extension Color: ExpressibleByIntegerLiteral, RawRepresentable {
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.init(value);
    }
    
    public typealias RawValue = Int
    
    public var rawValue: Int {
        return __NSIntegerFromXZRGBA(self)
    }
    
    public init(rawValue: Int) {
        self.init(rawValue)
    }
    
}


extension Int {
    
    public init(_ color: Color) {
        self = __NSIntegerFromXZRGBA(color)
    }
    
}
