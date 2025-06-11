//
//  XZMocoaBindMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

// @bind: 校验 @bind 标记的宏的合法性
public struct XZMocoaBindMacro {
    
    public static func isValid(macro node: SwiftSyntax.AttributeSyntax, declaration: FunctionDeclSyntax, in role: XZMocoaRole) throws {
        switch role {
        case .m:
            throw XZMocoaMacroError.message("@bind: 暂不支持 .m 角色")
            
        case .v:
            let methodArgumentsCount = declaration.signature.parameterClause.parameters.count;
            guard methodArgumentsCount <= 3 else {
                throw XZMocoaMacroError.message("@bind: 仅支持绑定 value、key-value、sender-key-value 三种参数形式的方法")
            }
            
            // 宏参数
            if let macroArguments = node.arguments {
                switch macroArguments {
                case .argumentList(let macroArguments):
                    switch macroArguments.count {
                    case 0:
                        break
                    case 1:
                        let expression = macroArguments[macroArguments.startIndex].expression
                        if expression.as(StringLiteralExprSyntax.self) == nil && expression.as(MemberAccessExprSyntax.self) == nil {
                            throw XZMocoaMacroError.message("@bind: 指定键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                    default:
                        throw XZMocoaMacroError.message("@bind: 仅可指定 key 一个参数")
                    }
                    
                default:
                    throw XZMocoaMacroError.message("@bind: 不支持绑定当前的键类型")
                }
            }
            
        case .vm:
            let methodArgumentsCount = declaration.signature.parameterClause.parameters.count;
            
            // 函数参数的数量
            guard methodArgumentsCount > 0 else {
                throw XZMocoaMacroError.message("@bind: 函数没有参数，无法接收被绑定的键值")
            }
            
            // 宏参数
            if let macroArguments = node.arguments {
                switch macroArguments {
                case .argumentList(let macroArguments):
                    switch macroArguments.count {
                    case 0:
                        break
                    case methodArgumentsCount:
                        let expression = macroArguments[macroArguments.startIndex].expression
                        if expression.as(StringLiteralExprSyntax.self) == nil && expression.as(MemberAccessExprSyntax.self) == nil {
                            throw XZMocoaMacroError.message("@bind: 指定键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                        break
                    default:
                        throw XZMocoaMacroError.message("@bind: 函数的参数与绑定的键数量不一致")
                    }

                default:
                    throw XZMocoaMacroError.message("@bind: 不支持绑定当前的键类型")
                }
            }
        }
    }
    
    public static func isValid(macro node: SwiftSyntax.AttributeSyntax, declaration: VariableDeclSyntax, in role: XZMocoaRole) throws {
        switch role {
        case .m:
            throw XZMocoaMacroError.message("@bind: 暂不支持 .m 角色")
            
        case .v:
            guard let propertyType = ({ (type: TypeSyntax?) -> (name: String, isOptional: Bool)? in
                guard let type = type else { return nil }
                if let op = type.as(OptionalTypeSyntax.self) {
                    return (op.wrappedType.trimmedDescription, true)
                }
                if let op = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                    return (op.wrappedType.trimmedDescription, true)
                }
                return (type.trimmedDescription, false)
            })(declaration.bindings.first?.typeAnnotation?.type) else {
                throw XZMocoaMacroError.message("@bind: 无法确定属性类型")
            }
            
            // 宏参数
            if let macroArguments = node.arguments {
                switch macroArguments {
                case .argumentList(let macroArguments):
                    switch macroArguments.count {
                    case 0:
                        switch propertyType.name {
                        case "UILabel":
                            break
                        case "UIImageView":
                            break;
                        default:
                            throw XZMocoaMacroError.message("@bind: 默认绑定还不支持 \(propertyType.name) 类型")
                        }
                    case 1:
                        let macroArgument = macroArguments[macroArguments.startIndex]
                        if let label = macroArgument.label?.trimmedDescription {
                            if label != "v" {
                                throw XZMocoaMacroError.message("@bind: 单个参数仅支持 v 标签（指定 View 属性）")
                            }
                        } else {
                            switch propertyType.name {
                            case "UILabel":
                                break
                            case "UIImageView":
                                break;
                            default:
                                throw XZMocoaMacroError.message("@bind: 默认绑定还不支持 \(propertyType.name) 类型")
                            }
                        }
                    case 2:
                        let firstExpression = macroArguments[macroArguments.startIndex].expression
                        if let stringValue = firstExpression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw XZMocoaMacroError.message("@bind: 绑定 vm 键名不能为空，若 vm 键与 v 属性同名，可在第一个参数前添加 v: 标签")
                            }
                        } else if firstExpression.as(MemberAccessExprSyntax.self) == nil {
                            throw XZMocoaMacroError.message("@bind: 绑定 vm 键名必须是 String 字面量或 XZMocoaKey 枚举值")
                        }
                        
                        let secondExpression = macroArguments[macroArguments.index(after: macroArguments.startIndex)].expression
                        if let stringValue = secondExpression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw XZMocoaMacroError.message("@bind: 绑定 v 键名不能为空；若 v 支持默认键名，请不要提供第二参数")
                            }
                        } else if secondExpression.as(MemberAccessExprSyntax.self) == nil {
                            throw XZMocoaMacroError.message("@bind: 绑定 v 键名必须是 String 字面量或 XZMocoaKey 枚举值")
                        }
                        
                    default:
                        throw XZMocoaMacroError.message("@bind: 绑定 v 属性仅支持 (.vmKey)、(v: .vKey)、(vmKey, vKey) 三种形式的参数")
                    }
                    
                default:
                    throw XZMocoaMacroError.message("@bind: 不支持绑定当前的键类型")
                }
            }
            
        case .vm:
            // 宏参数
            if let macroArguments = node.arguments {
                switch macroArguments {
                case .argumentList(let macroArguments):
                    switch macroArguments.count {
                    case 0:
                        break
                    case 1:
                        let expression = macroArguments[macroArguments.startIndex].expression
                        if let stringValue = expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw XZMocoaMacroError.message("@bind: 绑定 vm 键名不能为空，若 m 键与 vm 属性同名，可省略参数")
                            }
                        } else if expression.as(MemberAccessExprSyntax.self) == nil {
                            throw XZMocoaMacroError.message("@bind: 绑定 vm 属性的键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                        break
                    default:
                        throw XZMocoaMacroError.message("@bind: 绑定 vm 属性仅支持一个参数")
                    }

                default:
                    throw XZMocoaMacroError.message("@bind: 不支持绑定当前的键类型")
                }
            }
        }
    }
    
}

extension XZMocoaBindMacro: PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        // do nothing, but check in @mocoa macro, because there is no common check for all roles.
        
        // TODO: - 视图可选属性绑定 vm 键，是否可以添加 didSet 绑定 vm
        
        return []
    }
    
}

/*
/// 实现 `#bind(text: UILabel)` 宏
public struct MocoaBindLabelMacro: ExpressionMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        let arguments = node.arguments
        
        switch arguments.count {
        case 0:
            throw XZMocoaMacroError.message("#bind: 缺少参数")
        case 1:
            throw XZMocoaMacroError.message("#bind: 参数不足，至少需要提供 view 和 viewModel 两个参数")
        case 2:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "text":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UILabel.text), forKey: .text, value: nil)"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
        case 3:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "text":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let key = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UILabel.text), forKey: \(raw: key), value: nil)"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
        case 4:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "text":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let key = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let value = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UILabel.text), forKey: \(raw: key), value: \(raw: value))"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
            
        default:
            throw XZMocoaMacroError.message("#bind: 暂不支持")
        }
    }
    
}

/// 实现 `#bind(text: UITextView)` 宏
public struct MocoaBindTextViewMacro: ExpressionMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        let arguments = node.arguments
        
        switch arguments.count {
        case 0:
            throw XZMocoaMacroError.message("#bind: 缺少参数")
        case 1:
            throw XZMocoaMacroError.message("#bind: 参数不足，至少需要提供 view 和 viewModel 两个参数")
        case 2:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "text":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UITextView.text), forKey: .text, value: nil)"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
        case 3:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "text":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let key = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UITextView.text), forKey: \(raw: key), value: nil)"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
        case 4:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "text":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let key = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let value = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UITextView.text), forKey: \(raw: key), value: \(raw: value))"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
            
        default:
            throw XZMocoaMacroError.message("#bind: 暂不支持")
        }
    }
    
}

/// 实现 `#bind(text: UIImageView)` 宏
public struct MocoaBindImageViewMacro: ExpressionMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        let arguments = node.arguments
        
        switch arguments.count {
        case 0:
            throw XZMocoaMacroError.message("#bind: 缺少参数")
        case 1:
            throw XZMocoaMacroError.message("#bind: 参数不足，至少需要提供 view 和 viewModel 两个参数")
        case 2:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "image":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UIImageView.image), forKey: .text, value: nil)"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
        case 3:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "image":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let key = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UIImageView.image), forKey: \(raw: key), value: nil)"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
        case 4:
            var index = arguments.startIndex
            guard let label = arguments[index].label?.trimmedDescription else {
                throw XZMocoaMacroError.message("#bind: 缺少标签")
            }
            switch label {
            case "image":
                let view = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let viewModel = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let key = arguments[index].expression.trimmedDescription
                index = arguments.index(after: index)
                let value = arguments[index].expression.trimmedDescription
                return "\(raw: viewModel).addTarget(\(raw: view), action: #selector(setter: UIImageView.image), forKey: \(raw: key), value: \(raw: value))"
            default:
                throw XZMocoaMacroError.message("#bind: 暂不支持")
            }
            
        default:
            throw XZMocoaMacroError.message("#bind: 暂不支持")
        }
    }
    
}
*/
