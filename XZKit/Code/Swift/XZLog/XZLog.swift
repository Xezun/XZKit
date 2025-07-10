//
//  XZLog.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/16.
//

import Foundation

@freestanding(expression)
public macro XZLog(_ message: String, in system: XZLogSystem = .default) = #externalMacro(module: "XZLogMacros", type: "XZLogMacro")
#if SWIFT_PACKAGE
@_exported import _XZKitObjC

#else
public func  XZLog(_ message: String, in system: XZLogSystem = .default, file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
    XZLogs(system, file, line, function, message)
    #endif
}
#endif
