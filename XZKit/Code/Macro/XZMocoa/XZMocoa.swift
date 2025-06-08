//
//  XZMocoaMacros.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/7.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

public enum MacroError: Error {
    case message(String)
}

public struct MocoaMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
//        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
//            throw MacroError.message("宏 @mocoa 只能应用于类")
//        }
//        
//        guard let _ = classDecl.inheritanceClause else {
//            throw MacroError.message("必须是对象类型")
//        }
//        
//        let mocoaProperties = classDecl.memberBlock.members.compactMap({ item in
//            // 过滤：获取所有属性
//            return item.decl.as(VariableDeclSyntax.self)
//        }).filter({ varDecl in
//            // 过滤：获取所有带 @mocoaKey 标记的属性
//            return varDecl.attributes.contains(where: { item in
//                switch item {
//                case .attribute(let attribute):
//                    return attribute.atSign.text == "@mocoaKey"
//                case .ifConfigDecl(_):
//                    return false
//                }
//            })
//        }).flatMap({ varDecl in
//            // 降维
//            return varDecl.bindings
//        }).compactMap({ binding -> String? in
//            // 获取属性名
//            return binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
//        })
        return []
        // 生成 Key 枚举
//        let MocoaKeyEnum = try EnumDeclSyntax("public enum Key: String") {
//            for name in mocoaProperties {
//                "case \(raw: name)"
//            }
//        }
//        
//        return [DeclSyntax(MocoaKeyEnum)]
    }
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return try expansion(of: node, providingMembersOf: declaration, in: context)
    }
    
}

//extension MocoaMacro: MemberAttributeMacro {
//    
//    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
//        
//        guard let member = member.as(VariableDeclSyntax.self) else { return [] }
//        
//        if let argument = node.arguments.first.expression.as(StringLiteralExprSyntax.self) {
//            
//        }
//        
//        return [.init(stringLiteral: "@objc")]
//    }
//    
//    
//}


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
            throw MacroError.message("只能为属性添加 @mocoaKey 声明");
        }
        
        guard declaration.bindingSpecifier.text == "var" else {
            throw MacroError.message("只能为 var 属性添加 @mocoaKey 声明")
        }
        
        guard let binding = declaration.bindings.first else { return [] }

        // 存储属性不生成
        if let _ = binding.initializer {
            return []
        }
        
        // 自定义了实现的
        if let block = binding.accessorBlock {
            switch block.accessors {
            case .accessors(let list):
                for item in list {
                    switch item.accessorSpecifier.text {
                    case "getter":
                        return []
                    case "willSet":
                        return []
                    case "set":
                        return []
                    case "didSet":
                        return []
                    default:
                        break
                    }
                }
                break
            case .getter:
                throw MacroError.message("只读计算属性不能添加 @mocoakey 声明");
            }
        }
        
        guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { return [] }
        
        guard let type = binding.typeAnnotation?.type else { return [] }
        
        return ["""
            var _\(raw: name): \(raw: type.trimmedDescription)
            """]
    }
    
}

/// 为 @mocoaKey(key) 生成 setter getter
extension MocoaKeyMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw MacroError.message("只能为属性添加 @mocoaKey 声明");
        }
        
        guard declaration.bindingSpecifier.text == "var" else {
            throw MacroError.message("只能为 var 属性添加 @mocoaKey 声明")
        }
        
        guard let binding = declaration.bindings.first else { return [] }
        
        var hasDidSet = false

        if let block = binding.accessorBlock {
            switch block.accessors {
            case .accessors(let list):
                for item in list {
                    switch item.accessorSpecifier.text {
                    case "getter":
                        return []
                    case "willSet":
                        return []
                    case "set":
                        return []
                    case "didSet":
                        hasDidSet = true
                    default:
                        break
                    }
                }
                break
            case .getter:
                throw MacroError.message("只读计算属性不能添加 @mocoaKey 声明");
            }
        }
        
        guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { return [] }
        
        /// 存储属性。
        if let _ = binding.initializer {
            if hasDidSet {
                return []
            }
            let _didSet = """
                didSet {
                    if oldValue != \(name) {
                        sendActions(forKey: "\(name)", value: newValue)
                    }
                }
                """
            return [AccessorDeclSyntax(stringLiteral: _didSet)]
        }
        
//        guard let type = binding.typeAnnotation?.type else { return [] }
        
        let getter = """
            get {
                return _\(name)
            }
            """
        let setter = """
            set {
                let oldValue = _\(name)
                _\(name) = newValue;
                if oldValue != newValue {
                    sendActions(forKey: "\(name)", value: newValue)
                }
            }
            """
        
        return [AccessorDeclSyntax(stringLiteral: getter), AccessorDeclSyntax(stringLiteral: setter)]
    }
    
}



 

import SwiftCompilerPlugin
import Foundation

@main
struct MocoaMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        MocoaMacro.self,
        MocoaKeyMacro.self
    ]
}
