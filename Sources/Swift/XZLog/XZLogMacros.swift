//
//  XZLogMacros.swift
//  XZKit
//
//  Created by Xezun on 2025/7/11.
//

import Foundation

@freestanding(expression)
public macro XZLog(system: XZLogSystem = .default, _ format: StaticString, _ arguments: any CVarArg...) = #externalMacro(module: "XZKitMacros", type: "XZLogMacro")
