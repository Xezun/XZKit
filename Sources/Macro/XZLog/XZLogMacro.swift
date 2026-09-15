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
        var system = ".default";
        var type   = ".debug"
        
        var arguments = node.arguments;
        
        if arguments[arguments.startIndex].label?.text == "type" {
            type = arguments[arguments.startIndex].expression.trimmedDescription;
            arguments.remove(at: arguments.startIndex)
            
            if arguments[arguments.startIndex].label?.text == "system" {
                system = arguments[arguments.startIndex].expression.trimmedDescription
                arguments.remove(at: arguments.startIndex)
            }
        } else if arguments[arguments.startIndex].label?.text == "system" {
            system = arguments[arguments.startIndex].expression.trimmedDescription
            arguments.remove(at: arguments.startIndex)
        }
        
        let format = arguments[arguments.startIndex].trimmedDescription.trimmingCharacters(in: [",", "\""])
        arguments.remove(at: arguments.startIndex)
        
        if arguments.isEmpty {
            return """
            ({ 
                let __xz_log_system__ : XZLogSystem = \(raw: system)
                guard __xz_log_system__.isEnabled else { return }
                for message in XZLogs(__xz_log_system__, #file, #line, #function, "\(raw: format)") { 
                    os_log(\(raw: type), log: __xz_log_system__.oslog, "%@", message) 
                } 
            })()
            """
        }
        
        return """
        ({ 
            let __xz_log_system__ : XZLogSystem = \(raw: system)
            guard __xz_log_system__.isEnabled else { return }
            let __xz_log_message__ = String(formal: "\(raw: format)", \(raw: arguments))
            for __xz_log_text__ in XZLogs(__xz_log_system__, #file, #line, #function, __xz_log_message__) { 
                os_log(\(raw: type), log: __xz_log_system__.oslog, "%@", __xz_log_text__) 
            } 
        })()
        """
#else
        return "os_log(.debug, log: .disabled, \"\")"
#endif
    }
    
}
