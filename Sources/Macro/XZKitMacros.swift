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
        // NSURL
        URLMacro.self,
        // XZLog
        XZLogMacro.self,
        // XZMocoa
        MocoaMacro.self,
        ModuleMacro.self,
        KeyMacro.self,
        BindMacro.self,
        ViewBindMacro.self
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
    
    public init(_ node: AttributeSyntax, message: String) {
        self = .message("@\(node.attributeName.trimmedDescription): \(message)")
    }
    
}

/// XZKitMacros 诊断消息。
public struct XZMacroDiagnosticMessage: DiagnosticMessage {
    
    public let message: String
    
    public var diagnosticID: SwiftDiagnostics.MessageID {
        return .init(domain: "com.xezun.XZKit", id: "XZKitMacros")
    }
    
    public let severity: SwiftDiagnostics.DiagnosticSeverity
    
    public init(_ node: AttributeSyntax, message: String, severity: SwiftDiagnostics.DiagnosticSeverity) {
        self.message = "@\(node.attributeName.trimmedDescription): \(message)"
        self.severity = severity
    }
    
    public init(_ node: AttributeSyntax, error: Error, severity: SwiftDiagnostics.DiagnosticSeverity) {
        if case let .message(message) = (error as? XZMacroError) {
            self.init(node, message: message, severity: severity)
        } else {
            self.init(node, message: "未知错误", severity: .error)
        }
    }
    
}

/// 输出普通诊断信息。
public func XZMacroDiagnose(_ context: some SwiftSyntaxMacros.MacroExpansionContext, node: AttributeSyntax, message: String, severity: SwiftDiagnostics.DiagnosticSeverity, fixIt: FixIt? = nil) {
    let diagnosticMessage = XZMacroDiagnosticMessage.init(node, message: message, severity: severity);
    if let fixIt = fixIt {
        context.diagnose(.init(node: node, message: diagnosticMessage, fixIt: fixIt))
    } else {
        context.diagnose(.init(node: node, message: diagnosticMessage))
    }
}

/// 输出错误诊断信息。
public func XZMacroDiagnose(_ context: some SwiftSyntaxMacros.MacroExpansionContext, node: AttributeSyntax, error: Error, severity: SwiftDiagnostics.DiagnosticSeverity, fixIt: FixIt? = nil) {
    let diagnosticMessage = XZMacroDiagnosticMessage.init(node, error: error, severity: severity);
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
    
    /// 宏参数列表的数组形式。标签，表达式，字符串值
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

public enum XZMocoaSearchMatchMethod {
    case or
    case and
}

extension VariableDeclSyntax {
    
    /// 属性名
    public var name: String? {
        
        if let binding = self.bindings.first {
            binding.typeAnnotation?.type.as(ide)
        }
        return self.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
    }
    
    public var type: String? {
        
    }
    
    /// 是否为只读属性。
    public var isReadOnlyProperty: Bool {
        if self.bindingSpecifier.text == "let" {
            return true
        }
        
        if self.bindings.count != 1 {
            return false
        }
        
        let expression = self.bindings[self.bindings.startIndex]
        
        if let block = expression.accessorBlock {
            switch block.accessors {
            case .accessors(let list):
                // 只有一个 get 访问点，才认为是只读属性。
                return list.count == 1 && list.first!.accessorSpecifier.tokenKind == .keyword(.get)
            case .getter:
                return true
            }
        }
        
        return false
    }
    
    /// 判断属性是否包含指定修饰符。
    public func containsModifier(_ modifier: Keyword) -> Bool {
        return self.modifiers.contains(where: { $0.name.tokenKind == .keyword(modifier) })
    }
    
    /// 获取指定名字的属性。
    public func attributeForName(_ name: String) -> SwiftSyntax.AttributeSyntax? {
        for attribute in self.attributes {
            guard case let .attribute(macroNode) = attribute else {
                continue
            }
            if macroNode.attributeName.trimmedDescription == name {
                return macroNode
            }
        }
        return nil
    }
    
    /// 判断属性是否包含指定属性。
    ///
    /// 比如`@objc`属性，使用`objc`作为参数。
    public func containsAttribute(_ name: String) -> Bool {
        return self.attributes.contains { attribute in
            if case let .attribute(macroNode) = attribute {
                return macroNode.attributeName.trimmedDescription == name
            }
            return false
        }
    }
    
    public func containsAttributes(_ names: Set<String>, _ method: XZMocoaSearchMatchMethod) -> Bool {
        if names.isEmpty {
            return true
        }
        switch method {
        case .or:
            return self.attributes.contains { attribute in
                if case let .attribute(macroNode) = attribute {
                    let name = macroNode.attributeName.trimmedDescription
                    return names.contains(name)
                }
                return false
            }
        case .and:
            return self.attributes.reduce(names, { partialResult, attribute in
                guard case let .attribute(macroNode) = attribute else {
                    return partialResult
                }
                let name = macroNode.attributeName.trimmedDescription
                guard let index = partialResult.firstIndex(of: name) else {
                    return partialResult
                }
                var newNames = partialResult
                newNames.remove(at: index)
                return newNames
            }).isEmpty
        }
        
    }
    
    /// 包含 accessors 中的任意一个就返回 true
    public func containsAccessors(_ accessors: Set<String>) -> Bool {
        for binding in self.bindings {
            guard let accessorBlock = binding.accessorBlock else { continue }
            switch accessorBlock.accessors {
            case .accessors(let list):
                for item in list {
                    // accessorSpecifier => get set didSet willSet
                    if accessors.contains(item.accessorSpecifier.text) {
                        return true
                    }
                }
            case .getter:
                if accessors.contains("get") {
                    return true
                }
            }
        }
        return false
    }
    
}

extension FunctionDeclSyntax {
    
    /// 获取指定名字的属性。
    public func attributeForName(_ name: String) -> SwiftSyntax.AttributeSyntax? {
        for attribute in self.attributes {
            guard case let .attribute(macroNode) = attribute else {
                continue
            }
            if macroNode.attributeName.trimmedDescription == name {
                return macroNode
            }
        }
        return nil
    }
    
    public func containsAttributes(_ names: Set<String>, _ method: XZMocoaSearchMatchMethod) -> Bool {
        if names.isEmpty {
            return true
        }
        switch method {
        case .or:
            return self.attributes.contains { attribute in
                if case let .attribute(macroNode) = attribute {
                    let name = macroNode.attributeName.trimmedDescription
                    return names.contains(name)
                }
                return false
            }
        case .and:
            return self.attributes.reduce(names, { partialResult, attribute in
                guard case let .attribute(macroNode) = attribute else {
                    return partialResult
                }
                let name = macroNode.attributeName.trimmedDescription
                guard let index = partialResult.firstIndex(of: name) else {
                    return partialResult
                }
                var newNames = partialResult
                newNames.remove(at: index)
                return newNames
            }).isEmpty
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
    
    public func containsMethod(_ methodName: String) -> Bool {
        for member in self.memberBlock.members {
            guard let methodDecl = member.decl.as(FunctionDeclSyntax.self) else {
                continue
            }
            if methodDecl.name.text == methodName {
                return true
            }
        }
        return false
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


extension AttributeSyntax {
    
    // 返回当前宏的第 index 个参数的 XZMocoaKey 值。
    // 如果参数不是字符串或点语法，就返回 nil
    func mocoaKeyFromArgument(at index: Int) throws -> String? {
        guard let arguments = self.arguments else { return nil }
        
        switch arguments {
        case .argumentList(let arguments):
            guard index < arguments.count else { break }
            let argument = arguments[arguments.index(arguments.startIndex, offsetBy: index)]
            // 参数为字符串
            if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
                // 字符串有插值时 representedLiteralValue 返回 nil
                guard let key = stringLiteral.representedLiteralValue else {
                    throw XZMacroError(message: "\(self.attributeName): 仅支持静态字符串")
                }
                return key
            }
            // 参数为点语法
            guard var memberSyntax = argument.expression.as(MemberAccessExprSyntax.self) else {
                throw XZMacroError(message: "\(self.attributeName): 不是合法的 XZMocoaKey 值")
            }
            // 拼接 declName 为最后一个点，后面的部分
            var keyPath = memberSyntax.declName.trimmedDescription;
            while let base = memberSyntax.base?.as(MemberAccessExprSyntax.self) {
                keyPath = "\(base.declName.trimmedDescription).\(keyPath)"
                memberSyntax = base
            }
            return keyPath
            
        default:
            break
        }
    
        throw XZMacroError(message: "@\(self.attributeName): 缺少第 \(index) 参数")
    }
}

public func XZMocoaKey(from argument: LabeledExprSyntax, of node: AttributeSyntax) throws -> String {
    // 参数为字符串
    if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
        if let key = stringLiteral.representedLiteralValue {
            return key
        }
        throw XZMacroError(node, message: "仅支持静态字符串")
    }
    // 参数为点语法
    guard var memberSyntax = argument.expression.as(MemberAccessExprSyntax.self) else {
        throw XZMacroError(node, message: "不是合法的 XZMocoaKey 值")
    }
    // 拼接 declName 为最后一个点，后面的部分
    var keyPath = memberSyntax.declName.trimmedDescription;
    while let base = memberSyntax.base?.as(MemberAccessExprSyntax.self) {
        keyPath = "\(base.declName.trimmedDescription).\(keyPath)"
        memberSyntax = base
    }
    return keyPath
}
