//
//  XZMocoaKeyMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

public struct XZMocoaKeyMacro {
    
    /// 校验宏节点 node 属性 declaration 作为 role 角色的元素是否有效。
    /// - Parameters:
    ///   - node: 宏节点
    ///   - declaration: 属性节点
    ///   - role: 角色
    /// - Returns: 如果有效，返回属性表达式和访问器，否则抛出异常。
    public static func isValid(macro node: SwiftSyntax.AttributeSyntax, declaration: some SwiftSyntax.DeclSyntaxProtocol, in role: XZMocoaRole) throws -> (expression: PatternBindingSyntax, accessors: [String]) {
        switch role {
        case .m:
            throw XZMocoaMacroError.message("@key: 暂不支持 .m 角色");
            
        case .v:
            throw XZMocoaMacroError.message("@key: 暂不支持 .v 角色")
            
        case .vm:
            guard let syntax = declaration.as(VariableDeclSyntax.self) else {
                throw XZMocoaMacroError.message("@key: 只能应用于 var 属性");
            }
            
            guard syntax.bindingSpecifier.text == "var" else {
                throw XZMocoaMacroError.message("@key: 只能应用于 var 属性")
            }
            
            guard syntax.bindings.count == 1 else {
                throw XZMocoaMacroError.message("@key: 只适用于单个属性")
            }
            
            let expression = syntax.bindings[syntax.bindings.startIndex]
            
            if expression.initializer != nil {
                let (_, value) = try XZMocoaKeyMacro.arguments(forMacro: node, for: expression)
                if value == nil {
                    throw XZMocoaMacroError.message("@key: 请通过 value 参数提供初始值，请删除属性初始值")
                }
                throw XZMocoaMacroError.message("@key: 不支持在此处提供属性的初始值")
            }
            
            var accessors = [String]()
            
            if let block = expression.accessorBlock {
                switch block.accessors {
                case .accessors(let list):
                    for item in list {
                        accessors.append(item.accessorSpecifier.text)
                    }
                    break
                case .getter:
                    throw XZMocoaMacroError.message("@key: 无法应用于“只读计算属性”");
                }
            }
            
            return (expression, accessors)
        }
        
    }
    
    /// 解析 `@key` 宏的参数。供外部调用。
    public static func arguments(forMacro node: SwiftSyntax.AttributeSyntax, declaration: VariableDeclSyntax, in role: XZMocoaRole) throws -> (name: String, initialValue: String?) {
        let expression = try isValid(macro: node, declaration: declaration, in: role).expression
        return try arguments(forMacro: node, for: expression)
    }
    
    /// 解析 `@key` 宏的参数。
    /// - Parameters:
    ///   - node: 宏节点
    ///   - expression: 修饰的属性表达式
    /// - Returns: 表示键名的 name 和初始值 value 的元组
    public static func arguments(forMacro node: SwiftSyntax.AttributeSyntax, for expression: PatternBindingSyntax) throws -> (name: String, initialValue: String?) {
        guard let arguments = node.arguments else {
            guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                throw XZMocoaMacroError.message("@key: 无法确定属性名")
            }
            return (name, nil)
        }
        return try macroArguments(from: arguments, property: expression)
    }
    
    /// 解析宏 `@key` 的参数。
    private static func macroArguments(from arguments: SwiftSyntax.AttributeSyntax.Arguments, property binding: PatternBindingSyntax) throws -> (name: String, initialValue: String?) {
        switch arguments {
        case .argumentList(let arguments):
            switch arguments.count {
            case 0:
                // 没有参数，使用属性名
                guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                    throw XZMocoaMacroError.message("@key: 无法确定属性名")
                }
                return (name, nil)
                
            case 1:
                let firstArgument = arguments[arguments.startIndex]
                
                if let label = firstArgument.label?.trimmedDescription {
                    if label == "value" {
                        guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                            throw XZMocoaMacroError.message("@key: 无法确定属性名")
                        }
                        return (name, firstArgument.expression.trimmedDescription)
                    }
                    throw XZMocoaMacroError.message("@key: 第一个参数必须是 value 标签，而不能是 \(label) 标签")
                }
                
                if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
                    if let stringValue = stringLiteral.representedLiteralValue, stringValue.count > 0 {
                        return (stringValue, nil)
                    }
                } else if let mocoaKeySyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
                    let mocoaKey = mocoaKeySyntax.declName.trimmedDescription
                    return (mocoaKey, nil)
                }
                
                throw XZMocoaMacroError.message("@key: 第一个参数必须为 String 字面量或 XZMocoaKey 枚举，而不能是 \(firstArgument.expression) 值")
                
            case 2:
                let value = arguments[arguments.index(after: arguments.startIndex)].expression.trimmedDescription
                
                let firstArgument = arguments[arguments.startIndex]
                
                // 检查是否为字面量
                if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
                    if let stringValue = stringLiteral.representedLiteralValue, stringValue.count > 0 {
                        return (stringValue, value)
                    }
                    throw XZMocoaMacroError.message("@key: 第一参数不能为空，若不想提供，请使用 value 标签直接提供第二个参数")
                }
                
                // 检查是否 .key 语法
                if let mocoaKeySyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
                    let mocoaKey = mocoaKeySyntax.declName.trimmedDescription
                    return (mocoaKey, value)
                }
                
                throw XZMocoaMacroError.message("@key: 第一个参数必须为 String 字面量或 XZMocoaKey 枚举，而不能是 \(firstArgument.expression) 值")
                
            default:
                throw XZMocoaMacroError.message("@key: 最多支持两个参数（name, initialValue)")
                
            }
        case .token(_):
            throw XZMocoaMacroError.message("@key: not support arguments .token")
        case .string(_):
            throw XZMocoaMacroError.message("@key: not support arguments .string")
        case .availability(_):
            throw XZMocoaMacroError.message("@key: not support arguments .availability")
        case .specializeArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .specializeArguments")
        case .objCName(_):
            throw XZMocoaMacroError.message("@key: not support arguments .objCName")
        case .implementsArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .implementsArguments")
        case .differentiableArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .differentiableArguments")
        case .derivativeRegistrationArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .derivativeRegistrationArguments")
        case .backDeployedArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .backDeployedArguments")
        case .conventionArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .conventionArguments")
        case .conventionWitnessMethodArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .conventionWitnessMethodArguments")
        case .opaqueReturnTypeOfAttributeArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .opaqueReturnTypeOfAttributeArguments")
        case .exposeAttributeArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .exposeAttributeArguments")
        case .originallyDefinedInArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .originallyDefinedInArguments")
        case .underscorePrivateAttributeArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .underscorePrivateAttributeArguments")
        case .dynamicReplacementArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .dynamicReplacementArguments")
        case .unavailableFromAsyncArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .unavailableFromAsyncArguments")
        case .effectsArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .effectsArguments")
        case .documentationArguments(_):
            throw XZMocoaMacroError.message("@key: not support arguments .documentationArguments")
        }
    }
    
}

/// 宏 `@key("key")` 的实现：生成存储属性。
extension XZMocoaKeyMacro: PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let (propertySyntax, _) = try isValid(macro: node, declaration: declaration, in: .vm)
        
        guard let type = propertySyntax.typeAnnotation?.type.trimmedDescription else {
            throw XZMocoaMacroError.message("@key: 无法确定属性类型")
        }
        
        let (name, value) = try arguments(forMacro: node, for: propertySyntax)
        
        if let value = value {
            return ["var _\(raw: name): \(raw: type) = \(raw: value)"]
        }
        
        return ["var _\(raw: name): \(raw: type)"]
    }
}

/// 宏 `@key("key")` 的实现： 生成 setter/getter 方法。
extension XZMocoaKeyMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        let (propertySyntax, accessors) = try isValid(macro: node, declaration: declaration, in: .vm)
        
        let hasGetter = accessors.contains("get")
        let hasSetter = accessors.contains("set")
        let hasWilSet = accessors.contains("willSet")
        let hasDidSet = accessors.contains("didSet")
                
        // 属性名
        let name = try arguments(forMacro: node, for: propertySyntax).name
        
        var results = [AccessorDeclSyntax]()
        
        if !hasGetter {
            results.append(
                """
                get { 
                    return _\(raw: name) 
                }
                """
            )
        }
        
        if (!hasSetter && !hasWilSet && !hasDidSet) {
            results.append(
                """
                set {
                    let oldValue = _\(raw: name)
                    _\(raw: name) = newValue
                    if oldValue != newValue {
                        sendActions(forKey: "\(raw: name)", value: newValue)
                    }
                }
                """
            )
        }
        
        return results
    }
    
}



