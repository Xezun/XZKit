//
//  XZMocoaMacros.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/7.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

public enum MacroError: Error, CustomStringConvertible {
    case message(String)
    
    public var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}

/// @mocoa: 为带 @key、@bind 的成员，就添加 @objc 标记
public struct MocoaMacro: MemberAttributeMacro {

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        
        if let member = member.as(VariableDeclSyntax.self) {
            var needsAttachAttribute = false
            for item in member.attributes {
                if case let .attribute(attr) = item {
                    let name = attr.attributeName.trimmedDescription
                    // 已有 objc 标记
                    if name == "objc" {
                        return []
                    }
                    // 找到 key 标记
                    if name == "key" {
                        needsAttachAttribute = true;
                    }
                }
            }
            
            if needsAttachAttribute {
                return ["@objc"]
            }
            return []
        }
        
        if let member = member.as(FunctionDeclSyntax.self) {
            var needsAttachAttribute = false
            for item in member.attributes {
                if case let .attribute(attr) = item {
                    let name = attr.attributeName.trimmedDescription
                    // 已有 objc 标记
                    if name == "objc" {
                        return []
                    }
                    // 找到 key 标记
                    if name == "bind" {
                        needsAttachAttribute = true;
                    }
                }
            }
            
            if needsAttachAttribute {
                return ["@objc"]
            }
            return []
        }
   
        return []
    }
    
}


extension MocoaMacro: ExpressionMacro {
    
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard node.arguments.count == 1, let argument = node.arguments.first else {
            throw MacroError.message("仅支持“模块地址”作为参数")
        }
        
        if let exprSyntax = argument.expression.as(StringLiteralExprSyntax.self) {
            guard let string = exprSyntax.representedLiteralValue, string.count > 0 else {
                throw MacroError.message("模块地址不能为空")
            }
            guard URL.init(string: string) != nil else {
                throw MacroError.message("模块地址不是合法的 URL 字符串")
            }
            return "XZMocoaModule(for: URL(string: \(raw: exprSyntax.trimmedDescription)))!"
        }
        
        return "XZMocoaModule(for: \(raw: argument.expression.trimmedDescription))!"
    }
}


/// 为 @mocoaKey(key) 生成存储属性。
public struct MocoaKeyMacro: PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw MacroError.message("@key: 只能应用于 var 属性");
        }
        
        guard declaration.bindingSpecifier.text == "var" else {
            throw MacroError.message("@key: 只能应用于 var 属性")
        }
        
        guard let binding = declaration.bindings.first else {
            throw MacroError.message("@key: 只能应用于 var 属性")
        }

        // 存储属性不生成
        if let _ = binding.initializer {
            throw MacroError.message("@key: 属性不支持直接提供初始值，请通过宏第二个参数提供")
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
                throw MacroError.message("@key: 只能应用于 var 属性");
            }
        }
        
        // 属性名
        var name: String! = nil
        var value: String? = nil
        
        // 属性类型
        guard let type = binding.typeAnnotation?.type else { return [] }
        
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let arguments):
                switch arguments.count {
                case 0:
                    break
                case 2:
                    if let item = arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue, item.count > 0 {
                        name = item
                    }
                    if let item = arguments.last?.expression.trimmedDescription {
                        value = item
                    }
                case 1:
                    guard let argument = arguments.first else { break }
                    if let label = argument.label?.trimmedDescription {
                        if label == "value" {
                            value = argument.expression.trimmedDescription
                        } else {
                            throw MacroError.message("@key: 第一个参数必须是 value 标签，而不是 \(label) 标签")
                        }
                    } else if let item = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                        name = item;
                    } else {
                        throw MacroError.message("@key: 第一个参数必须为 String 字面量，而不能是 \(argument.expression) 值")
                    }
                default:
                    throw MacroError.message("@key: 最多支持两个参数（name, initialValue)")
                }
            case .token(_):
                throw MacroError.message("token")
            case .string(_):
                throw MacroError.message("string")
            case .availability(_):
                throw MacroError.message("availability")
            case .specializeArguments(_):
                throw MacroError.message("specializeArguments")
            case .objCName(_):
                throw MacroError.message("objCName")
            case .implementsArguments(_):
                throw MacroError.message("implementsArguments")
            case .differentiableArguments(_):
                throw MacroError.message("differentiableArguments")
            case .derivativeRegistrationArguments(_):
                throw MacroError.message("derivativeRegistrationArguments")
            case .backDeployedArguments(_):
                throw MacroError.message("backDeployedArguments")
            case .conventionArguments(_):
                throw MacroError.message("conventionArguments")
            case .conventionWitnessMethodArguments(_):
                throw MacroError.message("conventionWitnessMethodArguments")
            case .opaqueReturnTypeOfAttributeArguments(_):
                throw MacroError.message("opaqueReturnTypeOfAttributeArguments")
            case .exposeAttributeArguments(_):
                throw MacroError.message("exposeAttributeArguments")
            case .originallyDefinedInArguments(_):
                throw MacroError.message("originallyDefinedInArguments")
            case .underscorePrivateAttributeArguments(_):
                throw MacroError.message("underscorePrivateAttributeArguments")
            case .dynamicReplacementArguments(_):
                throw MacroError.message("dynamicReplacementArguments")
            case .unavailableFromAsyncArguments(_):
                throw MacroError.message("unavailableFromAsyncArguments")
            case .effectsArguments(_):
                throw MacroError.message("effectsArguments")
            case .documentationArguments(_):
                throw MacroError.message("documentationArguments")
            }
        }
        
        if name == nil {
            if let alia = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                name = alia
            } else {
                throw MacroError.message("@key: 无法确定名称")
            }
        }
        
        if let value = value {
            return ["""
                var _\(raw: name!): \(raw: type.trimmedDescription) = \(raw: value)
                """]
        }
        
        return ["""
            var _\(raw: name!): \(raw: type.trimmedDescription)
            """]
    }
    
}

/// 为 @mocoaKey(key) 生成 setter getter
extension MocoaKeyMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw MacroError.message("@key: 只能应用于 var 属性");
        }
        
        guard declaration.bindingSpecifier.text == "var" else {
            throw MacroError.message("@key: 只能应用于 var 属性")
        }
        
        guard let binding = declaration.bindings.first else {
            throw MacroError.message("@key: 只能应用于 var 属性")
        }

        // 存储属性不生成
        if let _ = binding.initializer {
            throw MacroError.message("@key: 属性不支持直接提供初始值，请通过宏第二个参数提供")
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
                throw MacroError.message("@key: 只能应用于 var 属性");
            }
        }
        
        // 属性名
        var name: String! = nil
        
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let arguments):
                switch arguments.count {
                case 0:
                    break
                case 2:
                    if let item = arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue, item.count > 0 {
                        name = item
                    }
                case 1:
                    guard let argument = arguments.first else { break }
                    if let _ = argument.label?.trimmedDescription {
                        // value 参数
                    } else if let item = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                        name = item;
                    } else {
                        throw MacroError.message("@key: 第一个参数必须为 String 字面量，而不能是 \(argument.expression) 值")
                    }
                default:
                    throw MacroError.message("@key: 最多支持两个参数（name, initialValue)")
                }
            case .token(_):
                throw MacroError.message("token")
            case .string(_):
                throw MacroError.message("string")
            case .availability(_):
                throw MacroError.message("availability")
            case .specializeArguments(_):
                throw MacroError.message("specializeArguments")
            case .objCName(_):
                throw MacroError.message("objCName")
            case .implementsArguments(_):
                throw MacroError.message("implementsArguments")
            case .differentiableArguments(_):
                throw MacroError.message("differentiableArguments")
            case .derivativeRegistrationArguments(_):
                throw MacroError.message("derivativeRegistrationArguments")
            case .backDeployedArguments(_):
                throw MacroError.message("backDeployedArguments")
            case .conventionArguments(_):
                throw MacroError.message("conventionArguments")
            case .conventionWitnessMethodArguments(_):
                throw MacroError.message("conventionWitnessMethodArguments")
            case .opaqueReturnTypeOfAttributeArguments(_):
                throw MacroError.message("opaqueReturnTypeOfAttributeArguments")
            case .exposeAttributeArguments(_):
                throw MacroError.message("exposeAttributeArguments")
            case .originallyDefinedInArguments(_):
                throw MacroError.message("originallyDefinedInArguments")
            case .underscorePrivateAttributeArguments(_):
                throw MacroError.message("underscorePrivateAttributeArguments")
            case .dynamicReplacementArguments(_):
                throw MacroError.message("dynamicReplacementArguments")
            case .unavailableFromAsyncArguments(_):
                throw MacroError.message("unavailableFromAsyncArguments")
            case .effectsArguments(_):
                throw MacroError.message("effectsArguments")
            case .documentationArguments(_):
                throw MacroError.message("documentationArguments")
            }
        }
        
        if name == nil {
            if let alia = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                name = alia
            } else {
                throw MacroError.message("@key: 无法确定名称")
            }
        }
        
        var results = [AccessorDeclSyntax]()
        
        if !hasGetter {
            results.append("""
            get {
                return _\(raw: name!)
            }
            """)
        }
        
        if (!hasSetter && !hasWilSet && !hasDidSet) {
            results.append("""
                set {
                    let oldValue = _\(raw: name!)
                    _\(raw: name!) = newValue
                    if oldValue != newValue {
                        sendActions(forKey: "\(raw: name!)", value: newValue)
                    }
                }
                """)
        }
        
        return results
    }
    
}

// @bind: 校验 @bind 标记的宏的合法性
public struct MocoaBindMacro: BodyMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingBodyFor declaration: some SwiftSyntax.DeclSyntaxProtocol & SwiftSyntax.WithOptionalCodeBlockSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
        
        guard let method = declaration.as(FunctionDeclSyntax.self) else { throw MacroError.message("@key: 只能应用于函数") }
        
        // 函数参数的数量
        if method.signature.parameterClause.parameters.count == 0 {
            throw MacroError.message("@bind: 函数的参数必须与绑定的键一一对应")
        }
        
        // 宏参数
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let list):
                // 宏的参数必须为 0 或者与方法的参数相同
                if list.count == 0 {
                    return []
                }
                if list.count != method.signature.parameterClause.parameters.count {
                    throw MacroError.message("@bind: 函数的参数与绑定的键数量不一致")
                }
                if list.contains(where: { item in
                    return item.expression.as(StringLiteralExprSyntax.self) == nil
                }) {
                    throw MacroError.message("@bind: 指定键名必须为 String 字面量")
                }
                return []
            default:
                throw MacroError.message("@bind: 必须指定当前函数所监听 key 键")
            }
        }
        
        return []
    }
    
}

/// @mocoa: 为成员中带 @bind 的方法注册 mappingModelKeys
extension MocoaMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.message("@mocoa: 只能应用于类")
        }
        
        // 判断是否自定义 mappingModelKeys 属性
        for member in classDecl.memberBlock.members {
            if let member = member.decl.as(VariableDeclSyntax.self) {
                if let propertyName = member.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                    if propertyName == "mappingModelKeys" {
                        for modifier in member.modifiers {
                            if modifier.name.trimmedDescription == "class" {
                                return []
                            }
                        }
                    }
                }
            }
        }
        
        var mappingKeyValueStrings = [String]()
        
        // 遍历 class 包体
        for member in classDecl.memberBlock.members {
            // 只处理方法
            guard let method = member.decl.as(FunctionDeclSyntax.self) else {
                continue
            }
            // 遍历方法属性
            for methodAttribute in method.attributes {
                guard case let .attribute(macroAttribute) = methodAttribute else {
                    continue
                }
                // 只处理带 @bind 标记的方法。
                guard macroAttribute.attributeName.trimmedDescription == "bind" else {
                    continue
                }
                // 获取宏参数
                var keysArray = [String]()
                if let macroArguments = macroAttribute.arguments {
                    switch macroArguments {
                    case .argumentList(let arguments):
                        for argument in arguments {
                            if let key = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                                keysArray.append(key)
                            }
                        }
                    default:
                        break
                    }
                }
                // 遍历方法参数，拼接方法名
                var selector = method.name.text + "("
                if keysArray.count == 0 {
                    for parameter in method.signature.parameterClause.parameters {
                        selector += parameter.firstName.text + ":"
                        if let name = parameter.secondName {
                            keysArray.append(name.text)
                        } else {
                            keysArray.append(parameter.firstName.text)
                        }
                    }
                } else {
                    for parameter in method.signature.parameterClause.parameters {
                        selector += parameter.firstName.text + ":"
                    }
                }
                selector += ")"
                
                let keysString = "\"" + keysArray.joined(separator: "\", \"") + "\""
                
                mappingKeyValueStrings.append("NSStringFromSelector(#selector(Self.\(selector))): [\(keysString)]")
                
                break
            }
        }
        
        if mappingKeyValueStrings.count == 0 {
            return []
        }
        
        let mappingKeyValues = mappingKeyValueStrings.joined(separator: ", \n")
        
        let sdf = try VariableDeclSyntax(
            """
            override class var mappingModelKeys: [String : Any]? {
                return [ 
                    \(raw: mappingKeyValues)
                ]
            }
            """
        )
        
        return [DeclSyntax(sdf)]
    }
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return try expansion(of: node, providingMembersOf: declaration, in: context)
    }
    
}

 

import SwiftCompilerPlugin
import Foundation

@main
struct MocoaMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        MocoaMacro.self,
        MocoaKeyMacro.self,
        MocoaBindMacro.self
    ]
}
