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
public struct XZMocoaBindMacro: PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        // 绑定函数
        if let method = declaration.as(FunctionDeclSyntax.self) {
            // 函数参数的数量
            if method.signature.parameterClause.parameters.count == 0 {
                throw XZMocoaMacroError.message("@bind: 函数的参数必须与绑定的键一一对应")
            }
            
            // 宏参数
            if let arguments = node.arguments {
                switch arguments {
                case .argumentList(let list):
                    // 宏的参数必须为 0 或者与方法的参数相同
                    if list.count == 0 {
                        return []
                    }
                    if list.count != method.signature.parameterClause.parameters.count {
                        throw XZMocoaMacroError.message("@bind: 函数的参数与绑定的键数量不一致")
                    }
                    if list.contains(where: { item in
                        return item.expression.as(StringLiteralExprSyntax.self) == nil
                    }) {
                        throw XZMocoaMacroError.message("@bind: 指定键名必须为 String 字面量")
                    }
                    return []
                default:
                    throw XZMocoaMacroError.message("@bind: 必须指定当前函数所监听 key 键")
                }
            }
        }
        
        if let _ = declaration.as(VariableDeclSyntax.self) {
            return [] // TODO: 绑定属性校验
        }
        
        return []
    }

}

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
