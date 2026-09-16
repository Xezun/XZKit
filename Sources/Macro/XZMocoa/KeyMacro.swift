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
    
    
    public static func keyName(from node: SwiftSyntax.AttributeSyntax) throws -> String? {
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
}

/// 宏 `@key("key")` 的实现： 生成 setter/getter 方法。
extension KeyMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        switch try MocoaRole(node: node, context: context) {
        case .m:
            guard let propertyDecl = declaration.as(VariableDeclSyntax.self) else {
                throw XZMacroError.init(message: "@key: 仅支持属性")
            }
            guard propertyDecl.contains(modifier: .dynamic) else {
                throw XZMacroError.init(message: "@key: 属性需添加 dynamic 修饰符")
            }
            // 由 @mocoa 宏添加 @objc 标记 + dynamic 标记，以支持 KVO
            return []
            
        case .v:
            throw XZMacroError(message: "@key: 不支持在 View 角色中使用")
            
        case .vm:
            guard let propertyDecl = declaration.as(VariableDeclSyntax.self) else {
                throw XZMacroError.init(message: "@key: 仅支持属性")
            }
            
            // 只读属性，不添加 didSet 方法
            if propertyDecl.isReadOnlyProperty {
                return []
            }
            
            // 获取属性声明
            guard let expression = propertyDecl.bindings.first else {
                throw XZMacroError(message: "@key: 宏无法确定属性名")
            }
            
            // 获取属性名
            guard let propertyName = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                throw XZMacroError(message: "@key: 宏无法确定属性名")
            }
            
            // 获取属性类型
            guard let type = expression.typeAnnotation?.type else {
                throw XZMacroError(message: "@key: 宏无法确定属性类型，请用 var name: Type 的形式声明属性")
            }
            
            // key 名
            let key = try self.keyName(from: node) ?? propertyName
            
            var keyValue = "newValue"
            if type.is(OptionalTypeSyntax.self) || type.is(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                keyValue = "newValue ?? kCFNull"
            }
            
            return [
                """
                didSet {
                    let newValue = \(raw: propertyName)
                    if newValue != oldValue {
                        sendActions(forKey: "\(raw: key)", value: \(raw: keyValue))
                    }
                }
                """
            ]
            
        }
    }
    
}
