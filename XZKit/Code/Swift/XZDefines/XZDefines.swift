//
//  XZDefines.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/16.
//

import Foundation

#if SWIFT_PACKAGE
@_exported import XZDefinesObjC
@freestanding(expression)
public macro LOG(_ message: String) = #externalMacro(module: "XZDefinesMacros", type: "XZDefinesLOGMacro")
#else
public func XZLog(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
    XZLogv(file, line, function, message)
    #endif
}
#endif
