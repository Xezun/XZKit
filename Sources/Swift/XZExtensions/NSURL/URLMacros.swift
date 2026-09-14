//
//  NSURL.swift
//  XZKit
//
//  Created by 徐臻 on 2026/7/25.
//

import Foundation

#if SWIFT_PACKAGE
@freestanding(expression)
public macro URL(_ string: String) -> URL = #externalMacro(module: "XZKitMacros", type: "URLMacro")
#endif
