//
//  XZLogMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/16.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics
import Foundation

/// 宏 `XZLog(message)` 的实现。
public struct XZLogMacro: ExpressionMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
#if DEBUG
        var system = "XZLogSystem.default";
        
        var arguments = node.arguments;
        if arguments[arguments.startIndex].label?.text == "system" {
            if let expression = arguments[arguments.startIndex].expression.as(MemberAccessExprSyntax.self) {
                if expression.base == nil {
                    system = "XZLogSystem" + expression.trimmedDescription;
                } else {
                    system = expression.trimmedDescription
                }
            } else {
                system = arguments[arguments.startIndex].trimmedDescription
            }
            arguments.remove(at: arguments.startIndex)
        }
        
        let format = arguments[arguments.startIndex].trimmedDescription.trimmingCharacters(in: [",", "\""])
        arguments.remove(at: arguments.startIndex)
        
        if arguments.isEmpty {
            return "os_log(.debug, log: \(raw: system).oslog, \"%{public}@ \\n\(raw: format)\", XZLogs(\(raw: system), #file, #line, #function))"
        }
        return "os_log(.debug, log: \(raw: system).oslog, \"%{public}@ \\n\(raw: format)\", XZLogs(\(raw: system), #file, #line, #function), \(raw: arguments))"
#else
        return "os_log(.debug, log: .disabled, \"\")"
#endif
    }
    
}
