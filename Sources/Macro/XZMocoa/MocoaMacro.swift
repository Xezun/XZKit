//
//  MocoaMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

public struct MocoaMacro {
    
    /// 点语法表达式 .key1.key2 转为字符串 "key1.key2"
    public static func keyPath(fromMacroArgument argument: LabeledExprSyntax) -> String? {
        guard var keyExpr = argument.expression.as(MemberAccessExprSyntax.self) else {
            return nil
        }
        
        // declName 为最后一个点，后面的部分
        var keyPath = keyExpr.declName.trimmedDescription;
        
        while let base = keyExpr.base?.as(MemberAccessExprSyntax.self) {
            keyPath = "\(base.declName.trimmedDescription).\(keyPath)"
            keyExpr = base
        }
        
        return keyPath
    }
    
}

/// 为成员添加`@`修饰属性。
/// 宏 `@mocoa(role)` 的实现：
/// .m  => 为 @key 标记的属性添加 @objc 标记，以支持 KVC 取值
/// .v  => 为 @key / @bind 标记的方法，添加 @objc 标记，以支持 KVC 取值
/// .vm => 为 @key @bind 标记的属性和方法添加 @objc 标记
extension MocoaMacro: MemberAttributeMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw XZMacroError(message: "@mocoa: 仅可用于 class 的声明")
        }
        
        let role = try MocoaRole.init(node: node, declaration: classDecl)
        
        switch role {
        case .m:
            guard let propertyDecl = member.as(VariableDeclSyntax.self) else {
                return []
            }
            guard let attributeNode = propertyDecl.attributeForName("key") else {
                return []
            }
            return try KeyMacro.expansion(of: attributeNode, providingAttributesFor: propertyDecl, in: context)
                                      
        case .v:
            // 视图属性不需要添加 @objc
            guard let methodDecl = member.as(FunctionDeclSyntax.self) else {
                return []
            }
            if let attributeNode = methodDecl.attributeForName("bind") {
                return try BindMacro.expansion(of: attributeNode, providingAttributesFor: methodDecl, in: context, for: .v)
            }
            if let attributeNode = methodDecl.attributeForName("link") {
                return try BindMacro.expansion(of: attributeNode, providingAttributesFor: methodDecl, in: context, for: .v)
            }
            return []
            
        case .vm:
            // 为 class 的属性附加宏
            if let propertyDecl = member.as(VariableDeclSyntax.self) {
                // 为 @key 宏生成 @objc 标记
                if let attributeNode = propertyDecl.attributeForName("key") {
                    return try KeyMacro.expansion(of: attributeNode, providingAttributesFor: propertyDecl, in: context)
                }
                // 为 @bind 宏生成 @objc 标记
                if let attributeNode = propertyDecl.attributeForName("bind") {
                    return try BindMacro.expansion(of: attributeNode, providingAttributesFor: propertyDecl, in: context, for: .vm)
                }
                // 为 @link 宏生成 @objc 标记
                if let attributeNode = propertyDecl.attributeForName("link") {
                    return try BindMacro.expansion(of: attributeNode, providingAttributesFor: propertyDecl, in: context, for: .vm)
                }
                return []
            }
            
            // 为 class 的方法附加宏
            if let methodDecl = member.as(FunctionDeclSyntax.self) {
                // 为 @bind 宏生成 @objc 标记
                if let attributeNode = methodDecl.attributeForName("bind") {
                    return try BindMacro.expansion(of: attributeNode, providingAttributesFor: methodDecl, in: context, for: .vm)
                }
                // 为 @link 宏生成 @objc 标记
                if let attributeNode = methodDecl.attributeForName("link") {
                    return try BindMacro.expansion(of: attributeNode, providingAttributesFor: methodDecl, in: context, for: .vm)
                }
                return []
            }
            
            return []
        }
    }
    
}

/// 宏 `@mocoa(role)` 的实现：
/// .vm => 为 @bind 的成员注册 `mappingObserverMethodsForModelKeys` 自动监听
/// .v  => 为 @bind 成员生成 `__xz_bind_prepare` 自动绑定
/// .m  => 暂不执行任何操作
extension MocoaMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw XZMacroError(message: "@mocoa: 只能应用于 class 类")
        }
        
        switch try MocoaRole.init(node: node, declaration: classDecl) {
        case .m:
            return [];
            
        case .v:
            // 判断是否自定义 __xz_bind_prepare 方法
            if classDecl.containsMethod("__xz_bind_prepare") {
                throw XZMacroError(node, message: "重写私有方法 __xz_bind_prepare 方法会导致绑定失效，请使用 prepareForViewModel 方法代替")
            }
            
            var statements = [String]()
            
            for member in classDecl.memberBlock.members {
                if let propertyDecl = member.decl.as(VariableDeclSyntax.self) {
                    for attribute in propertyDecl.attributes {
                        guard case let .attribute(node) = attribute else {
                            continue
                        }
                        switch node.attributeName.trimmedDescription {
                        case "bind":
                            fallthrough
                        case "link":
                            statements.append(contentsOf: try BindMacro.expansion(of: node, providingStatementsOf: propertyDecl, in: context, for: .v))
                        default:
                            continue
                        }
                    }
                }
                if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                    for attribute in methodDecl.attributes {
                        guard case let .attribute(node) = attribute else {
                            continue
                        }
                        switch node.attributeName.trimmedDescription {
                        case "bind":
                            fallthrough
                        case "link":
                            statements.append(contentsOf: try BindMacro.expansion(of: node, providingStatementsOf: methodDecl, in: context, for: .vm))
                        default:
                            continue
                        }
                    }
                }
            }
            
            if statements.isEmpty {
                return []
            }
            
            let bindcodes = statements.joined(separator: "\n    ")
            
            let methodSyntax = try FunctionDeclSyntax(
                """
                override func __xz_bind_prepare() {
                    super.__xz_bind_prepare()
                    guard let viewModel = self.viewModel else { return }
                    \(raw: bindcodes)
                }
                """
            )
            return [DeclSyntax(methodSyntax)]
            
        case .vm:
            // 判断是否自定义 mappingObserverMethodsForModelKeys 属性
            if classDecl.containsMethod("mappingObserverMethodsForModelKeys") {
                for member in classDecl.memberBlock.members {
                    if let variableDecl = member.decl.as(VariableDeclSyntax.self), let node = variableDecl.attributeForName("bind") {
                        XZMacroDiagnose(context, node: node, message: "由于已重写 mappingObserverMethodsForModelKeys 属性，宏 @bind 监听将不生效", severity: .warning)
                    }
                    if let methodDecl = member.decl.as(FunctionDeclSyntax.self), let node = methodDecl.attributeForName("bind") {
                        XZMacroDiagnose(context, node: node, message: "由于已重写 mappingObserverMethodsForModelKeys 属性，宏 @bind 监听将不生效", severity: .warning)
                    }
                }
                return []
            }
            
            var statements = [String]()
            
            for member in classDecl.memberBlock.members {
                if let propertyDecl = member.decl.as(VariableDeclSyntax.self) {
                    for attribute in propertyDecl.attributes {
                        guard case let .attribute(node) = attribute else {
                            continue
                        }
                        switch node.attributeName.trimmedDescription {
                        case "bind":
                            fallthrough
                        case "link":
                            statements.append(contentsOf: try BindMacro.expansion(of: node, providingStatementsOf: propertyDecl, in: context, for: .v))
                        default:
                            continue
                        }
                    }
                }
                if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                    for attribute in methodDecl.attributes {
                        guard case let .attribute(node) = attribute else {
                            continue
                        }
                        switch node.attributeName.trimmedDescription {
                        case "bind":
                            fallthrough
                        case "link":
                            statements.append(contentsOf: try BindMacro.expansion(of: node, providingStatementsOf: methodDecl, in: context, for: .vm))
                        default:
                            continue
                        }
                    }
                }
            }
            
            if statements.isEmpty {
                return []
            }
            
            let bindcodes = statements.joined(separator: ", \n            ")
            
            let variableSyntax = try VariableDeclSyntax(
                """
                    override class var mappingObserverMethodsForModelKeys: [String : Any]? {
                        return [ 
                            \(raw: bindcodes)
                        ]
                    }
                """
            )
            
            return [DeclSyntax(variableSyntax)]
            
            // old
            
            var mappingKeyValueStrings = [String]()
            
            // 遍历 class 包体
            for member in classDecl.memberBlock.members {
                // 处理属性
                if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                    // 遍历方法属性，找到理带 @bind 标记的方法。
                    for variableAttribute in variableDecl.attributes {
                        guard case let .attribute(macroAttribute) = variableAttribute else {
                            continue
                        }
                        guard macroAttribute.attributeName.trimmedDescription == "bind" else {
                            continue
                        }
                        
                        guard let name = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                            continue
                        }
                        
                        // 获取宏参数
                        var macroParameter: String? = nil
                        if let macroArguments = macroAttribute.arguments {
                            switch macroArguments {
                            case .argumentList(let arguments):
                                for argument in arguments {
                                    // 参数为字符串，去掉双引号
                                    if let key = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                                        macroParameter = key
                                        break
                                    }
                                    // 参数为点语法，去掉了点号，转化为 keyPath
                                    if let keyPath = Self.keyPath(fromMacroArgument: argument) {
                                        macroParameter = keyPath
                                        break
                                    }
                                }
                            default:
                                break
                            }
                        }
                        
                        if let macroParameter = macroParameter {
                            mappingKeyValueStrings.append("NSStringFromSelector(#selector(setter: Self.\(name))): [\"\(macroParameter)\"]")
                        } else {
                            mappingKeyValueStrings.append("NSStringFromSelector(#selector(setter: Self.\(name))): [\"\(name)\"]")
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
                        default:
                            continue
                        }
                        
                        // 获取宏参数
                        var macroParameters = [String]()
                        if let macroArguments = macroAttribute.arguments {
                            switch macroArguments {
                            case .argumentList(let arguments):
                                for argument in arguments {
                                    if let key = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                                        macroParameters.append(key)
                                    } else if let keyPath = Self.keyPath(fromMacroArgument: argument) {
                                        macroParameters.append(keyPath)
                                    }
                                }
                            default:
                                break
                            }
                        }
                        // 遍历方法参数，拼接方法名
                        var bindSelector = methodDecl.name.text + "("
                        
                        // 宏没有参数，读取方法的参数
                        if macroParameters.count == 0 {
                            for parameter in methodDecl.signature.parameterClause.parameters {
                                bindSelector += parameter.firstName.text + ":"
                                if let name = parameter.secondName {
                                    macroParameters.append(name.text)
                                } else {
                                    macroParameters.append(parameter.firstName.text)
                                }
                            }
                        } else {
                            // 校验宏指定的 key 数量与方法参数数量一致，否则监听映射不正确。
                            let parameterCount = methodDecl.signature.parameterClause.parameters.count
                            guard macroParameters.count == parameterCount else {
                                XZMacroDiagnose(context, node: macroAttribute, message: "@mocoa: @bind 指定的 key 数量（\(macroParameters.count)）与方法参数数量（\(parameterCount)）不一致", severity: .warning)
                                break
                            }
                            for parameter in methodDecl.signature.parameterClause.parameters {
                                bindSelector += parameter.firstName.text + ":"
                            }
                        }
                        bindSelector += ")"
                        
                        
                        let bindKeys = "\"" + macroParameters.joined(separator: "\", \"") + "\""
                        
                        mappingKeyValueStrings.append("NSStringFromSelector(#selector(Self.\(bindSelector))): [\(bindKeys)]")
                        break
                    }
                }
                
            }
            
            
            
            if mappingKeyValueStrings.isEmpty {
                return []
            }
            
            let mappingKeyValues = mappingKeyValueStrings.joined(separator: ", \n            ")
            
            let variableSyntax = try VariableDeclSyntax(
                """
                    override class var mappingObserverMethodsForModelKeys: [String : Any]? {
                        return [ 
                            \(raw: mappingKeyValues)
                        ]
                    }
                """
            )
            
            return [DeclSyntax(variableSyntax)]
        }
        
    }
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return try expansion(of: node, providingMembersOf: declaration, in: context)
    }
    
}

public enum MocoaRole: String {
    
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
                        if let role = MocoaRole.init(rawValue: roleValue) {
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
                        self = try MocoaRole.init(node: node, declaration: classDecl)
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



