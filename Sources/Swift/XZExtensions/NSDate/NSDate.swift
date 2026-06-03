//
//  NSDate.swift
//  XZKit
//
//  Created by Xezun on 2025/6/23.
//

import Foundation

extension Date {
    
    /// 通过指定格式的日期字符串，构造 Date 对象。
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - dateFormat: 日期格式
    ///   - formatter: 格式化工具
    public init?(from string: String, using formatter: DateFormatter = .dateTime) {
        guard let date = formatter.date(from: string) else {
            return nil
        }
        self = date
    }
    
    /// 将当前日期对象，格式化为指定格式的日期字符串。
    /// - Parameters:
    ///   - dateFormat: 日期格式
    ///   - formatter: 格式化工具
    /// - Returns: 格式化的日期字符串
    public func formatted(using formatter: DateFormatter = .dateTime) -> String {
        return formatter.string(from: self)
    }
    
}

/// 描述时间日期格式的结构体枚举，该结构体可以用字符串字面量表示。
///
/// ### 日期格式字符及含义
/// - G： 纪念符号，公元 AD
/// - yyyy：年 2019
/// - Y：Week year
/// - MM：月
/// - dd：日
/// - hh：1~12小时制(1-12)
/// - HH：24小时制(0-23)
/// - mm：分
/// - ss：秒
/// - S：毫秒
/// - E：星期几
/// - D：一年中的第几天
/// - F：一月中的第几个星期(会把这个月总共过的天数除以7)
/// - w：一年中的第几个星期
/// - W：一月中的第几星期(会根据实际情况来算)
/// - a：上下午标识 AM/PM
/// - k：和HH差不多，表示一天24小时制(1-24)。
/// - K：和hh差不多，表示一天12小时制(0-11)。
/// - Z：表示时区 +0800
/// - z: 时区 PST GMT
/// - X: 时区 +08；+0800；+08:00
public struct XZDateFormatStyle: RawRepresentable, FormatStyle, Sendable {
    
    /// yyyy-MM-dd HH:mm:ss.SSS
    public static let msecDateTime    = XZDateFormatStyle(rawValue: "yyyy-MM-dd HH:mm:ss.SSS")
    /// yyyy-MM-dd HH:mm:ss
    public static let dateTime        = XZDateFormatStyle(rawValue: "yyyy-MM-dd HH:mm:ss")
    /// y-M-d H:m:s
    public static let shortDateTime   = XZDateFormatStyle(rawValue: "y-M-d H:m:s")
    /// yyyy-MM-dd
    public static let date            = XZDateFormatStyle(rawValue: "yyyy-MM-dd")
    /// y-M-d
    public static let shortDate       = XZDateFormatStyle(rawValue: "y-M-d")
    /// MM-dd
    public static let monthDay        = XZDateFormatStyle(rawValue: "MM-dd")
    /// M-d
    public static let shortMonthDay   = XZDateFormatStyle(rawValue: "M-d")
    /// HH:mm:ss
    public static let time            = XZDateFormatStyle(rawValue: "HH:mm:ss")
    /// H:m:s
    public static let shortTime       = XZDateFormatStyle(rawValue: "H:m:s")
    /// HH:mm
    public static let hourMinute      = XZDateFormatStyle(rawValue: "HH:mm")
    /// H:m
    public static let shortHourMinute = XZDateFormatStyle(rawValue: "H:m")
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        self.dateFormatter = DateFormatter.frozenDateFormatter(dateFormat: rawValue)
    }
    
    public typealias FormatInput = Date
    public typealias FormatOutput = String
    
    public let dateFormatter: DateFormatter
    
    public func format(_ value: Date) -> String {
        return dateFormatter.string(from: value)
    }
    
    public func locale(_ locale: Locale) -> XZDateFormatStyle {
        return self
    }
    
}

extension XZDateFormatStyle: ExpressibleByStringLiteral, CustomStringConvertible {
    
    public typealias RawValue = String
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    public var description: String {
        return rawValue
    }
    
}

extension DateFormatter {
    
    /// 直接使用日期格式字符串，创建日期格式化对象。
    /// - Parameter dateFormat: 日期格式
    public convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
    
    /// 使用 XZDateFormatStyle 枚举，创建日期格式化对象。
    /// - Parameter dateFormat: 日期格式枚举
    public convenience init(_ dateFormat: XZDateFormatStyle) {
        self.init()
        self.dateFormat = dateFormat.rawValue
    }
    
    /// 格式 yyyy-MM-dd HH:mm:ss.SSS 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let msecDateTime   = XZDateFormatStyle.msecDateTime.dateFormatter
    
    /// 格式 yyyy-MM-dd HH:mm:ss 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let dateTime        = XZDateFormatStyle.dateTime.dateFormatter
    
    /// 格式 y-M-d H:m:s 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let shortDateTime   = XZDateFormatStyle.shortDateTime.dateFormatter
    
    /// 格式 yyyy-MM-dd 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let date            = XZDateFormatStyle.date.dateFormatter
    
    /// 格式 y-M-d 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let shortDate       = XZDateFormatStyle.shortDate.dateFormatter
    
    /// 格式 MM-dd 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let monthDay        = XZDateFormatStyle.monthDay.dateFormatter
    
    /// 格式 M-d 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let shortMonthDay   = XZDateFormatStyle.shortMonthDay.dateFormatter
    
    /// 格式 HH:mm:ss 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let time            = XZDateFormatStyle.time.dateFormatter
    
    /// 格式 H:m:s 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let shortTime       = XZDateFormatStyle.shortTime.dateFormatter
    
    /// 格式 HH:mm 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let hourMinute      = XZDateFormatStyle.hourMinute.dateFormatter
    
    /// 格式 H:m 且不允许修改。
    ///
    /// - Attention: 该格式化对象的时区、日历等属性，保持系统默认，因为是单例，不建议动态修改。
    public static let shortHourMinute = XZDateFormatStyle.shortHourMinute.dateFormatter
    
    
}

extension DateFormatter {
    
    /// 创建一个不可修改 dateFormat 的 DateFormatter 对象。
    public static func frozenDateFormatter(dateFormat: String) -> DateFormatter {
        return XZFrozenDateFormatter.init(frozen: dateFormat)
    }
    
    private class XZFrozenDateFormatter: DateFormatter, @unchecked Sendable {
        
        public init(frozen dateFormat: String) {
            super.init();
            super.dateFormat = dateFormat
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var dateFormat: String! {
            get {
                return super.dateFormat
            }
            set {
                #if DEBUG
                fatalError("[XZKit] Changing dateFormat property is not allowed for this date formatter.");
                #endif
            }
        }
        
    }
    
}


