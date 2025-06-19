//
//  XZDefines.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/16.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

@main
struct XZMocoaMacros: CompilerPlugin {
    
    var providingMacros: [Macro.Type] = [
        XZDefinesLogMacro.self
    ]
    
}


/// 宏 `XZLog(message)` 的实现。
public struct XZDefinesLogMacro: ExpressionMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard node.arguments.count == 1 else {
            throw XZDefinesMacroError.message("#XZLog: 只支持一个参数")
        }
        
        let message = node.arguments[node.arguments.startIndex].expression
        
#if DEBUG
        return """
            XZLogv(#file, #line, #function, \(raw: message.trimmedDescription))
        """
        
#else
        return "while false { }"
#endif
        
    }
    
}


private enum XZDefinesMacroError: Error, CustomStringConvertible {
    
    case message(String)
    
    public var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
    
}
