//
//  XZToast.swift
//  ChatGPT
//
//  Created by Xezun on 2023/12/11.
//

import UIKit
import XZGeometry
import XZTextImageView

#if SWIFT_PACKAGE
import XZToastObjC
#endif

extension XZToast.Position: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .top:
            return "top"
        case .middle:
            return "middle"
        case .bottom:
            return "bottom"
        @unknown default:
            return "unknown"
        }
    }
    
}

extension XZToast {
    
    /// 通过 view 构造 XZToast 对象。
    /// - Parameter view: 呈现提示的视图
    /// - Returns: XZToast 对象
    @objc public class func view(_ view: UIView) -> Self {
        return Self.init(view: view)
    }
    
    /// 构造表示文本消息的 XZToast 对象。
    /// - Parameter text: 待呈现的文本内容
    /// - Returns: XZToast 对象
    @objc public class func message(_ text: String) -> Self {
        return Self.init(message: text)
    }
    
    /// 构造表示加载过程的 XZToast 对象。
    /// - Parameter text: 加载过程的描述文案
    /// - Returns: XZToast 对象
    @objc public static func loading(_ text: String) -> Self {
        return Self.init(loading: text)
    }
}

extension XZToast: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    /// 实现字符字面量构造 `XZToast` 的方法，实际调用 `init(message:)` 方法的便利方法。
    public required convenience init(stringLiteral value: String) {
        self.init(message: value)
    }
    
}

private let successImageData = """
PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/PjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTV
kcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+PHN2ZyB0PSIxNz
QwOTgyNjI2MDcxIiBjbGFzcz0iaWNvbiIgdmlld0JveD0iMCAwIDEwMjQgMTAyNCIgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR
0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHAtaWQ9IjEwMjA1IiB3aWR0aD0iMTUwIiBoZWlnaHQ9IjE1MCIgeG1sbnM6eGxp
bms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPjxwYXRoIGQ9Ik01MDguMzU2ODU1IDc0Ljk2NTg5MWMtMjU2LjMzM
DAzMiAwLTQ2NC4xMzI1NTYgMjA3Ljc5MjI5MS00NjQuMTMyNTU2IDQ2NC4xMzI1NTYgMCAyNTYuMzMwMDMyIDIwNy44MDI1Mj
QgNDY0LjEzMjU1NiA0NjQuMTMyNTU2IDQ2NC4xMzI1NTYgMjU2LjM0MDI2NiAwIDQ2NC4xMzI1NTYtMjA3LjgwMjUyNCA0NjQ
uMTMyNTU2LTQ2NC4xMzI1NTZDOTcyLjQ4OTQxMiAyODIuNzU4MTgyIDc2NC42OTcxMjEgNzQuOTY1ODkxIDUwOC4zNTY4NTUg
NzQuOTY1ODkxek04MDcuMzE5ODY4IDM2Ny41NzM4NjhjMCAwLTIyOS45OTkxMDEgMTM2LjY3OTMzMi0zNzkuNDgwNjA3IDM4N
S45Mzc5NzktNzMuNDA1Mjc1LTEwOC4xMzc5NTMtMTc0LjIwNTc3LTIwMS4yMDE4ODMtMTc0LjIwNTc3LTIwMS4yMDE4ODNzLT
MuNDU4OTQxLTc5Ljg1MjQxMyA0OC4xMDc5MzItNTQuOTEzMjQ1YzAgMCA0MS4yNDEyMTggMTcuMTMwOTY3IDExMi40NjY3NDY
gODUuODM5MDQxIDIwOC43MzM3NzgtMTg2LjE4OTI2MSAzNzEuOTQ4NzEyLTI1NC43ODQ3NjYgMzcxLjk0ODcxMi0yNTQuNzg0
NzY2QzgyNi4yMTEwMDcgMzA4LjMyMTU5NyA4MDcuMzE5ODY4IDM2Ny41NzM4NjggODA3LjMxOTg2OCAzNjcuNTczODY4eiIgZ
mlsbD0iI2ZmZmZmZiIgcC1pZD0iMTAyMDYiPjwvcGF0aD48L3N2Zz4=
""";

private let failureImageData = """
PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/PjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTV
kcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+PHN2ZyB0PSIxNz
QxMDA1NjY5NzI3IiBjbGFzcz0iaWNvbiIgdmlld0JveD0iMCAwIDEwMjQgMTAyNCIgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR
0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHAtaWQ9IjIwMzAiIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5
L3hsaW5rIiB3aWR0aD0iMTUwIiBoZWlnaHQ9IjE1MCI+PHBhdGggZD0iTTUxMS4wNzA4MzggNzAuMjA5MDM4Yy0yNDQuMTQzN
DYzIDAtNDQyLjA3MDMyNCAxOTcuOTI2ODYyLTQ0Mi4wNzAzMjQgNDQyLjA3MDMyNHMxOTcuOTI2ODYyIDQ0Mi4wNzAzMjQgND
QyLjA3MDMyNCA0NDIuMDcwMzI0IDQ0Mi4wNzAzMjQtMTk3LjkyNjg2MiA0NDIuMDcwMzI0LTQ0Mi4wNzAzMjRTNzU1LjIxNTM
yNCA3MC4yMDkwMzggNTExLjA3MDgzOCA3MC4yMDkwMzh6TTcwNi4xOTY5MSA1NzEuNzg2NjY1IDMxNS45NDU3ODkgNTcxLjc4
NjY2NWMtMzIuODY5NjE4IDAtNTkuNTA2Mjc5LTI2LjY2NjMzNi01OS41MDYyNzktNTkuNTA2Mjc5IDAtMzIuODY4NTk1IDI2L
jYzNzY4NC01OS41MzQ5MzEgNTkuNTA2Mjc5LTU5LjUzNDkzMWwzOTAuMjUyMTQ1IDBjMzIuODY5NjE4IDAgNTkuNTA2Mjc5ID
I2LjY2NjMzNiA1OS41MDYyNzkgNTkuNTM0OTMxUzczOS4wOTUxODEgNTcxLjc4NjY2NSA3MDYuMTk2OTEgNTcxLjc4NjY2NXo
iIHAtaWQ9IjIwMzEiIGZpbGw9IiNmZmZmZmYiPjwvcGF0aD48L3N2Zz4=
"""

