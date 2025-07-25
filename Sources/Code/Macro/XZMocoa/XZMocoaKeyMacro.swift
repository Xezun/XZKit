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
    public static func isValid(forMacro node: SwiftSyntax.AttributeSyntax, forVariable declaration: some SwiftSyntax.DeclSyntaxProtocol, for role: XZMocoaRole) throws -> (expression: PatternBindingSyntax, accessors: [String]) {
        switch role {
        case .m:
            throw Message("@key: 暂不支持 .m 角色");
            
        case .v:
            throw Message("@key: 暂不支持 .v 角色")
            
        case .vm:
            guard let syntax = declaration.as(VariableDeclSyntax.self) else {
                throw Message("@key: 只能应用于 var 属性");
            }
            
            guard syntax.bindingSpecifier.text == "var" else {
                throw Message("@key: 只能应用于 var 属性")
            }
            
            guard syntax.bindings.count == 1 else {
                throw Message("@key: 只适用于单个属性")
            }
            
            if syntax.attributes.attributes(forName: "key").count > 1 {
                throw Message("@key: 标记重复，只可标记一次")
            }
            
            let expression = syntax.bindings[syntax.bindings.startIndex]
            
            if expression.initializer != nil {
                throw Message("@key: 被 @key 标记的属性，需通过 @key(value:) 或 @key(.akey, value:) 提供初始值")
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
                    throw Message("@key: 无法应用于“只读计算属性”");
                }
            }
            
            return (expression, accessors)
        }
        
    }
    
    /// 解析 `@key` 宏的参数。供外部调用。
    public static func arguments(forMacro node: SwiftSyntax.AttributeSyntax, for declaration: VariableDeclSyntax) throws -> (name: String, initialValue: String?) {
        guard let expression = declaration.bindings.first else {
            throw Message("@key: 无法确定属性名")
        }
        return try arguments(forMacro: node, forVariable: expression)
    }
    
    /// 解析 `@key` 宏的参数。
    /// - Parameters:
    ///   - node: 宏节点
    ///   - expression: 属性表达式
    /// - Returns: 表示键名的 name 和初始值 value 的元组
    public static func arguments(forMacro node: SwiftSyntax.AttributeSyntax, forVariable expression: PatternBindingSyntax) throws -> (name: String, initialValue: String?) {
        guard let macroArguments = node.arguments else {
            guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                throw Message("@key: 无法确定属性名")
            }
            return (name, nil)
        }
        return try arguments(froMarco: macroArguments, forVariable: expression)
    }
    
    /// 解析宏 `@key` 的参数。
    private static func arguments(froMarco arguments: SwiftSyntax.AttributeSyntax.Arguments, forVariable expression: PatternBindingSyntax) throws -> (name: String, initialValue: String?) {
        switch arguments {
        case .argumentList(let arguments):
            switch arguments.count {
            case 0:
                // 没有参数，使用属性名
                guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                    throw Message("@key: 无法确定属性名")
                }
                return (name, nil)
                
            case 1:
                let firstArgument = arguments[arguments.startIndex]
                
                if let label = firstArgument.label?.trimmedDescription {
                    if label == "value" {
                        guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                            throw Message("@key: 无法确定属性名")
                        }
                        return (name, firstArgument.expression.trimmedDescription)
                    }
                    throw Message("@key: 第一个参数必须是 value 标签，而不能是 \(label) 标签")
                }
                
                if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
                    if let stringValue = stringLiteral.representedLiteralValue, stringValue.count > 0 {
                        return (stringValue, nil)
                    }
                } else if let mocoaKeySyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
                    let mocoaKey = mocoaKeySyntax.declName.trimmedDescription
                    return (mocoaKey, nil)
                }
                
                throw Message("@key: 第一个参数必须为 String 字面量或 XZMocoaKey 枚举，而不能是 \(firstArgument.expression) 值")
                
            case 2:
                let value = arguments[arguments.index(after: arguments.startIndex)].expression.trimmedDescription
                
                let firstArgument = arguments[arguments.startIndex]
                
                // 检查是否为字面量
                if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
                    if let stringValue = stringLiteral.representedLiteralValue, stringValue.count > 0 {
                        return (stringValue, value)
                    }
                    throw Message("@key: 第一参数不能为空，若不想提供，请使用 value 标签直接提供第二个参数")
                }
                
                // 检查是否 .key 语法
                if let mocoaKeySyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
                    let mocoaKey = mocoaKeySyntax.declName.trimmedDescription
                    return (mocoaKey, value)
                }
                
                throw Message("@key: 第一个参数必须为 String 字面量或 XZMocoaKey 枚举，而不能是 \(firstArgument.expression) 值")
                
            default:
                throw Message("@key: 最多支持两个参数（name, initialValue)")
                
            }
        case .token(_):
            throw Message("@key: not support arguments .token")
        case .string(_):
            throw Message("@key: not support arguments .string")
        case .availability(_):
            throw Message("@key: not support arguments .availability")
        case .specializeArguments(_):
            throw Message("@key: not support arguments .specializeArguments")
        case .objCName(_):
            throw Message("@key: not support arguments .objCName")
        case .implementsArguments(_):
            throw Message("@key: not support arguments .implementsArguments")
        case .differentiableArguments(_):
            throw Message("@key: not support arguments .differentiableArguments")
        case .derivativeRegistrationArguments(_):
            throw Message("@key: not support arguments .derivativeRegistrationArguments")
        case .backDeployedArguments(_):
            throw Message("@key: not support arguments .backDeployedArguments")
        case .conventionArguments(_):
            throw Message("@key: not support arguments .conventionArguments")
        case .conventionWitnessMethodArguments(_):
            throw Message("@key: not support arguments .conventionWitnessMethodArguments")
        case .opaqueReturnTypeOfAttributeArguments(_):
            throw Message("@key: not support arguments .opaqueReturnTypeOfAttributeArguments")
        case .exposeAttributeArguments(_):
            throw Message("@key: not support arguments .exposeAttributeArguments")
        case .originallyDefinedInArguments(_):
            throw Message("@key: not support arguments .originallyDefinedInArguments")
        case .underscorePrivateAttributeArguments(_):
            throw Message("@key: not support arguments .underscorePrivateAttributeArguments")
        case .dynamicReplacementArguments(_):
            throw Message("@key: not support arguments .dynamicReplacementArguments")
        case .unavailableFromAsyncArguments(_):
            throw Message("@key: not support arguments .unavailableFromAsyncArguments")
        case .effectsArguments(_):
            throw Message("@key: not support arguments .effectsArguments")
        case .documentationArguments(_):
            throw Message("@key: not support arguments .documentationArguments")
        }
    }
    
}

/// 宏 `@key("key")` 的实现：生成存储属性。
extension XZMocoaKeyMacro: PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let (expression, _) = try isValid(forMacro: node, forVariable: declaration, for: .vm)
        
        guard let type = expression.typeAnnotation?.type.trimmedDescription else {
            throw Message("@key: 无法确定属性类型")
        }
        
        let (name, value) = try arguments(forMacro: node, forVariable: expression)
        
        if let value = value {
            return ["var _\(raw: name): \(raw: type) = \(raw: value)"]
        }
        
        return ["var _\(raw: name): \(raw: type)"]
    }
}

/// 宏 `@key("key")` 的实现： 生成 setter/getter 方法。
extension XZMocoaKeyMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        let (expression, accessors) = try isValid(forMacro: node, forVariable: declaration, for: .vm)
        
        let hasGetter = accessors.contains("get")
        let hasSetter = accessors.contains("set")
        let hasWilSet = accessors.contains("willSet")
        let hasDidSet = accessors.contains("didSet")
                
        // 属性名
        let name = try arguments(forMacro: node, forVariable: expression).name
        
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



