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
        // #URL
        URLMacro.self,
        // #XZLog
        XZLogMacro.self,
        // #module
        ModuleMacro.self,
        // @mocoa
        MocoaMacro.self,
        // @key
        KeyMacro.self,
        // @bind
        BindMacro.self
    ]
    
}

/// 错误信息。
public struct XZMacroError: Error, DiagnosticMessage, CustomStringConvertible {
    
    public let message: String
    public let severity: SwiftDiagnostics.DiagnosticSeverity
    public let diagnosticID: SwiftDiagnostics.MessageID = .init(domain: "com.xezun.XZKit", id: "XZKitMacros")
    
    public var description: String {
        return message
    }
    
    /// 构造用于 `throw` 的错误，severity 固定为 `.error`。
    public init(message: String) {
        self.message = message
        // throw 意味着宏展开失败，而 SwiftSyntax 要求失败时至少产生一条 .error 级诊断，
        // 否则会再补一条通用错误 "macro expansion failed without generating an error"，
        // 掩盖这里自定义的消息，所以用于抛出的 severity 必须是 .error。
        //
        // 宏实现抛出的 error 会被 SwiftSyntax 捕获，并优先尝试作为 DiagnosticMessage 使用。
        // ```swift
        // } else if let message = error as? DiagnosticMessage {
        //     diagnostics = [Diagnostic(node: Syntax(node), message: message)]   // 直接用你的 message + severity
        // }
        // ```
        self.severity = .error
    }
    
    /// 构造用于 `throw` 的错误，消息以宏名称为前缀，severity 固定为 `.error`。
    public init(_ node: AttributeSyntax, message: String) {
        self.init(node, message: message, severity: .error)
    }
    
    /// 构造任意 severity 的诊断消息，仅供 `XZMacroDiagnose` 通过 `context.diagnose`
    /// 输出警告/提示（不中止展开）时使用。
    /// - Important: 不可用此方法构造的对象去 `throw`：抛出非 `.error` 的诊断会被 SwiftSyntax
    ///   追加的通用错误 "macro expansion failed without generating an error" 掩盖。
    ///   为避免误用，限定为 fileprivate，不对外暴露。
    fileprivate init(_ node: AttributeSyntax, message: String, severity: SwiftDiagnostics.DiagnosticSeverity) {
        self.message = "@\(node.attributeName.trimmedDescription): \(message)"
        self.severity = severity
    }
    
}

/// 生成诊断信息。
public func XZMacroDiagnose(_ context: some SwiftSyntaxMacros.MacroExpansionContext, node: AttributeSyntax, message: String, severity: SwiftDiagnostics.DiagnosticSeverity, fixIt: FixIt? = nil) {
    let diagnosticMessage = XZMacroError.init(node, message: message, severity: severity);
    if let fixIt = fixIt {
        context.diagnose(.init(node: node, message: diagnosticMessage, fixIt: fixIt))
    } else {
        context.diagnose(.init(node: node, message: diagnosticMessage))
    }
}

public enum XZMocoaSearchMatchMethod {
    case or
    case and
}

public enum XZMacroMocoaRole: String {
    
    case m
    
    case v
    
    case vm
    
    /// 获取 `@mocoa` 宏所修饰的 class 的 MVVM 角色。
    /// - Parameters:
    ///   - node: 附属于 class 的 `@mocoa(role)` 宏
    ///   - declaration: 声明 class 的节点
    /// - Returns: class 的角色
    public init(node: SwiftSyntax.AttributeSyntax, declaration: SwiftSyntax.ClassDeclSyntax) throws {
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let arguments):
                switch arguments.count {
                case 0:
                    break
                    
                case 1:
                    if let roleValue = arguments[arguments.startIndex].expression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription {
                        if let role = XZMacroMocoaRole.init(rawValue: roleValue) {
                            self = role
                            return
                        }
                    }
                    throw XZMacroError(message: "@mocoa: 参数 role 不是合法的枚举值")
                    
                default:
                    throw XZMacroError(message: "@mocoa: 目前仅支持 role 参数")
                    
                }
                
            default:
                throw XZMacroError(message: "@mocoa: 不支持的参数形式")
            }
            
        }
        
        let inheritedTypes = declaration.inheritedTypes
        
        if inheritedTypes.contains("XZMocoaModel") {
            self = .m
            return
        }
        
        if inheritedTypes.contains("XZMocoaViewModel") {
            self = .vm
            return
        }
        
        if inheritedTypes.contains("UIView") || inheritedTypes.contains("XZMocoaView") || inheritedTypes.contains("UIViewController") {
            self = .v
            return
        }
        
        let className = declaration.name.text
        
        if className.hasSuffix("ViewModel") {
            self = .vm
            return
        }

        if className.hasSuffix("View") || className.hasSuffix("Cell") || className.hasSuffix("Controller") || className.hasSuffix("Bar") {
            self = .v
            return
        }

        if className.hasSuffix("Model") {
            self = .m
            return
        }
        
        throw XZMacroError(message: "@mocoa: 无法确定 \(className) 的角色，请通过 role 参数指定")
    }
    
    /// 获取宏所属的 class 的角色。
    /// - Parameters:
    ///   - node: 宏节点，必须是修饰 class 属性或方法的宏
    ///   - context: 宏节点的上下文
    /// - Returns: 角色
    public init(node: SwiftSyntax.AttributeSyntax, context: some SwiftSyntaxMacros.MacroExpansionContext) throws {
        for lexicalContext in context.lexicalContext {
            if let classDecl = lexicalContext.as(ClassDeclSyntax.self) {
                for attribute in classDecl.attributes {
                    
                    switch attribute {
                    case .attribute(let node):
                        guard node.attributeName.trimmedDescription == "mocoa" else {
                            break;
                        }
                        self = try XZMacroMocoaRole.init(node: node, declaration: classDecl)
                        return
                    case .ifConfigDecl:
                        break
                    }
                }
            }
        }
        throw XZMacroError(message: "@mocoa: 无法确定 \(node.attributeName.trimmedDescription) 所属的角色")
    }
}

/// 类型的包装形式。
public enum XZMacroTypeWrapation {
    /// 非可选
    case unwrapped
    /// 可选
    case optional
    /// 隐式可选
    case autoUnwrapped
    
    init?(_ type: TypeSyntax?) {
        guard let type = type else { return nil }
        if let _ = type.as(OptionalTypeSyntax.self) {
            self = .optional
        } else if let _ = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            self = .autoUnwrapped
        } else {
            self = .unwrapped
        }
    }
}

public struct XZMacroTypeInfomation {
    let name: String
    let wrapation: XZMacroTypeWrapation
    
    init(_ node: AttributeSyntax, _ variableDecl: VariableDeclSyntax) throws {
        guard let expression = variableDecl.bindings.first else {
            throw XZMacroError(node, message: "没有找到属性类型")
        }
        
        // 示例：var textLabel: UILabel!
        if let type = expression.typeAnnotation?.type {
            if let op = type.as(OptionalTypeSyntax.self) {
                self.name = op.wrappedType.trimmedDescription
                self.wrapation = .optional
            } else if let op = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                self.name = op.wrappedType.trimmedDescription
                self.wrapation = .autoUnwrapped
            } else {
                self.name = type.trimmedDescription
                self.wrapation = .unwrapped
            }
        } else if expression.initializer != nil {
            // 由于表达式的返回值值及返回值的可选性无法推断，因此如下获取获取类型，必准确
            // initializer.value.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base
            throw XZMacroError(node, message: "请使用 var propery: Type = initializer() 的形式初始化属性")
        } else {
            throw XZMacroError(node, message: "@bind: 无法解析属性类型")
        }
    }
}

public enum XZMacroPropertyReadability {
    /// let 只读属性
    case constant
    
    /// var 计算属性
    case computed
    /// var 可写属性
    case variable
    
    var isReadonly: Bool {
        return self != .variable
    }
}

public struct XZMacroPropertyInfomation {
    
    let declaration: VariableDeclSyntax
    
    /// 属性名
    let name: String
    /// 属性数据类型
    let type: XZMacroTypeInfomation
    /// 属性的可读性
    let readability: XZMacroPropertyReadability
    /// get set didSet willSet
    let accessors: [String]
    
    init(_ node: AttributeSyntax, _ declaration: VariableDeclSyntax) throws {
        guard let name = declaration.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw XZMacroError(node, message: "无法确定属性名")
        }
        
        self.declaration = declaration
        self.name = name
        self.type = try XZMacroTypeInfomation.init(node, declaration)
        
        switch declaration.bindingSpecifier.text {
        case "let":
            self.readability = .constant
            self.accessors = []
        case "var":
            guard let expression = declaration.bindings.first else {
                throw XZMacroError(node, message: "")
            }
            
            if let accessors = expression.accessorBlock?.accessors {
                switch accessors {
                case .getter:
                    // 计算属性
                    self.readability = .computed
                    self.accessors = ["get"]
                case .accessors(let accessors):
                    self.readability = .variable
                    self.accessors = accessors.map({ accessorDecl in
                        return accessorDecl.accessorSpecifier.text
                    })
                }
            } else {
                self.readability = .variable
                self.accessors = []
            }
        default:
            throw XZMacroError(node, message: "无法确定属性内存属性")
        }
    }
}


public struct XZMacroMethodInformation {
    
    let declaration: FunctionDeclSyntax
    let selector: String
    let parameters: [String]
    
    public init(_ node: SwiftSyntax.AttributeSyntax, _ declaration: FunctionDeclSyntax) {
        var parameters = [String]()

        // 遍历方法参数，拼接方法名
        var selector = "\(declaration.name.text)("
        for parameter in declaration.signature.parameterClause.parameters {
            let parameterLabel = parameter.firstName.text;
            selector += parameterLabel + ":"
            if let parameterName = parameter.secondName?.text {
                parameters.append(parameterName)
            } else {
                parameters.append(parameterLabel)
            }
        }
        selector += ")"
        
        self.declaration = declaration
        self.selector    = selector
        self.parameters  = parameters
    }
}

extension VariableDeclSyntax {
    
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
    
    /// 判断修饰方法的属性宏中，是否包含指定名称的宏。
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
    
    /// class 的方法列表中，是否包含指定名称的方法。
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

extension AttributeSyntax {
    
    /// 宏参数的个数。
    public var numberOfArguments: Int {
        guard case let .argumentList(arguments) = self.arguments else {
            return 0
        }
        return arguments.count
    }
    
    /// 宏参数列表的数组形式。参数表达式，参数的标签
    public var representedArrayArguments: [(expression: LabeledExprSyntax, label: String?)] {
        guard case let .argumentList(arguments) = self.arguments else {
            return []
        }
        var macroArguments = [(LabeledExprSyntax, String?)]()
        for argument in arguments {
            macroArguments.append((argument, argument.label?.text))
        }
        return macroArguments
    }
    
}

public func XZMocoaKey(firstArgumentOf node: AttributeSyntax) throws -> String? {
    guard case let .argumentList(arguments) = node.arguments else { return nil }
    guard let argument = arguments.first else { return nil }
    return try XZMocoaKey(node, argument: argument)
}

public func XZMocoaKey(_ node: AttributeSyntax, argument: LabeledExprSyntax) throws -> String {
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
