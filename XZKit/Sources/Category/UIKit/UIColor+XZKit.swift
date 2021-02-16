//
//  UIColor+XZKit.swift
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

import Foundation

extension XZColor: ExpressibleByIntegerLiteral, RawRepresentable {
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.init(rawValue: value)
    }
    
    public typealias RawValue = Int
    
    public var rawValue: Int {
        return alpha + (blue << 8) + (green << 16) + (red << 24);
    }
    
    public init(rawValue: Int) {
        let r = (rawValue >> 24) & 0xFF;
        let g = (rawValue >> 16) & 0xFF;
        let b = (rawValue >>  8) & 0xFF;
        let a = (rawValue >>  0) & 0xFF;
        self.init(red: r, green: g, blue: b, alpha: a);
    }
    
    public var uiColor: UIColor {
        return UIColor(self)
    }
    
}


extension Int {
    
    public init(_ color: XZColor) {
        self = color.rawValue
    }
    
}

/// 通过字符串形式 RGBA 值构造 UIColor 对象。
/// - Parameter string: 十六进制颜色字符串，如 #A1B2C3FF
/// - Returns: UIColr
public func rgba(_ string: String) -> UIColor {
    let color = XZColor.init(string)
    return rgba(color.red, color.green, color.blue, color.alpha)
}

/// 通过整数形式的 RGBA 值构造 UIColor 对象。
/// - Parameter value: 十六进制 RGBA 颜色值，如 0xFF0000FF
/// - Returns: UIColor
public func rgba(_ value: Int) -> UIColor {
    let r = CGFloat((value >> 24) & 0xFF) / 255.0
    let g = CGFloat((value >> 16) & 0xFF) / 255.0
    let b = CGFloat((value >>  8) & 0xFF) / 255.0
    let a = CGFloat((value >>  0) & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
}

/// 通过 RGBA 值 [0, 255] 构造 UIColor 对象。
public func rgba(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Int) -> UIColor {
    let r = CGFloat(red)   / 255.0
    let g = CGFloat(green) / 255.0
    let b = CGFloat(blue)  / 255.0
    let a = CGFloat(alpha) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
}

/// 通过 RGBA 值 [0, 1.0] 构造 UIColor 对象。
public func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

/// 通过字符串形式 RGB 值构造 UIColor 对象。
/// - Parameter string: 十六进制颜色字符串，如 #A1B2C3FF
/// - Returns: UIColr
public func rgb(_ string: String) -> UIColor {
    let color = XZColor.init(string)
    return rgb(color.red, color.green, color.blue)
}

/// 通过整数形式的 RGB 值构造 UIColor 对象。
/// - Parameter value: 十六进制 RGBA 颜色值，如 0xFF0000
/// - Returns: UIColor
public func rgb(_ value: Int) -> UIColor {
    let r = value >> 16
    let g = value >> 8
    let b = value
    return rgba(r&0xFF, g&0xFF, b&0xFF, 255)
}

/// 通过 RGB 值 [0, 255] 构造 UIColor 对象。
public func rgb(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
    return rgba(red, green, blue, 255)
}

/// 通过 RGB 值 [0, 1.0] 构造 UIColor 对象。
public func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return rgba(red, green, blue, 255)
}


