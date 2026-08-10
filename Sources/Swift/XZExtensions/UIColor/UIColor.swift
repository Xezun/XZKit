//
//  UIColor.swift
//  XZKit
//
//  Created by 徐臻 on 2026/8/11.
//

import UIKit
import XZKitObjC

extension XZColor: RawRepresentable {
    
    public typealias RawValue = UInt32
    
    public var rawValue: UInt32 {
        return __UInt32FromXZColor(self)
    }
    
    public init(rawValue: UInt32) {
        let r = (rawValue & 0xFF000000) >> 24
        let g = (rawValue & 0x00FF0000) >> 16
        let b = (rawValue & 0x0000FF00) >> 8
        let a = (rawValue & 0x000000FF)
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    public init(_ rawValue: UInt32) {
        self.init(rawValue: rawValue)
    }
    
    public init?(_ rawValue: String) {
        var error: OSStatus = 0
        let color = __XZColorFromString(rawValue, &error)
        if error != noErr {
            return nil
        }
        self = color
    }
    
}


extension XZColor: CustomStringConvertible {
    
    public var description: String {
        return __NSStringFromXZColor(self)
    }
}
