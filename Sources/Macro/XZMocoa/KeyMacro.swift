//
//  KeyMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

// @key
// @key("name")

public struct KeyMacro {
    
    /// 解析 `@key` 宏的参数。供外部调用。
    public static func arguments(from node: SwiftSyntax.AttributeSyntax, for declaration: VariableDeclSyntax) throws -> String {
        guard let expression = declaration.bindings.first else {
            throw XZMacroError(message: "@key: 无法确定属性名")
        }
        return try arguments(forMacro: node, forVariable: expression)
    }
    
    /// 解析 `@key` 宏的参数。
    /// - Parameters:
    ///   - node: 宏节点
    ///   - expression: 属性表达式
    /// - Returns: 键名 name
    public static func arguments(forMacro node: SwiftSyntax.AttributeSyntax, forVariable expression: PatternBindingSyntax) throws -> String {
        guard let macroArguments = node.arguments else {
            guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                throw XZMacroError(message: "@key: 无法确定属性名")
            }
            return name
        }
        return try arguments(fromMacro: macroArguments, forVariable: expression)
    }
    
    /// 解析宏 `@key` 的参数。
    private static func arguments(fromMacro arguments: SwiftSyntax.AttributeSyntax.Arguments, forVariable expression: PatternBindingSyntax) throws -> String {
        switch arguments {
        case .argumentList(let arguments):
            switch arguments.count {
            case 0:
                // 没有参数，使用属性名
                guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                    throw XZMacroError(message: "@key: 无法确定属性名")
                }
                return name
                
            case 1:
                let firstArgument = arguments[arguments.startIndex]
                
                // 仅支持无标签的键名参数，初始值由属性自身的初始化表达式提供。
                if let label = firstArgument.label?.trimmedDescription {
                    throw XZMacroError(message: "@key: 不支持 \(label) 标签参数，仅支持指定键名")
                }
                
                if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
                    if let stringValue = stringLiteral.representedLiteralValue?.replacingOccurrences(of: ".", with: "_"), stringValue.count > 0 {
                        return stringValue
                    }
                } else if let mocoaKeySyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
                    let mocoaKey = mocoaKeySyntax.declName.trimmedDescription
                    return mocoaKey
                }
                
                throw XZMacroError(message: "@key: 第一个参数必须为 String 字面量或 XZMocoaKey 枚举，而不能是 \(firstArgument.expression) 值")
                
            default:
                throw XZMacroError(message: "@key: 最多支持一个参数（name）")
                
            }
        default:
            throw XZMacroError(message: "@key: not supported arguments \(arguments)")
        }
    }
    
    /// 返回 @key 宏通过参数指定的键名，返回 nil 表示没有提供参数。返回值也可能是 keyPath 形式。
    public static func nameForKeyMacro(_ node: SwiftSyntax.AttributeSyntax) throws -> String? {
        guard let firstArgument = node.arguments?.first?.value else {
            return nil
        }
            
        if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
            // 字符串有插值时 representedLiteralValue 返回 nil
            guard let key = stringLiteral.representedLiteralValue else {
                throw XZMacroError(message: "@key: 仅支持静态字符串")
            }
            return key
        }
        
        guard var memberSyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) else {
            return nil
        }
        
        // declName 为最后一个点，后面的部分
        var keyPath = memberSyntax.declName.trimmedDescription;
        
        while let base = memberSyntax.base?.as(MemberAccessExprSyntax.self) {
            keyPath = "\(base.declName.trimmedDescription).\(keyPath)"
            memberSyntax = base
        }
        
        return keyPath
    }
    
    /// 为 @key 宏标记的属性，添加 @objc 标记。
    /// - Parameters:
    ///   - node: `@key` 宏
    ///   - declaration: 宏所修饰的属性
    ///   - context: 上下文
    /// - Returns: 属性
    public static func expansion(of node: AttributeSyntax, providingAttributesFor declaration: VariableDeclSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        // 已包含 @objc
        if declaration.containsAttribute("objc") {
            return []
        }
        
        if let key = try self.nameForKeyMacro(node) {
            return ["@objc(\(raw: key))"]
        }
        
        return ["@objc"]
    }
}

/// 宏 `@key("key")` 的实现： 生成 setter/getter 方法。
extension KeyMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        // 属性
        guard let propertyDecl = declaration.as(VariableDeclSyntax.self) else {
            throw XZMacroError.init(message: "@key: 仅支持属性")
        }
        
        // 只读属性
        if propertyDecl.isReadOnlyProperty {
            return []
        }
        
        // 获取属性名
        guard let propertyName = propertyDecl.name else {
            throw XZMacroError(message: "@key: 宏无法确定属性名")
        }
        
        switch try MocoaRole(node: node, context: context) {
        case .m:
            // 包含 set 或 didSet 就无法重写
            if propertyDecl.containsAccessors(["set", "didSet"]) {
                // 检测属性是否包含 didChangeValue 方法调用，以是否包含 didChangeValue 简单判断，不实质判断。
                if !propertyDecl.trimmedDescription.contains("didChangeValue") {
                    XZMacroDiagnose(context, node: node, message: "@key: 无法添加 didSet 方法，请自行调用 didChangeValue(forKey:) 方法触发监听", severity: .warning)
                }
                return []
            }
            
            // 由 @mocoa 宏添加 @objc 标记 + dynamic 标记，以支持 KVO
            let key = try self.nameForKeyMacro(node) ?? propertyName
            
            return [
                """
                didSet {
                    if \(raw: propertyName) == oldValue {
                        return
                    }
                    didChangeValue(forKey: "\(raw: key)")
                }
                """
            ]
            
        case .v:
            throw XZMacroError(message: "@key: 不支持在 View 角色中使用")
            
        case .vm:
            // 包含 set 或 didSet 就无法重写
            if propertyDecl.containsAccessors(["set", "didSet"]) {
                // 检测属性是否包含 didChangeValue 方法调用，以是否包含 sendActions 简单判断，不实质判断。
                if !propertyDecl.trimmedDescription.contains("sendActions") {
                    XZMacroDiagnose(context, node: node, message: "@key: 无法添加 didSet 方法，请自行调用 sendActions(forKey:) 方法触发监听", severity: .warning)
                }
                return []
            }
            
            // key 名
            let key = try self.nameForKeyMacro(node) ?? propertyName
            
            return [
                """
                didSet {
                    if \(raw: propertyName) == oldValue {
                        return
                    }
                    sendActions(forKey: "\(raw: key)")
                }
                """
            ]
            
        }
    }
    
}
