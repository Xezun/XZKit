//
//  MocoaMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

/// 为成员添加 `@objc` 修饰属性。
/// 宏 `@mocoa(role)` 的实现：
/// .m  => 为 @key 标记的属性添加 @objc 标记，以支持 KVO 通知
/// .v  => 为 @bind / @link 标记的方法添加 @objc 标记，以支持 KTA 绑定（视图属性通过 setter 选择器绑定，无需 @objc）
/// .vm => 为 @key / @bind / @link 标记的属性和方法添加 @objc 标记
public struct MocoaMacro: MemberAttributeMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw XZMacroError(message: "@mocoa: 仅可用于 class 的声明")
        }
        
        let role = try XZMacroMocoaRole.init(node: node, declaration: classDecl)
        
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
/// .vm => 为 @bind / @link 的成员注册 `mappingObserverMethodsForModelKeys` 自动监听
/// .v  => 为 @bind / @link 成员生成 `__mocoa_bind_prepare` 自动绑定
/// .m  => 暂不执行任何操作
extension MocoaMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw XZMacroError(message: "@mocoa: 只能应用于 class 类")
        }
        
        switch try XZMacroMocoaRole.init(node: node, declaration: classDecl) {
        case .m:
            return [];
            
        case .v:
            // 判断是否自定义 __mocoa_bind_prepare 方法
            if classDecl.containsMethod("__mocoa_bind_prepare") {
                throw XZMacroError(node, message: "重写私有方法 __mocoa_bind_prepare 方法会导致绑定失效，请使用 prepareForViewModel 方法代替")
            }
            
            var statements = [String]()
            
            for member in classDecl.memberBlock.members {
                if let propertyDecl = member.decl.as(VariableDeclSyntax.self) {
                    let property = try XZMacroPropertyInfomation(node, propertyDecl)
                    if let statement = try BindMacro.expansion(view: node, providingStatementsOf: property, in: context) {
                        statements.append(statement)
                    }
                }
                if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                    let method = XZMacroMethodInformation(node, methodDecl)
                    if let statement = try BindMacro.expansion(view: node, providingStatementsOf: method, in: context) {
                        statements.append(statement)
                    }
                }
            }
            
            if statements.isEmpty {
                return []
            }
            
            // 增加内部的缩进
            statements = statements.map({ statement in
                return statement.replacingOccurrences(of: "\n    ", with: "\n        ")
            })
            
            let methodSyntax = try FunctionDeclSyntax(
                """
                override func __mocoa_bind_prepare() {
                    super.__mocoa_bind_prepare()
                    guard let viewModel = self.viewModel else { return }
                    \(raw: statements.joined(separator: "\n    "))
                }
                """
            )
            return [DeclSyntax(methodSyntax)]
            
        case .vm:
            // 判断是否自定义 mappingObserverMethodsForModelKeys 属性
            if classDecl.containsProperty("mappingObserverMethodsForModelKeys") {
                for member in classDecl.memberBlock.members {
                    if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                        if let node = variableDecl.attributeForName("bind") {
                            XZMacroDiagnose(context, node: node, message: "由于已重写 mappingObserverMethodsForModelKeys 属性，宏 @bind 监听将不生效", severity: .warning)
                        }
                        if let node = variableDecl.attributeForName("link") {
                            XZMacroDiagnose(context, node: node, message: "由于已重写 mappingObserverMethodsForModelKeys 属性，宏 @link 绑定将不生效", severity: .warning)
                        }
                    }
                    if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                        if let node = methodDecl.attributeForName("bind") {
                            XZMacroDiagnose(context, node: node, message: "由于已重写 mappingObserverMethodsForModelKeys 属性，宏 @bind 监听将不生效", severity: .warning)
                        }
                        if let node = methodDecl.attributeForName("link") {
                            XZMacroDiagnose(context, node: node, message: "由于已重写 mappingObserverMethodsForModelKeys 属性，宏 @link 绑定将不生效", severity: .warning)
                        }
                    }
                }
                return []
            }
            
            if classDecl.containsProperty("activelyObservedModelKeys") {
                for member in classDecl.memberBlock.members {
                    if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                        if let node = variableDecl.attributeForName("bind") {
                            XZMacroDiagnose(context, node: node, message: "由于已重写 activelyObservedModelKeys 属性，宏 @bind 监听将不生效", severity: .warning)
                        }
                        if let node = variableDecl.attributeForName("link") {
                            XZMacroDiagnose(context, node: node, message: "由于已重写 activelyObservedModelKeys 属性，宏 @link 绑定将不生效", severity: .warning)
                        }
                    }
                    if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                        if let node = methodDecl.attributeForName("bind") {
                            XZMacroDiagnose(context, node: node, message: "由于已重写 activelyObservedModelKeys 属性，宏 @bind 监听将不生效", severity: .warning)
                        }
                        if let node = methodDecl.attributeForName("link") {
                            XZMacroDiagnose(context, node: node, message: "由于已重写 activelyObservedModelKeys 属性，宏 @link 绑定将不生效", severity: .warning)
                        }
                    }
                }
                return []
            }
            
            var mappingStatements = [String]()  // mappingObserverMethodsForModelKeys 的语句
            var bindKeys = Set<String>()  // @bind 标记的 key，用于 activelyObservedModelKeys
            var linkNodes = [(node: AttributeSyntax, keys: [String])]()  // @link 标记的 key，排除出 activelyObservedModelKeys
            
            for member in classDecl.memberBlock.members {
                if let propertyDecl = member.decl.as(VariableDeclSyntax.self) {
                    let property = try XZMacroPropertyInfomation(node, propertyDecl)
                    if let result = try BindMacro.expansion(viewModel: node, providingStatementsOf: property, in: context) {
                        mappingStatements.append(result.statements)
                        bindKeys.formUnion(result.bindKeys)
                        linkNodes.append(contentsOf: result.linkNodes)
                    }
                    continue
                }
                
                if let methodDecl = member.decl.as(FunctionDeclSyntax.self) {
                    let method = XZMacroMethodInformation(node, methodDecl)
                    if let result = try BindMacro.expansion(viewModel: node, providingStatementsOf: method, in: context) {
                        mappingStatements.append(result.statements)
                        bindKeys.formUnion(result.bindKeys)
                        linkNodes.append(contentsOf: result.linkNodes)
                    }
                    continue
                }
            }
            
            // 发送 @link 隐式升级为 @bind 警告
            for linkNode in linkNodes {
                if bindKeys.isDisjoint(with: linkNode.keys) {
                    continue
                }
                XZMacroDiagnose(context, node: linkNode.node, message: "由于键被 @bind 绑定，键已成为主动观察键，请修改为 @bind 以消除警告", severity: .warning)
            }
            
            var generatedDecls: [DeclSyntax] = []
            
            // 生成 mappingObserverMethodsForModelKeys
            if !mappingStatements.isEmpty {
                let dictionaryElements = mappingStatements.joined(separator: ", \n")
                let variableSyntax = try VariableDeclSyntax(
                    """
                    public override class var mappingObserverMethodsForModelKeys: [String : Any]? {
                        return [ 
                            \(raw: dictionaryElements)
                        ]
                    }
                    """
                )
                generatedDecls.append(DeclSyntax(variableSyntax))
            }
            
            // 生成 activelyObservedModelKeys：只包含 @bind 标记的键，排除 @link 标记的键
            if !bindKeys.isEmpty {
                // 生成数组元素
                let arrayElements = bindKeys.joined(separator: ", ")
                let observedVariableSyntax = try VariableDeclSyntax(
                    """
                    public override class var activelyObservedModelKeys: [String]? {
                        return [\(raw: arrayElements)]
                    }
                    """
                )
                generatedDecls.append(DeclSyntax(observedVariableSyntax))
            }
            
            return generatedDecls
        }
        
    }
    
}





