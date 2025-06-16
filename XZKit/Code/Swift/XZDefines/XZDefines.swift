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
public macro XZLog(_ message: String) = #externalMacro(module: "XZDefinesMacros", type: "XZDefinesLogMacro")
#endif
