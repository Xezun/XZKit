//
//  XZKitMacros.swift
//  XZKit
//
//  Created by Xezun on 2025/7/11.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

@main
struct XZKitMacros: CompilerPlugin {
    
    let providingMacros: [Macro.Type] = [
        // XZLog
        XZLogMacro.self,
        // XZMocoa
        XZMocoaMacro.self,
        XZMocoaModuleMacro.self,
        XZMocoaKeyMacro.self,
        XZMocoaBindMacro.self,
        XZMocoaBindViewMacro.self,
        XZMocoaPrepareMacro.self
    ]
    
}

/// XZKitMacros 抛出的错误类型。
public enum XZMacroError: Error, CustomStringConvertible {
    
    case message(String)
    
    public var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
    
    public init(message: String) {
        self = .message(message)
    }
    
}

/// XZKitMacros 诊断消息。
public struct XZMacroDiagnosticMessage: DiagnosticMessage {
    
    public let message: String
    
    public var diagnosticID: SwiftDiagnostics.MessageID {
        return .init(domain: "com.xezun.XZKit", id: "XZKitMacros")
    }
    
    public let severity: SwiftDiagnostics.DiagnosticSeverity
    
    public init(message: String, severity: SwiftDiagnostics.DiagnosticSeverity) {
        self.message = message
        self.severity = severity
    }
    
    public init(error: Error, severity: SwiftDiagnostics.DiagnosticSeverity) {
        if case let .message(message) = (error as? XZMacroError) {
            self.init(message: message, severity: severity)
        } else {
            self.init(message: "未知错误", severity: .error)
        }
    }
    
}

/// 输出普通诊断信息。
public func XZMacroDiagnose(_ context: some SwiftSyntaxMacros.MacroExpansionContext, node: some SwiftSyntax.SyntaxProtocol, message: String, severity: SwiftDiagnostics.DiagnosticSeverity, fixIt: FixIt? = nil) {
    let diagnosticMessage = XZMacroDiagnosticMessage.init(message: message, severity: severity);
    if let fixIt = fixIt {
        context.diagnose(.init(node: node, message: diagnosticMessage, fixIt: fixIt))
    } else {
        context.diagnose(.init(node: node, message: diagnosticMessage))
    }
}

/// 输出错误诊断信息。
public func XZMacroDiagnose(_ context: some SwiftSyntaxMacros.MacroExpansionContext, node: some SwiftSyntax.SyntaxProtocol, error: Error, severity: SwiftDiagnostics.DiagnosticSeverity, fixIt: FixIt? = nil) {
    let diagnosticMessage = XZMacroDiagnosticMessage.init(error: error, severity: severity);
    if let fixIt = fixIt {
        context.diagnose(.init(node: node, message: diagnosticMessage, fixIt: fixIt))
    } else {
        context.diagnose(.init(node: node, message: diagnosticMessage))
    }
}

extension SwiftSyntax.AttributeSyntax.Arguments {
    
    /// 获取宏参数个数，列表形式的参数个数。
    public var count: Int {
        switch self {
        case .argumentList(let arguments):
            return arguments.count
        default:
            break
        }
        return 0
    }
    
    /// 宏参数列表的数组形式。
    public var arrayRepresentation: [(label: String?, value: String, representedLiteralValue: String?)] {
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
    public var first: (label: String?, value: SwiftSyntax.LabeledExprSyntax)? {
        switch self {
        case .argumentList(let arguments):
            guard let first = arguments.first else { return nil }
            return (first.label?.trimmedDescription, first)
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
    public func attributes(forName name: String) -> [AttributeSyntax] {
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

extension VariableDeclSyntax {
    
    /// 是否为只读属性。
   public var isReadyOnlyProperty: Bool {
        if self.bindings.count != 1 {
            return false
        }
        
        let expression = self.bindings[self.bindings.startIndex]
        
        if let block = expression.accessorBlock {
            switch block.accessors {
            case .accessors(let list):
                if list.count == 1 {
                    // 只有一个 get 访问点
                    return list.first!.accessorSpecifier.tokenKind == .keyword(.get)
                }
                return list.count == 1
            case .getter:
                return true
            }
        }
        
        return false
    }
    
    /// 判断属性是否包含指定修饰符。
    public func contains(modifier: Keyword) -> Bool {
        return self.modifiers.contains(where: { $0.name.tokenKind == .keyword(modifier) })
    }
    
    /// 判断属性是否包含指定属性。
    ///
    /// 比如`@objc`属性，使用`objc`作为参数。
    public func contains(attribute name: String) -> Bool {
        return self.attributes.contains { attribute in
            if case let .attribute(macroNode) = attribute {
                return macroNode.attributeName.trimmedDescription == name
            }
            return false
        }
    }
    
}

extension ClassDeclSyntax {
    
    /// class 继承的类型。
    public var inheritedTypes: [String] {
        guard let inheritedTypes = self.inheritanceClause?.inheritedTypes else {
            return []
        }
        return inheritedTypes.compactMap { inheritedType in
            if let typeSyntax = inheritedType.type.as(IdentifierTypeSyntax.self) {
                return typeSyntax.name.text
            }
            return nil
        }
    }
    
}

extension CodeBlockItemSyntax {
    
    /// 将 body 转化为 do 语句，然后封装为 CodeBlockItemSyntax 元素，以便插入到其他 body 中。
    public init(body: SwiftSyntax.CodeBlockSyntax) {
        let body = SwiftSyntax.CodeBlockSyntax.init(statements: body.statements);
        let doStmtSyntax = DoStmtSyntax.init(body: body)
        self.init(item: .stmt(.init(doStmtSyntax)))
    }
    
}


extension CodeBlockItemListSyntax {
    
    var trimmedNewLines: CodeBlockItemListSyntax {
        return self.trimmed(matching: { item in
            switch item {
            case .newlines:
                return true
            default:
                return false
            }
        })
    }
    
}
