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

public enum XZMocoaRole: String {
    case m
    case v
    case vm
}

@main
struct XZMocoaMacros: CompilerPlugin {
    
    var providingMacros: [Macro.Type] = [
        XZMocoaMacro.self,
        XZMocoaModuleMacro.self,
        XZMocoaKeyMacro.self,
        XZMocoaBindMacro.self,
        XZMocoaBindViewMacro.self,
        XZMocoaReadyMacro.self
    ]
    
}

private enum XZMocoaMacroError: Error, CustomStringConvertible {
    
    case message(String)
    
    public var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
    
}

private struct XZMocoaMacroDiagnosticMessage: DiagnosticMessage {
    
    public let message: String
    
    public var diagnosticID: SwiftDiagnostics.MessageID {
        return .init(domain: "com.xezun.XZKit", id: "XZMocoa")
    }
    
    public let severity: SwiftDiagnostics.DiagnosticSeverity
    
}

func Message(_ message: String) -> Error {
    return XZMocoaMacroError.message(message)
}

func Message(_ message: String, severity: SwiftDiagnostics.DiagnosticSeverity) -> any DiagnosticMessage {
    return XZMocoaMacroDiagnosticMessage.init(message: message, severity: severity)
}

func Message(_ error: Error, severity: SwiftDiagnostics.DiagnosticSeverity) -> any DiagnosticMessage {
    if case let .message(message) = (error as? XZMocoaMacroError) {
        return Message(message, severity: severity)
    }
    return Message("出现未知错误", severity: .error)
}



extension SwiftSyntax.AttributeSyntax {
    
    var argumentsArray: [(label: String?, value: String, representedLiteralValue: String?)] {
        
        var macroArguments = [(String?, String, String?)]()
        if let arguments = self.arguments {
            switch arguments {
            case .argumentList(let arguments):
                for argument in arguments {
                    let label = argument.label?.trimmedDescription;
                    let value = argument.expression.trimmedDescription
                    let key = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
                    macroArguments.append((label, value, key))
                }
            default:
                break
            }
        }
        
        return macroArguments
    }
    
    var firstArgument: (label: String?, value: String)? {
        guard let arguments = self.arguments else { return nil }
        switch arguments {
        case .argumentList(let arguments):
            guard let first = arguments.first else { return nil }
            return (first.label?.trimmedDescription, first.expression.trimmedDescription)
        default:
            return nil
        }
    }
    
}

extension SwiftSyntax.AttributeListSyntax {
    
    func attributes(forName name: String) -> [AttributeSyntax] {
        var results = [AttributeSyntax]()
        for attribute in self {
            switch attribute {
            case .attribute(let attributeSyntax):
                if attributeSyntax.attributeName.trimmedDescription == name {
                    results.append(attributeSyntax)
                }
            case .ifConfigDecl:
                break
            }
        }
        return results
    }
    
}


public struct XZMocoaReadyMacro: BodyMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingBodyFor declaration: some SwiftSyntax.DeclSyntaxProtocol & SwiftSyntax.WithOptionalCodeBlockSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            throw Message("@ready: 仅可用于方法")
        }
        guard declaration.signature.parameterClause.parameters.count == 0 else {
            throw Message("@ready: 初始化方法没有参数")
        }
        
        guard declaration.modifiers.contains(where: { $0.name.text == "private" }) else {
            throw Message("@ready: 初始化方法必须使用 private 标记")
        }
        
        return []
    }
    
}
