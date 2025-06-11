//
//  XZMocoaMacros.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/7.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

@main
struct XZMocoaMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        XZMocoaMacro.self,
        XZMocoaModuleMacro.self,
        XZMocoaKeyMacro.self,
        XZMocoaBindMacro.self
    ]
}

public enum XZMocoaMacroError: Error, CustomStringConvertible, DiagnosticMessage {
    
    public var message: String {
        switch self {
        case .message(let text):
            return text
        }
    }
    
    public var diagnosticID: SwiftDiagnostics.MessageID {
        switch self {
        case .message(let text):
            return .init(domain: "com.xezun.XZKit", id: text)
        }
    }
    
    public var severity: SwiftDiagnostics.DiagnosticSeverity {
        switch self {
        case .message(let text):
            return .warning
        }
    }
    
    case message(String)
    
    public var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
    
    
}
