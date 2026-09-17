//
//  KeyMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

/// @key 宏的实现：为 Model、ViewModel 带 @key 宏的标记，生成 didSet 方法。
public struct KeyMacro: AccessorMacro {
    
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
                    XZMacroDiagnose(context, node: node, message: "无法添加 didSet 方法，请自行调用 didChangeValue(forKey:) 方法触发监听", severity: .warning)
                }
                return []
            }
            
            // 由 @mocoa 宏添加 @objc 标记 + dynamic 标记，以支持 KVO
            let key = try node.mocoaKeyFromArgument(at: 0) ?? propertyName
            
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
                    XZMacroDiagnose(context, node: node, message: "无法添加 didSet 方法，请自行调用 sendActions(forKey:) 方法触发监听", severity: .warning)
                }
                return []
            }
            
            // key 名
            let key = try node.mocoaKeyFromArgument(at: 0) ?? propertyName
            
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

extension KeyMacro {
    
    /// 供 @mooca 宏调用，为 @key 宏标记的属性，添加 @objc 标记。
    ///
    /// 调用此方法前 @mocoa 宏已确定所有参数类型。
    /// - Parameters:
    ///   - node: `@key` 宏
    ///   - declaration: 被 @key 宏修饰的属性
    ///   - context: @mocoa 宏的上下文
    /// - Returns: 属性
    public static func expansion(of node: AttributeSyntax, providingAttributesFor declaration: VariableDeclSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        // 已包含 @objc
        if declaration.containsAttributes(["objc", "NSManaged", "IBOutlet"], .or) {
            return []
        }
        
        if let key = try node.mocoaKeyFromArgument(at: 0) {
            return ["@objc(\(raw: key))"]
        }
        
        return ["@objc"]
    }
    
}
