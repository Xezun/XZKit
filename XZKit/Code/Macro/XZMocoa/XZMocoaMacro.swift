//
//  XZMocoaMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

/// 宏 `@mocoa(role)` 的实现：为 `@key`、`@bind` 的成员添加 `@objc` 标记。
public struct XZMocoaMacro: MemberAttributeMacro {

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        
        if let member = member.as(VariableDeclSyntax.self) {
            var objcAttributes: String? = nil
            
            for item in member.attributes {
                if case let .attribute(attr) = item {
                    switch attr.attributeName.trimmedDescription {
                    case "objc", "IBAction", "IBOutlet": // 已有 objc 标记
                        return []
                    case "key": // 找到 key 标记
                        if let name = try XZMocoaKeyMacro.macroArguments(from: attr).name {
                            objcAttributes = "@objc(\(name))"
                        } else {
                            objcAttributes = "@objc"
                        }
                    case "bind":
                        objcAttributes = "@objc"
                    default:
                        break
                    }
                }
            }
            
            guard let objcAttributes = objcAttributes else {
                return []
            }
            
            return ["\(raw: objcAttributes)"]
        }
        
        if let member = member.as(FunctionDeclSyntax.self) {
            var needsAttachAttribute = false
            for item in member.attributes {
                if case let .attribute(attr) = item {
                    let name = attr.attributeName.trimmedDescription
                    // 已有 objc 标记
                    if name == "objc" || name == "IBAction" || name == "IBOutlet" {
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

/// 宏 `@mocoa(role)` 的实现：注册角色中带 @bind 的成员方法 mappingModelKeys
extension XZMocoaMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw XZMocoaMacroError.message("@mocoa: 只能应用于类")
        }
        
        guard let arguments = node.arguments, case let .argumentList(argumentList) = arguments, let role = argumentList.first?.trimmedDescription else {
            throw XZMocoaMacroError.message("@mocoa: 缺少 role 参数")
        }
        
        switch role {
        case ".m":
            throw XZMocoaMacroError.message("@mocoa: 暂未实现")
        case ".v":
            // 判断是否自定义 viewModelDidChange 方法
            for member in classDecl.memberBlock.members {
                if let member = member.decl.as(FunctionDeclSyntax.self) {
                    let methodName = member.name.trimmedDescription
                    if methodName == "viewModelDidChange" {
                        // TODO: 是否有必要校验是否为 static 方法
                        return []
                    }
                }
            }
            
            var bindClauseStrings = [String]()
            
            // 遍历 class 包体
            for member in classDecl.memberBlock.members {
                // 只处理方法
                guard let property = member.decl.as(VariableDeclSyntax.self) else {
                    continue
                }
                
                // 遍历属性
                for propertyAttribute in property.attributes {
                    // 找到宏属性
                    guard case let .attribute(macroAttribute) = propertyAttribute else {
                        continue
                    }
                    // 只处理带 @bind 标记的属性。
                    guard macroAttribute.attributeName.trimmedDescription == "bind" else {
                        continue
                    }
                    // 获取宏参数
                    var keysArray = [String]()
                    if let macroArguments = macroAttribute.arguments {
                        switch macroArguments {
                        case .argumentList(let arguments):
                            for argument in arguments {
                                keysArray.append(argument.expression.trimmedDescription)
                            }
                        default:
                            break
                        }
                    }
                    
                    guard let propertyType = ({ (type: TypeSyntax?) -> (name: String, isOptional: Bool)? in
                        guard let type = type else { return nil }
                        if let op = type.as(OptionalTypeSyntax.self) {
                            return (op.wrappedType.trimmedDescription, true)
                        }
                        if let op = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                            return (op.wrappedType.trimmedDescription, true)
                        }
                        return (type.trimmedDescription, false)
                    })(property.bindings.first?.typeAnnotation?.type) else {
                        throw XZMocoaMacroError.message("@mocoa: 无法确定属性类型")
                    }
                    
                    var vkey = ".text"
                    var vmKey = ".text"
                    var selector = ""
                    switch keysArray.count {
                    case 0:
                        switch propertyType.name {
                        case "UILabel":
                            vmKey = ".text"
                            vkey = ".text"
                        case "UITextView":
                            vmKey = ".text"
                            vkey = ".text"
                        case "UIImageView":
                            vmKey = ".image"
                            vkey = ".image"
                        default:
                            throw XZMocoaMacroError.message("@mocoa: 暂未为 \(propertyType) 类型提供默认支持")
                        }
                        selector = "#selector(setter: \(propertyType.name)\(vkey))"
                    case 1:
                        vmKey = keysArray[0]
                        switch propertyType.name {
                        case "UILabel":
                            vkey = ".text"
                        case "UITextView":
                            vkey = ".text"
                        case "UIImageView":
                            vkey = ".image"
                        default:
                            throw XZMocoaMacroError.message("@mocoa: 暂未为 \(propertyType) 类型提供默认支持")
                        }
                        selector = "#selector(setter: \(propertyType.name)\(vkey))"
                    case 2:
                        vmKey = keysArray[0]
                        vkey = keysArray[1]
                        selector = "#selector(setter: \(propertyType.name)\(vkey))"
                    case 3:
                        vmKey = keysArray[0]
                        vkey = keysArray[1]
                        selector = keysArray[2]
                    default:
                        throw XZMocoaMacroError.message("@mocoa: 参数错误，仅支持 (viewKey, viewModelKey, selector) 三个参数")
                    }
                    
                    guard let propertyName = property.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                        throw XZMocoaMacroError.message("@mocoa: 无法确定属性名")
                    }
                    
                    var bindClause = "viewModel.addTarget(\(propertyName), action: \(selector), forKey: \(vmKey), value: nil)"
                    if propertyType.isOptional {
                        // TODO: add didSet to optional properties
                        bindClause = "if let \(propertyName) = self.\(propertyName) { \(bindClause) }"
                    }
                    bindClauseStrings.append(bindClause)
                    break
                }
            }
            
            if bindClauseStrings.count == 0 {
                return []
            }
            
            let clauseString = bindClauseStrings.joined(separator: "\n")
            
            let methodSyntax = try FunctionDeclSyntax(
                """
                override func viewModelDidChange(_ oldValue: XZMocoaViewModel?) {
                    super.viewModelDidChange(oldValue)
                
                    guard let viewModel = self.viewModel else { return }
                    \(raw: clauseString)
                }
                """
            )
            
            return [DeclSyntax(methodSyntax)]
            
        case ".vm":
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
            
            let methodSyntax = try VariableDeclSyntax(
                """
                override class var mappingModelKeys: [String : Any]? {
                    return [ 
                        \(raw: mappingKeyValues)
                    ]
                }
                """
            )
            
            return [DeclSyntax(methodSyntax)]
        default:
            throw XZMocoaMacroError.message("@mocoa: 暂不支持 \(role) 角色")
        }
        
    }
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return try expansion(of: node, providingMembersOf: declaration, in: context)
    }
    
}
