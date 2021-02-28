//
//  XZKitDEBUG.swift
//  XZKit
//
//  Created by Xezun on 2021/2/28.
//

import Foundation

/// 标识当前是否处于调试模式。
public let isDebugMode = ProcessInfo.processInfo.arguments.contains("-XZKitDEBUG")
