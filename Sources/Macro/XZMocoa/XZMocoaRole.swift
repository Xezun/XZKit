//
//  XZMocoaRole.swift
//  XZKit
//
//  Created by Xezun on 2025/6/7.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

public enum XZMocoaRole: String {
    
    case m
    
    case v
    
    case vm
    
    /// 获取 class 角色。
    /// - Parameters:
    ///   - node: 附属于指定 class 的 `@mocoa(role)` 宏
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
                        if let role = XZMocoaRole.init(rawValue: roleValue) {
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
                        self = try XZMocoaRole.init(node: node, declaration: classDecl)
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



