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


extension SwiftSyntax.AttributeSyntax.Arguments {
    
    /// 获取宏参数个数，列表形式的参数个数。
    var count: Int {
        switch self {
        case .argumentList(let arguments):
            return arguments.count
        default:
            break
        }
        return 0
    }
    
    /// 宏参数列表的数组形式。
    var arrayRepresentation: [(label: String?, value: String, representedLiteralValue: String?)] {
        var macroArguments = [(String?, String, String?)]()
        
        switch self {
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
        
        return macroArguments
    }
    
    /// 第一个参数
    var first: (label: String?, value: String)? {
        switch self {
        case .argumentList(let arguments):
            guard let first = arguments.first else { return nil }
            return (first.label?.trimmedDescription, first.expression.trimmedDescription)
        default:
            return nil
        }
    }
    
}

extension SwiftSyntax.AttributeListSyntax {
    
    /// 获取当前声明的所有属性中，名称为 name 的属性。
    /// 比如获取属性所有 `@bind` 宏标记。
    /// - Parameter name: 宏名称
    /// - Returns: 宏
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


