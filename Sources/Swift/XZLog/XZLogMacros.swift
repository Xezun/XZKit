//
//  XZLogMacros.swift
//  XZKit
//
//  Created by Xezun on 2025/7/11.
//

import Foundation

@freestanding(expression)
public macro XZLog(_ message: String, in system: XZLogSystem = .default) = #externalMacro(module: "XZKitMacros", type: "XZLogMacro")
