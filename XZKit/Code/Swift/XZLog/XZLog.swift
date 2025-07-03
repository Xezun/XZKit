//
//  XZLog.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/16.
//

import Foundation

#if SWIFT_PACKAGE
@_exported import XZLogCore
@freestanding(expression)
public macro XZLog(_ message: String, in system: XZLogSystem? = nil) = #externalMacro(module: "XZLogMacros", type: "XZLogMacro")
#else
public func  XZLog(_ message: String, in system: XZLogSystem? = nil, file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
    XZLogv(system, file, line, function, message)
    #endif
}
#endif
