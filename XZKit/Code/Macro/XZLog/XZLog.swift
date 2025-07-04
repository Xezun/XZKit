//
//  XZLog.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/16.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

@main
struct XZDefinesMacros: CompilerPlugin {
    
    var providingMacros: [Macro.Type] = [
        XZLogMacro.self
    ]
    
}

/// 宏 `XZLog(message)` 的实现。
public struct XZLogMacro: ExpressionMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
#if DEBUG
        switch node.arguments.count {
        case 1:
            let message = node.arguments[node.arguments.startIndex].expression
            return """
                XZLogs(XZLogSystem.default, #file, #line, #function, \(raw: message.trimmedDescription))
            """
        case 2:
            let message = node.arguments[node.arguments.startIndex].expression
            let system  = node.arguments[node.arguments.index(after: node.arguments.startIndex)].expression
            return """
                XZLogs(\(raw: system.trimmedDescription), #file, #line, #function, \(raw: message.trimmedDescription))
            """
        default:
            throw XZLogMacroError.message("#XZLog: 只支持一个参数")
        }
#else
        return "while false { }"
#endif
    }
    
}


private enum XZLogMacroError: Error, CustomStringConvertible {
    
    case message(String)
    
    public var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
    
}
