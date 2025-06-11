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

public enum XZMocoaMacroError: Error, CustomStringConvertible {
    
    case message(String)
    
    public var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
    
    
}

public struct XZMocoaMacroDiagnosticMessage: DiagnosticMessage {
    
    public let message: String
    
    public var diagnosticID: SwiftDiagnostics.MessageID {
        return .init(domain: "com.xezun.XZKit", id: "XZMocoa")
    }
    
    public let severity: SwiftDiagnostics.DiagnosticSeverity
}
