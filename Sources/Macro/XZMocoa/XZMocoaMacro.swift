//
//  XZMocoaMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

public struct XZMocoaMacro {
    
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

/// .m  => 检查被 `@mocoa` 标记的类是否继承自 NSObject 并添加 `@objc` 标记。
extension XZMocoaMacro: PeerMacro {
    
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw XZMacroError(message: "@mocoa: 仅可用于 class 的声明")
        }
        
        let role = try XZMocoaRole.init(node: node, declaration: classDecl)
        
        switch role {
        case .m:
            // 为 Model 添加 @objc 标记
            guard classDecl.inheritedTypes.contains("NSObject") else {
                throw XZMacroError(message: "@mocoa: 仅可修饰继承自 NSObject 的 class 的声明")
            }
            
            var newAttributes = classDecl.attributes
            newAttributes.append(
                .init(AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("objc"))))
            )
            
            return [DeclSyntax(classDecl.with(\.attributes, newAttributes))]
        case .v:
            return []
        case .vm:
            return []
        }
        
    }
    
}

/// 宏 `@mocoa(role)` 的实现：
/// .m  => 为 @key 标记的属性添加 @objc 标记；检查是否缺少 dynamic 标记
/// .v  => 为 @bind 标记的方法，添加 @objc 标记
/// .vm => 为 @key @bind 标记的属性和方法添加 @objc 标记
extension XZMocoaMacro: MemberAttributeMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw XZMacroError(message: "@mocoa: 仅可用于 class 的声明")
        }
        
        let role = try XZMocoaRole.init(node: node, declaration: classDecl)
        
        switch role {
        case .m:
            guard let property = member.as(VariableDeclSyntax.self) else {
                return []
            }
            guard property.contains(attribute: "key") else {
                return []
            }
            if !property.contains(attributes: ["dynamic", "NSManaged"], .or) {
                let message = "@mocoa: 缺少 dynamic 标记，该属性值可能无法被用作 key";
                XZMacroDiagnose(context, node: property, message: message, severity: .warning)
            }
            if property.contains(attribute: "objc") {
                return []
            }
            return ["@objc"]
            
        case .v:
            // 视图属性不需要添加 @objc
            guard let methodNode = member.as(FunctionDeclSyntax.self) else {
                return []
            }
            
            var containsBind = false
            for attribute in methodNode.attributes {
                if case let .attribute(macroNode) = attribute {
                    switch macroNode.attributeName.trimmedDescription {
                    case "objc", "IBAction":
                        return []
                    
                    case "bind":
                        containsBind = true
                        
                    case "prepare":
                        break
                        
                    default:
                        break
                    }
                }
            }
            return containsBind ? ["@objc"] : []
            
        case .vm:
            var attributeSyntaxes = [SwiftSyntax.AttributeSyntax]()
            
            if let variableDecl = member.as(VariableDeclSyntax.self) {
                var containsObjc = false
                var containsBind = false
                
                for attribute in variableDecl.attributes {
                    guard case let .attribute(macroNode) = attribute else {
                        continue
                    }
                    switch macroNode.attributeName.trimmedDescription {
                    case "objc", "IBOutlet":
                        containsObjc = true
                    case "key": // 需要用 kvc 取值，因此需要 @objc 标记
                        containsBind = true
                    case "bind":
                        containsBind = true
                    default:
                        break
                    }
                }
                
                if containsBind && !containsObjc {
                    attributeSyntaxes.append("@objc")
                }
            }
            
            if let methodNode = member.as(FunctionDeclSyntax.self) {
                var containsObjc = false
                var containsBind = false
                
                for attribute in methodNode.attributes {
                    guard case let .attribute(macroNode) = attribute else {
                        continue;
                    }
                    switch macroNode.attributeName.trimmedDescription {
                    case "objc", "IBAction":
                        containsObjc = true
                    case "bind":
                        containsBind = true
                    case "prepare":
                        break
                    default:
                        break
                    }
                }
                
                if containsBind && !containsObjc {
                    attributeSyntaxes.append("@objc")
                }
            }
            
            return attributeSyntaxes
        }
        
        
    }
    
}

/// 宏 `@mocoa(role)` 的实现：
/// .vm => 为 @bind 的成员注册 mappingModelKeys 自动监听
/// .v  => 为 @bind 成员生成 viewModelDidChange 自动绑定
/// .m  => 暂不执行任何操作
extension XZMocoaMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw XZMacroError(message: "@mocoa: 只能应用于类")
        }
        
        let role = try XZMocoaRole.init(node: node, declaration: classDecl)
        
        switch role {
        case .m:
            return [];
            
        case .v:
            // 判断是否自定义 viewModelDidChange 方法
            for member in classDecl.memberBlock.members {
                if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                    let methodName = methodDecl.name.trimmedDescription
                    if methodName == "viewModelDidChange" {
                        XZMacroDiagnose(context, node: methodDecl, message: "@mocoa: 重写 viewModelDidChange 将会绑定实效，请使用 @prepare 标记初始化方法", severity: .warning)
                        return []
                    }
                }
            }
            
            var bindStatements = [String]()
            var prepareMethodNames = [String]()
            
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
                    
                    if macroNodes.isEmpty {
                        continue
                    }
                    
                    do {
                        let string = try XZMocoaBindMacro.viewBindStatements(forMacros: macroNodes, forVariable: variableDecl)
                        bindStatements.append(string)
                    } catch {
                        XZMacroDiagnose(context, node: variableDecl, error: error, severity: .warning)
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
                        case "bind": // 处理带 @bind 标记的属性。
                            do {
                                let string = try XZMocoaBindMacro.viewBindStatement(forMacro: macroNode, forFunction: methodDecl)
                                bindStatements.append(string)
                            } catch {
                                XZMacroDiagnose(context, node: methodDecl, error: error, severity: .warning)
                            }
                        case "prepare":
                            prepareMethodNames.append(methodDecl.name.text)
                            continue
                        default:
                            continue
                        }
                    }
                }
            }
            
            if bindStatements.isEmpty {
                if prepareMethodNames.isEmpty {
                    return []
                }
                let methodSyntax = try FunctionDeclSyntax(
                    """
                    override func viewModelDidChange() {
                        super.viewModelDidChange()
                        guard let viewModel = self.viewModel else { return }
                        // prepare
                        \(raw: prepareMethodNames.map({ "\($0)()" }).joined(separator: "\n"))
                    }
                    """
                )
                return [DeclSyntax(methodSyntax)]
            }
            
            let bindStatementString = bindStatements.joined(separator: "\n")
            
            if prepareMethodNames.isEmpty {
                let methodSyntax = try FunctionDeclSyntax(
                    """
                    override func viewModelDidChange() {
                        super.viewModelDidChange()
                        guard let viewModel = self.viewModel else { return }
                        // bind
                        \(raw: bindStatementString)
                    }
                    """
                )
                return [DeclSyntax(methodSyntax)]
            }
            
            let prepareStatementsString = prepareMethodNames.map({ "\($0)()" }).joined(separator: "\n")
            
            let methodSyntax = try FunctionDeclSyntax(
                """
                override func viewModelDidChange() {
                    super.viewModelDidChange()
                    guard let viewModel = self.viewModel else { return }
                    // bind
                    \(raw: bindStatementString)
                    // prepare
                    \(raw: prepareStatementsString)
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
                                if modifier.name.tokenKind == .keyword(.class) {
                                    XZMacroDiagnose(context, node: member, message: "@mocoa: 检测到已自定义 mappingModelKeys 属性，自动监听将不生效", severity: .warning)
                                    return []
                                }
                            }
                        }
                    }
                }
            }
            
            var mappingKeyValueStrings = [String]()
            var prepareMethodNames = [String]()
            
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
                        case "prepare":
                            prepareMethodNames.append(methodDecl.name.text)
                            continue
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
            
            var syntaxes = [DeclSyntax]()
            
            if !mappingKeyValueStrings.isEmpty {
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
                syntaxes.append(DeclSyntax(variableSyntax))
            }
            
            if !prepareMethodNames.isEmpty {
                let methodSyntax = try FunctionDeclSyntax(
                    """
                    override func prepare() {
                        super.prepare()
                        \(raw: prepareMethodNames.map({ "\($0)()" }).joined(separator: "\n"))
                    }
                    """
                )
                syntaxes.append(DeclSyntax(methodSyntax))
            }
            
            return syntaxes
        }
        
    }
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return try expansion(of: node, providingMembersOf: declaration, in: context)
    }
    
}
