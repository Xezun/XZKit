//
//  Date.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/23.
//

import Foundation

extension String {
    
    /// 描述时间日期格式的结构体，该结构体可以用字符串字面量表示。
    /// - Note: 日期格式字符及含义：
    /// ```swift
    /// // G： 纪念符号，公元 AD
    /// // yyyy：年 2019
    /// // Y：Week year
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
    /// // a：上下午标识 AM/PM
    /// // k：和HH差不多，表示一天24小时制(1-24)。
    /// // K：和hh差不多，表示一天12小时制(0-11)。
    /// // Z：表示时区 +0800
    /// // z: 时区 PST GMT
    /// // X: 时区 +08；+0800；+08:00
    /// ```
    public static let DateFormat = (
        /// yyyy-MM-dd HH:mm:ss
        dateTime        : "yyyy-MM-dd HH:mm:ss",
        /// y-M-d H:m:s
        shortDateTime   : "y-M-d H:m:s",
        /// yyyy-MM-dd
        date            : "yyyy-MM-dd",
        /// y-M-d
        shortDate       : "y-M-d",
        /// MM-dd
        monthDay        : "MM-dd",
        /// M-d
        shortMonthDay   : "M-d",
        /// HH:mm:ss
        time            : "HH:mm:ss",
        /// H:m:s
        shortTime       : "H:m:s",
        /// HH:mm
        hourMinute      : "HH:mm",
        /// H:m
        shortHourMinute : "H:m"
    )
    
    
}
