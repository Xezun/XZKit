//
//  XZMocoaBindMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

// 不带参数标签的 `@bind` 宏的实现。
public struct XZMocoaBindMacro {
    
    public enum OptionalType {
        /// 非可选
        case unwrapped
        /// 可选
        case wrapped
        /// 隐式可选
        case autoUnwrapped
    }
    
    public static func type(forVariable variableDecl: VariableDeclSyntax) throws -> (name: String, optional: OptionalType) {
        guard let expression = variableDecl.bindings.first else {
            throw Message("@bind: 没有找到属性类型")
        }
        
        // 示例：var textLabel: UILabel!
        if let type = expression.typeAnnotation?.type {
            if let op = type.as(OptionalTypeSyntax.self) {
                return (op.wrappedType.trimmedDescription, .wrapped)
            }
            
            if let op = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                return (op.wrappedType.trimmedDescription, .autoUnwrapped)
            }
            
            return (type.trimmedDescription, .unwrapped)
        }
        
        // 示例：var textLabel = UILabel.init()
        if expression.initializer != nil {
            throw Message("@bind: 无法推断属性类型，请使用 var view: UIView = .init() 的形式初始化属性")
            // 由于表达式的返回值值及返回值的可选性无法推断，因此如下获取获取类型，必准确
            //if let expression = initializer.value.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base {
            //    return (expression.trimmedDescription, .unwrapped)
            //}
        }
        
        throw Message("@bind: 无法解析属性类型")
    }
    
    public static func arguments(forMacro macroNode: SwiftSyntax.AttributeSyntax, forVariable typeName: String) throws -> (selector: String, key: String) {
        // 获取宏参数
        let macroArguments = macroNode.arguments?.arrayRepresentation ?? []
        
        var selector = ""
        var vmkey    = ""
        
        switch macroArguments.count {
        case 0:
            switch typeName {
            case "UILabel":
                vmkey = ".text"
                selector = "#selector(setter: UILabel.text)"
            case "UITextView":
                vmkey = ".text"
                selector = "#selector(setter: UITextView.text)"
            case "UIImageView":
                vmkey = ".image"
                selector = "#selector(setter: UIImageView.image)"
            default:
                throw Message("@bind: 暂未为 \(typeName) 类型提供默认支持")
            }
            
        case 1:
            let macroArgument = macroArguments[0]
            if macroArgument.label == nil {
                vmkey = macroArgument.value
                switch typeName {
                case "UILabel":
                    selector = "#selector(setter: UILabel.text)"
                case "UITextView":
                    selector = "#selector(setter: UITextView.text)"
                case "UIImageView":
                    selector = "#selector(setter: UIImageView.image)"
                default:
                    throw Message("@bind: 暂未为 \(typeName) 类型提供默认支持")
                }
            } else {
                vmkey = macroArgument.value
                if let key = macroArgument.representedLiteralValue {
                    selector = "#selector(setter: \(typeName).\(key))"
                } else {
                    selector = "#selector(setter: \(typeName)\(vmkey))"
                }
            }
        case 2:
            vmkey = macroArguments[0].value
            if macroArguments[1].label == "selector" {
                selector = macroArguments[1].value
            } else if let key = macroArguments[1].representedLiteralValue {
                selector = "#selector(setter: \(typeName).\(key))"
            } else {
                selector = "#selector(setter: \(typeName)\(macroArguments[1].value))"
            }
            
        default:
            throw Message("@bind: 参数错误，仅支持两个个参数")
        }
        
        return (selector, vmkey)
    }
    
    public static func statements(forMacro macroNodes: [SwiftSyntax.AttributeSyntax], forVariable declaration: VariableDeclSyntax) throws -> String {
        if macroNodes.isEmpty {
            return ""
        }
        
        guard let propertyName = declaration.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw Message("@bind: 无法确定属性名")
        }
        
        let propertyType = try Self.type(forVariable: declaration)
        
        let statements = try macroNodes.map({ macroNode throws -> String in
            let arguments = try Self.arguments(forMacro: macroNode, forVariable: propertyType.name)
            return "viewModel.addTarget(\(propertyName), action: \(arguments.selector), forKey: \(arguments.key), value: nil)"
        }).joined(separator: "\n")
        
        if propertyType.optional != .unwrapped {
            return "if let \(propertyName) = self.\(propertyName) { \(statements) }"
        }
        return statements
    }
    
    public static func arguments(forMacro macroNode: SwiftSyntax.AttributeSyntax, forFunction declaration: FunctionDeclSyntax) throws -> (selector: String, key: String) {
        var vmKey = macroNode.arguments?.first?.value
        
        // 遍历方法参数，拼接方法名
        var selector = "#selector(Self.\(declaration.name.text)("
        for parameter in declaration.signature.parameterClause.parameters {
            selector += parameter.firstName.text + ":"
            
            if vmKey == nil {
                vmKey = "\"\(parameter.secondName?.text ?? parameter.firstName.text)\""
            }
        }
        selector += "))"
        
        guard let vmKey = vmKey else {
            throw Message("@bind: 无法确定要绑定的视图模型的键名")
        }
        
        return (selector, vmKey)
    }
    
    public static func statement(forMacro macroNode: SwiftSyntax.AttributeSyntax, forFunction declaration: FunctionDeclSyntax) throws -> String {
        let arguments = try Self.arguments(forMacro: macroNode, forFunction: declaration)
        return "viewModel.addTarget(self, action: \(arguments.selector), forKey: \(arguments.key), value: nil)"
    }
    
    public static func isValid(forMacro node: SwiftSyntax.AttributeSyntax, forFunction declaration: FunctionDeclSyntax, for role: XZMocoaRole) throws {
        switch role {
        case .m:
            throw Message("@bind: 暂不支持 .m 角色")
            
        case .v:
            let methodArgumentsCount = declaration.signature.parameterClause.parameters.count;
            guard methodArgumentsCount <= 3 else {
                throw Message("@bind: 仅支持绑定 value、key-value、sender-key-value 三种参数形式的方法")
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
                            throw Message("@bind: 指定键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                    default:
                        throw Message("@bind: 仅可指定 key 一个参数")
                    }
                    
                default:
                    throw Message("@bind: 不支持绑定当前的键类型")
                }
            }
            
        case .vm:
            let methodArgumentsCount = declaration.signature.parameterClause.parameters.count;
            
            // 函数参数的数量
            guard methodArgumentsCount > 0 else {
                throw Message("@bind: 函数没有参数，无法接收被绑定的键值")
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
                            throw Message("@bind: 指定键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                        break
                    default:
                        throw Message("@bind: 函数的参数与绑定的键数量不一致")
                    }

                default:
                    throw Message("@bind: 不支持绑定当前的键类型")
                }
            }
        }
    }
    
    public static func isValid(forMacro node: SwiftSyntax.AttributeSyntax, forVariable declaration: VariableDeclSyntax, for role: XZMocoaRole) throws -> OptionalType {
        switch role {
        case .m:
            throw Message("@bind: 暂不支持 .m 角色")
            
        case .v:
            
            let propertyType = try self.type(forVariable: declaration)
            
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
                            throw Message("@bind: 默认绑定还不支持 \(propertyType.name) 类型")
                        }
                    case 1:
                        let macroArgument = macroArguments[macroArguments.startIndex]
                        if let label = macroArgument.label?.trimmedDescription {
                            if label != "v" {
                                throw Message("@bind: 单个参数仅支持 v 标签（指定 View 属性）")
                            }
                        } else {
                            switch propertyType.name {
                            case "UILabel":
                                break
                            case "UIImageView":
                                break;
                            default:
                                throw Message("@bind: 默认绑定还不支持 \(propertyType.name) 类型")
                            }
                        }
                    case 2:
                        let firstExpression = macroArguments[macroArguments.startIndex].expression
                        if let stringValue = firstExpression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw Message("@bind: 第一个参数不能为空，若仅指定 v 属性名，可使用 @bind(v:) 宏")
                            }
                        } else if firstExpression.as(MemberAccessExprSyntax.self) == nil {
                            throw Message("@bind: 绑定 vm 键名必须是 String 字面量或 XZMocoaKey 枚举值")
                        }
                        
                        let secondExpression = macroArguments[macroArguments.index(after: macroArguments.startIndex)].expression
                        if let stringValue = secondExpression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw Message("@bind: 绑定 v 键名不能为空；若 v 支持默认键名，请不要提供第二参数")
                            }
                        } else if secondExpression.as(MemberAccessExprSyntax.self) == nil {
                            throw Message("@bind: 绑定 v 键名必须是 String 字面量或 XZMocoaKey 枚举值")
                        }
                        
                    default:
                        throw Message("@bind: 仅支持 (.vmKey)、(.vmKey, .vKey) 两种形式的参数")
                    }
                    
                default:
                    throw Message("@bind: 不支持绑定当前的键类型")
                }
            }
            
            return propertyType.optional
            
        case .vm:
            // 宏参数
            if let macroArguments = node.arguments {
                switch macroArguments {
                case .argumentList(let macroArguments):
                    switch macroArguments.count {
                    case 0:
                        break
                    case 1:
                        let macroArgument = macroArguments[macroArguments.startIndex]
                        if let label = macroArgument.label, label.trimmedDescription.count > 0 {
                            throw Message("@bind: 在 .vm 上不支持该绑定，请移除参数标签")
                        }
                        let expression = macroArgument.expression
                        if let stringValue = expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw Message("@bind: 绑定 vm 键名不能为空，若 m 键与 vm 属性同名，可省略参数")
                            }
                        } else if expression.as(MemberAccessExprSyntax.self) == nil {
                            throw Message("@bind: 绑定 vm 属性的键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                        break
                    default:
                        throw Message("@bind: 绑定 vm 属性仅支持一个参数")
                    }

                default:
                    throw Message("@bind: 不支持绑定当前的键类型")
                }
            }
        }
        
        return .unwrapped
    }
    
}

extension XZMocoaBindMacro: PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        // 无法通过 node 或 method 的 declaration 属性找到上级，无法确定 role 所以无法验证
        return []
    }
    
}

public struct XZMocoaBindViewMacro {
    
}

extension XZMocoaBindViewMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw Message("@bind(v:) 仅支持属性")
        }
        
        for binding in declaration.bindings {
            guard let accessorBlock = binding.accessorBlock else {
                continue
            }
            switch accessorBlock.accessors {
            case .getter:
                throw Message("@bind: 只读计算属性不能绑定")
            case .accessors(let accessors):
                for accessor in accessors {
                    switch accessor.accessorSpecifier.text {
                    case "didSet":
                        context.diagnose(.init(node: node, message: Message("@oberve: 已自定义 didSet 无法绑定监听，请在 didSet 中自行处理", severity: .warning)))
                        return []
                    default:
                        break
                    }
                }
            }
        }
        
        guard try XZMocoaBindMacro.type(forVariable: declaration).optional == .wrapped else {
            return []
        }
        
        let statements = try XZMocoaBindMacro.statements(forMacro: declaration.attributes.compactMap({ attribute in
            switch attribute {
            case .attribute(let macroNode):
                if macroNode.attributeName.trimmedDescription == "bind" {
                    return macroNode
                }
                return nil
            case .ifConfigDecl:
                return nil
            }
        }), forVariable: declaration)
        
        return [
            """
            didSet {
                guard let viewModel = self.viewModel else { return }
                \(raw: statements)
            }
            """
        ]
    }
    
}

