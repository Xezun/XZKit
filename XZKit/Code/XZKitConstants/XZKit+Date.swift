//
//  Date+XZKit.swift
//  XZKit
//
//  Created by 徐臻 on 2019/3/27.
//  Copyright © 2019 mlibai. All rights reserved.
//

import Foundation

/// 描述时间日期格式的结构体，该结构体可以用字符串字面量表示。
/// - Note: 日期格式字符及含义：
/// ```swift
/// // yyyy：年
/// // MM：月
/// // dd：日
/// // hh：1~12小时制(1-12)
/// // HH：24小时制(0-23)
/// // mm：分
/// // ss：秒
/// // S：毫秒
/// // E：星期几
/// // D：一年中的第几天
/// // F：一月中的第几个星期(会把这个月总共过的天数除以7)
/// // w：一年中的第几个星期
/// // W：一月中的第几星期(会根据实际情况来算)
/// // a：上下午标识
/// // k：和HH差不多，表示一天24小时制(1-24)。
/// // K：和hh差不多，表示一天12小时制(0-11)。
/// // z：表示时区
/// ```
public struct DateFormat: RawRepresentable, ExpressibleByStringLiteral, Equatable {
    
    /// 标准日期时间格式，如 2016-09-13 13:02:46 。
    public static let dateTime        = DateFormat("yyyy.MM.dd HH:mm:ss");
    /// 短日期时间格式，如 2016-9-13 13:2:46 。
    public static let shortDateTime   = DateFormat("y.M.d H:m:s");
    /// 标准日期格式，如 2016-09-13 。
    public static let date            = DateFormat("yyyy.MM.dd");
    /// 短日期格式，如 2016-9-13 。
    public static let shortDate       = DateFormat("y.M.d");
    /// 标准日月格式，如 09-13 。
    public static let monthDay        = DateFormat("MM-dd");
    /// 短日月格式，如 9-13 。
    public static let shortMonthDay   = DateFormat("M-d");
    /// 标准时间格式，如 13:02:46 。
    public static let time            = DateFormat("HH:mm:ss");
    /// 短时间格式，如 13:2:46 。
    public static let shortTime       = DateFormat("H:m:s");
    /// 标准时分格式，如 13:02 。
    public static let hourMinute      = DateFormat("HH:mm");
    /// 短时分格式，如 13:2 。
    public static let shortHourMinute = DateFormat("H:m");
    
    public typealias RawValue = String
    public typealias StringLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    public init(unicodeScalarLiteral value: String) {
        self.rawValue = value
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.rawValue = value
    }
    
}

extension Date {
    
    /// 通过字符串构造一个日期。默认日期格式为 `DateFormat.standardDateTime` ，即标准的日期时间格式。
    /// ```swift
    /// // 标准时间格式
    /// let date1 = Date("2001-01-12 12:34:56")
    /// // 标准预定格式
    /// let date2 = Date("2012-12-20", format: .date)
    /// // 自定义日期格式
    /// let date3 = Date("2013/05/21", format: "yyyy/MM/dd")
    /// ```
    ///
    /// - Parameters:
    ///   - string: 指定格式的日期字符串。
    ///   - format: 日期的格式。
    public init?(_ string: String, format: DateFormat = DateFormat.dateTime) {
        DateFormatter.shared.dateFormat = format.rawValue
        guard let date = DateFormatter.shared.date(from: string) else { return nil }
        self = date
    }
    
    /// 按照指定格式生成，格式化后的日期字符串。
    ///
    /// - Parameter format: 日期格式。
    /// - Returns: 格式化后的日期字符串。
    public func formatted(with format: DateFormat = DateFormat.dateTime) -> String {
        DateFormatter.shared.dateFormat = format.rawValue
        return DateFormatter.shared.string(from: self)
    }
    
    /// 在用户当前日历下，获取日期中的年，如 2017-12-08 中的 2017 。
    public var year: Int {
        return Calendar.current.component(.year, from: self);
    }
    
    // 在用户当前日历下，获取日期中的月，如 2017-12-08 中的 12 。
    public var month: Int {
        return Calendar.current.component(.month, from: self);
    }
    
    // 在用户当前日历下，获取日期中的天，如 2017-12-08 中的 08 。
    public var day: Int {
        return Calendar.current.component(.day, from: self);
    }
    
    // 在用户当前日历下，获取日期所在周的次序，具体是星期几与周首设置有关。
    /// - 起始次序为 1 。
    public var dayOfWeek: Int {
        return Calendar.current.component(.weekday, from: self);
    }
    
    /// 在用户当前日历下，获取日期在其所在年份中是第几天。
    public var dayOfYear: Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: self)!
    }
    
    /// 在用户当前日历下，获取当前时间所在天的开始时间。
    public var startOfDay: Date {
        return Calendar.current.startOfDay(for: self);
    }
    
    /// 在用户当前日历下，获取当前月份的开始时间，如 2017-08-01 00:00:00 。
    public var startOfMonth: Date {
        let componets = Calendar.current.dateComponents([.year, .month], from: self);
        return Calendar.current.date(from: componets)!;
    }
    
    /// 在用户当前日历下，当前年份的的开始时间，比如今年是 2017 年，则表示的时间 2017-01-01 00:00:00 。
    public var startOfYear: Date {
        let componets = Calendar.current.dateComponents([.year], from: self);
        return Calendar.current.date(from: componets)!;
    }
    
    /// 在用户当前日历下，判断与另一日期是否是同一天。
    ///
    /// - Parameter date: 待比较的日期
    /// - Returns: 是否是同一天
    public func isInSameDay(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day);
    }
    
    /// 在用户当前日历下，判断与另一日期是否是同一周。
    ///
    /// - Parameter date: 待比较的日期
    /// - Returns: 是否是同一天
    public func isInSameWeek(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear);
    }
    
    /// 在用户当前日历下，判断与另一日期是否是同一月。
    ///
    /// - Parameter date: 待比较的日期
    /// - Returns: 是否是同一天
    public func isInSameMonth(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month);
    }
    
    /// 在用户当前日历下，判断与另一日期是否是同一年。
    ///
    /// - Parameter date: 待比较的日期
    /// - Returns: 是否是同一天
    public func isInSameYear(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year);
    }
    
    /// 把当前日期按指定日历单位进行加法运算。
    ///
    /// - Parameters:
    ///   - component: 要进行计算的日历单位
    ///   - value: 要增加的值
    /// - Returns: 计算结果
    public func adding(_ component: Calendar.Component, value: Int) -> Date {
        return  Calendar.current.date(byAdding: component, value: value, to: self)!
    }
    
}

extension DateFormatter {
    
    private struct AssociationKey {
        static var sharedFormatter = 0
    }
    
    /// 获取当前线程共享的 DateFormatter ，因此请不要在 A 线程内获取然后在 B 线程内使用。
    public static var shared: DateFormatter {
        let thread = Thread.current
        if let sharedFormatter = objc_getAssociatedObject(thread, &AssociationKey.sharedFormatter) as? DateFormatter {
            return sharedFormatter
        }
        let sharedFormatter = DateFormatter.init()
        objc_setAssociatedObject(thread, &AssociationKey.sharedFormatter, sharedFormatter, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return sharedFormatter
    }
    
}

extension String {
    
    /// 将日期按照指定格式，格式化成字符串。
    ///
    /// - Parameters:
    ///   - date: 待格式化的日期。
    ///   - format: 日期格式。
    public init(date: Date, format: DateFormat = .dateTime) {
        self = date.formatted(with: format)
    }
    
}

extension NSString {
    
    /// 格式化日期。
    ///
    /// - Parameters:
    ///   - date: 日期。
    ///   - format: 日期格式。
    @objc(xz_stringWithDate:format:)
    public convenience init(date: Date, format: String) {
        self.init(string: String.init(date: date, format: DateFormat.init(format)))
    }
    
}
