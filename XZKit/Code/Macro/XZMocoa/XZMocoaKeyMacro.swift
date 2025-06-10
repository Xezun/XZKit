//
//  XZMocoaKeyMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

/// 宏 `@key("key")` 的实现：生成存储属性。
public struct XZMocoaKeyMacro: PeerMacro {
    
    public static func macroArguments(from arguments: SwiftSyntax.AttributeSyntax.Arguments) throws -> (name: String?, initialValue: String?) {
        switch arguments {
        case .argumentList(let arguments):
            switch arguments.count {
            case 0:
                return (nil, nil)
            case 1:
                let firstArgument = arguments[arguments.startIndex]
                
                if let label = firstArgument.label?.trimmedDescription {
                    if label == "value" {
                        return (nil, firstArgument.expression.trimmedDescription)
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
                let secondArgument = arguments[arguments.index(after: arguments.startIndex)]
                
                let firstArgument = arguments[arguments.startIndex]
                if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
                    if let stringValue = stringLiteral.representedLiteralValue, stringValue.count > 0 {
                        return (stringValue, secondArgument.expression.trimmedDescription)
                    }
                    throw XZMocoaMacroError.message("@key: 第一参数不能为空，若不想提供，请使用 value 标签直接提供第二个参数")
                } else if let mocoaKeySyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
                    let mocoaKey = mocoaKeySyntax.declName.trimmedDescription
                    return (mocoaKey, secondArgument.expression.trimmedDescription)
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
    
    public static func macroArguments(from node: SwiftSyntax.AttributeSyntax) throws -> (name: String?, initialValue: String?) {
        guard let arguments = node.arguments else {
            return (nil, nil)
        }
        return try macroArguments(from: arguments)
    }
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw XZMocoaMacroError.message("@key: 只能应用于 var 属性");
        }
        
        guard declaration.bindingSpecifier.text == "var" else {
            throw XZMocoaMacroError.message("@key: 只能应用于 var 属性")
        }
        
        guard let binding = declaration.bindings.first else {
            throw XZMocoaMacroError.message("@key: 只能应用于 var 属性")
        }

        // 存储属性不生成
        if let _ = binding.initializer {
            throw XZMocoaMacroError.message("@key: 属性不支持直接提供初始值，请通过宏第二个参数提供")
        }
        
        // 除非只读计算属性，任何属性只要标记，就生成存储属性
        if let block = binding.accessorBlock {
            switch block.accessors {
            case .accessors(let list):
                for item in list {
                    switch item.accessorSpecifier.text {
                    case "getter":
                        break
                    case "willSet":
                        break
                    case "set":
                        break
                    case "didSet":
                        break
                    default:
                        break
                    }
                }
                break
            case .getter:
                throw XZMocoaMacroError.message("@key: 只能应用于 var 属性");
            }
        }
        
        var (name, value) = try Self.macroArguments(from: node)
        
        if name == nil {
            name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        }
        
        guard let name = name else {
            throw XZMocoaMacroError.message("@key: 无法确定名称")
        }
        
        // 属性类型
        guard let type = binding.typeAnnotation?.type.trimmedDescription else { return [] }
        
        if let value = value {
            return ["var _\(raw: name): \(raw: type) = \(raw: value)"]
        }
        
        return ["var _\(raw: name): \(raw: type)"]
    }
    
}

/// 宏 `@key("key")` 的实现： 生成 setter getter 方法。
extension XZMocoaKeyMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw XZMocoaMacroError.message("@key: 只能应用于 var 属性");
        }
        
        guard declaration.bindingSpecifier.text == "var" else {
            throw XZMocoaMacroError.message("@key: 只能应用于 var 属性")
        }
        
        guard let binding = declaration.bindings.first else {
            throw XZMocoaMacroError.message("@key: 只能应用于 var 属性")
        }

        // 存储属性不生成
        if let _ = binding.initializer {
            throw XZMocoaMacroError.message("@key: 属性不支持直接提供初始值，请通过宏第二个参数提供")
        }
        
        var hasGetter = false
        var hasSetter = false
        var hasWilSet = false
        var hasDidSet = false
        
        // 除非只读计算属性，任何属性只要标记，就生成存储属性
        if let block = binding.accessorBlock {
            switch block.accessors {
            case .accessors(let list):
                for item in list {
                    switch item.accessorSpecifier.text {
                    case "getter":
                        hasGetter = true
                    case "willSet":
                        hasWilSet = true
                    case "set":
                        hasSetter = true
                    case "didSet":
                        hasDidSet = true
                    default:
                        break
                    }
                }
                break
            case .getter:
                throw XZMocoaMacroError.message("@key: 只能应用于 var 属性");
            }
        }
        
        // 属性名
        var (name, _) = try Self.macroArguments(from: node)
        
        if name == nil {
            name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        }
        
        guard let name = name else {
            throw XZMocoaMacroError.message("@key: 无法确定名称")
        }
        
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
