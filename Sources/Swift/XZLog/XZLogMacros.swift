//
//  XZLogMacros.swift
//  XZKit
//
//  Created by Xezun on 2025/7/11.
//

import Foundation
#if SWIFT_PACKAGE
import XZKitObjC
import OSLog

@freestanding(expression)
public macro XZLog(type: OSLogType = .debug, system: XZLogSystem = .default, _ format: StaticString, _ arguments: Any?...) = #externalMacro(module: "XZKitMacros", type: "XZLogMacro")

#endif
