//
//  XZLogSystem.swift
//  XZLog
//
//  Created by 徐臻 on 2025/7/11.
//

import Foundation

// 为编译 XZLog 宏而提供。
public final class XZLogSystem: Sendable {
    public static let `default` = XZLogSystem.init()
}
