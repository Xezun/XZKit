//
//  XZMocoaMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

public struct XZMocoaMacro {
    
    /// 获取节点 node 上 `@mocoa(role)` 宏的角色声明。
    /// - Parameters:
    ///   - node: 由于无法从子节点获取父节点，该节点必须是声明在类上的宏节点
    ///   - declaration: 类的声明
    /// - Returns: 角色枚举，以及宏所在的声明
    public static func role(forMacro node: SwiftSyntax.AttributeSyntax, forClass declaration: SwiftSyntax.ClassDeclSyntax) throws -> XZMocoaRole {
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let arguments):
                switch arguments.count {
                case 0:
                    break
                    
                case 1:
                    if let roleValue = arguments[arguments.startIndex].expression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription {
                        if let role = XZMocoaRole.init(rawValue: roleValue) {
                            return role
                        }
                    }
                    throw Message("@mocoa: 参数 role 不是合法的枚举值")
                    
                default:
                    throw Message("@mocoa: 目前仅支持 role 参数")
                    
                }
                
            default:
                throw Message("@mocoa: 不支持的参数形式")
            }
            
        }
        
        let className = declaration.name.trimmedDescription
        
        if className.hasSuffix("ViewModel") {
            return .vm
        }
        
        if className.hasSuffix("View") || className.hasSuffix("Cell") || className.hasSuffix("Controller") || className.hasSuffix("Bar") {
            return .v
        }
        
        if className.hasSuffix("Model") {
            return .m
        }
        
        throw Message("@mocoa: 无法确定 \(className) 的角色，请通过 role 参数指定")
    }
    
}

/// 宏 `@mocoa(role)` 的实现：为 `@key`、`@bind` 的成员添加 `@objc` 标记。
extension XZMocoaMacro: MemberAttributeMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw Message("@mocoa: 仅可用于 class 的声明")
        }
        
        let role = try Self.role(forMacro: node, forClass: classDecl)
        
        if let variableDecl = member.as(VariableDeclSyntax.self) {
            var objcAttributes: String? = nil
            
            for attribute in variableDecl.attributes {
                if case let .attribute(macroNode) = attribute {
                    switch macroNode.attributeName.trimmedDescription {
                    case "objc", "IBOutlet":
                        return []
                        
                    case "key":
                        do {
                            let expression = try XZMocoaKeyMacro.isValid(forMacro: macroNode, forVariable: variableDecl, for: role).expression
                            let name = try XZMocoaKeyMacro.arguments(forMacro: macroNode, forVariable: expression).name
                            objcAttributes = "@objc(\(name))"
                        } catch {
                            context.diagnose(.init(node: macroNode, message: Message(error, severity: .warning)))
                        }
                        
                    case "bind":
                        do {
                            // 如果是可选属性，检测是否包含 bind(v:) 调用，否则给出警告
                            if try XZMocoaBindMacro.isValid(forMacro: macroNode, forVariable: variableDecl, for: role) == .wrapped {
                                if !variableDecl.attributes.attributes(forName: "bind").contains(where: { item -> Bool in
                                    guard let arguments = item.arguments else { return false }
                                    switch arguments {
                                    case .argumentList(let labeledExprListSyntax):
                                        return labeledExprListSyntax.contains(where: { $0.label?.text == "v" })
                                    default:
                                        return false
                                    }
                                }) {
                                    let message = "@mocoa: 检测到该属性为可选类型，普通绑定可能失效，请使用 @bind(v:) 进行绑定；若该确定属性不为空，也可使用隐式可选类型，以消除此警告";
                                    context.diagnose(.init(node: macroNode, message: Message(message, severity: .warning)))
                                }
                            }
                            guard objcAttributes == nil else {
                                break // 避免覆盖 @objc(key)
                            }
                            objcAttributes = "@objc"
                        }  catch {
                            context.diagnose(.init(node: macroNode, message: Message(error, severity: .warning)))
                        }
                        break
                        
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
        
        if let methodNode = member.as(FunctionDeclSyntax.self) {
            var objcAttributes: String? = nil
            
            for attribute in methodNode.attributes {
                if case let .attribute(macroNode) = attribute {
                    switch macroNode.attributeName.trimmedDescription {
                    case "objc", "IBAction":
                        return []
                    
                    case "bind":
                        do {
                            try XZMocoaBindMacro.isValid(forMacro: macroNode, forFunction: methodNode, for: role)
                            objcAttributes = "@objc"
                        }  catch {
                            context.diagnose(.init(node: methodNode, message: Message(error, severity: .warning)))
                        }
                        
                    case "ready":
                        objcAttributes = "@nonobjc"
                        
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
   
        return []
    }
    
}

/// 宏 `@mocoa(role)` 的实现：
/// 1. 为 .vm 中 @bind 的成员注册 mappingModelKeys 自动监听
/// 2. 为 .v 中 @bind 成员生成 viewModelDidChange 自动绑定
extension XZMocoaMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw Message("@mocoa: 只能应用于类")
        }
        
        switch try role(forMacro: node, forClass: classDecl) {
        case .m:
            throw Message("@mocoa: 暂未不支持 .m 角色")
            
        case .v:
            // 判断是否自定义 viewModelDidChange 方法
            for member in classDecl.memberBlock.members {
                if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                    let methodName = methodDecl.name.trimmedDescription
                    if methodName == "__viewModelDidChange" {
                        context.diagnose(.init(node: methodDecl, message: Message("@mocoa: 重写 __viewModelDidChange 将会绑定实效，请使用 @ready 标记初始化方法", severity: .warning)))
                        return []
                    }
                }
            }
            
            var bindStatements = [String]()
            var readyMethodNames = [String]()
            
            // 遍历 class 包体
            for member in classDecl.memberBlock.members {
                // 处理属性绑定
                
                if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                    let macroNodes = variableDecl.attributes.compactMap({ attribute -> AttributeSyntax? in
                        // 找到宏属性
                        guard case let .attribute(macroNode) = attribute else {
                            return nil
                        }
                        
                        // 只处理带 @bind 标记的属性。
                        guard macroNode.attributeName.trimmedDescription == "bind" else {
                            return nil
                        }
                        
                        return macroNode
                    });
                        
                    // 遍历属性
                    do {
                        let string = try XZMocoaBindMacro.statements(forMacro: macroNodes, forVariable: variableDecl)
                        bindStatements.append(string)
                    } catch {
                        context.diagnose(.init(node: macroNodes[0], message: Message(error, severity: .warning)))
                    }
                }
                
                // 处理方法绑定
                if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                    // 遍历属性
                    for attribute in methodDecl.attributes {
                        // 找到宏属性
                        guard case let .attribute(macroNode) = attribute else {
                            continue
                        }
                        
                        switch macroNode.attributeName.trimmedDescription {
                        case "bind":
                            break // 只处理带 @bind 标记的属性。
                        case "ready":
                            readyMethodNames.append(methodDecl.name.text)
                            continue
                        default:
                            continue
                        }
                        
                        guard macroNode.attributeName.trimmedDescription == "bind" else {
                            continue
                        }
                        
                        do {
                            let string = try XZMocoaBindMacro.statement(forMacro: macroNode, forFunction: methodDecl)
                            bindStatements.append(string)
                        } catch {
                            context.diagnose(.init(node: macroNode, message: Message(error, severity: .warning)))
                        }
                    }
                }
            }
            
            if bindStatements.isEmpty {
                if readyMethodNames.isEmpty {
                    return []
                }
                let methodSyntax = try FunctionDeclSyntax(
                    """
                    override func __viewModelDidChange(_ oldValue: XZMocoaViewModel?) {
                        super.__viewModelDidChange(oldValue)
                        \(raw: readyMethodNames.map({ "\($0)()" }).joined(separator: "\n"))
                    }
                    """
                )
                return [DeclSyntax(methodSyntax)]
            }
            
            let bindStatementString = bindStatements.joined(separator: "\n")
            let readyStatementString = readyMethodNames.map({ "\($0)()" }).joined(separator: "\n")
            
            let methodSyntax = try FunctionDeclSyntax(
                """
                override func __viewModelDidChange(_ oldValue: XZMocoaViewModel?) {
                    super.__viewModelDidChange(oldValue)
                    \(raw: readyStatementString)
                    guard let viewModel = self.viewModel else { return }
                    \(raw: bindStatementString)
                }
                """
            )
            
            return [DeclSyntax(methodSyntax)]
            
        case .vm:
            // 判断是否自定义 mappingModelKeys 属性
            for member in classDecl.memberBlock.members {
                if let member = member.decl.as(VariableDeclSyntax.self) {
                    if let propertyName = member.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                        if propertyName == "mappingModelKeys" {
                            for modifier in member.modifiers {
                                if modifier.name.trimmedDescription == "class" {
                                    context.diagnose(.init(node: member, message: Message("@mocoa: 检测到已自定义 mappingModelKeys 属性，自动监听将不生效", severity: .warning)))
                                    return []
                                }
                            }
                        }
                    }
                }
            }
            
            var mappingKeyValueStrings = [String]()
            var readyMethodNames = [String]()
            
            // 遍历 class 包体
            for member in classDecl.memberBlock.members {
                // 处理属性
                if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                    // 遍历方法属性，找到理带 @bind 标记的方法。
                    for methodAttribute in variableDecl.attributes {
                        guard case let .attribute(macroAttribute) = methodAttribute else {
                            continue
                        }
                        guard macroAttribute.attributeName.trimmedDescription == "bind" else {
                            continue
                        }
                        
                        guard let name = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                            continue
                        }
                        
                        // 获取宏参数
                        var keysArray = [String]()
                        if let macroArguments = macroAttribute.arguments {
                            switch macroArguments {
                            case .argumentList(let arguments):
                                for argument in arguments {
                                    if let key = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                                        // 去掉了字面量双引号
                                        keysArray.append(key)
                                    } else if let key = argument.expression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription {
                                        // 去掉了点号
                                        keysArray.append(key)
                                    }
                                }
                            default:
                                break
                            }
                        }
                        
                        if keysArray.isEmpty {
                            mappingKeyValueStrings.append("NSStringFromSelector(#selector(setter: Self.\(name))): [\"\(name)\"]")
                        } else {
                            mappingKeyValueStrings.append("NSStringFromSelector(#selector(setter: Self.\(name))): [\"\(keysArray[0])\"]")
                        }
                    }
                    
                }
                
                // 处理方法
                if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                    // 遍历方法属性，找到理带 @bind 标记的方法。
                    for methodAttribute in methodDecl.attributes {
                        guard case let .attribute(macroAttribute) = methodAttribute else {
                            continue
                        }
                        
                        switch macroAttribute.attributeName.trimmedDescription {
                        case "bind":
                            break
                        case "ready":
                            readyMethodNames.append(methodDecl.name.text)
                            continue
                        default:
                            continue
                        }
                        
                        // 获取宏参数
                        var keysArray = [String]()
                        if let macroArguments = macroAttribute.arguments {
                            switch macroArguments {
                            case .argumentList(let arguments):
                                for argument in arguments {
                                    if let key = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                                        // 去掉了字面量双引号
                                        keysArray.append(key)
                                    } else if let key = argument.expression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription {
                                        // 去掉了点号
                                        keysArray.append(key)
                                    }
                                }
                            default:
                                break
                            }
                        }
                        // 遍历方法参数，拼接方法名
                        var selector = methodDecl.name.text + "("
                        if keysArray.count == 0 {
                            for parameter in methodDecl.signature.parameterClause.parameters {
                                selector += parameter.firstName.text + ":"
                                if let name = parameter.secondName {
                                    keysArray.append(name.text)
                                } else {
                                    keysArray.append(parameter.firstName.text)
                                }
                            }
                        } else {
                            for parameter in methodDecl.signature.parameterClause.parameters {
                                selector += parameter.firstName.text + ":"
                            }
                        }
                        selector += ")"
                        
                        
                        let keysString = "\"" + keysArray.joined(separator: "\", \"") + "\""
                        
                        mappingKeyValueStrings.append("NSStringFromSelector(#selector(Self.\(selector))): [\(keysString)]")
                        break
                    }
                }
                
            }
            
            if mappingKeyValueStrings.count == 0 {
                let methodSyntax = try FunctionDeclSyntax(
                    """
                    override func __prepare() {
                        super.__prepare()
                        \(raw: readyMethodNames.map({ "\($0)()" }).joined(separator: "\n"))
                    }
                    """
                )
                return [DeclSyntax(methodSyntax)]
            }
            
            let mappingKeyValues = mappingKeyValueStrings.joined(separator: ", \n")
            
            let variableSyntax = try VariableDeclSyntax(
                """
                override class var mappingModelKeys: [String : Any]? {
                    return [ 
                        \(raw: mappingKeyValues)
                    ]
                }
                """
            )
            
            let methodSyntax = try FunctionDeclSyntax(
                """
                override func __prepare() {
                    super.__prepare()
                    \(raw: readyMethodNames.map({ "\($0)()" }).joined(separator: "\n"))
                }
                """
            )
            
            return [DeclSyntax(methodSyntax), DeclSyntax(variableSyntax)]
        }
        
    }
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return try expansion(of: node, providingMembersOf: declaration, in: context)
    }
    
}
