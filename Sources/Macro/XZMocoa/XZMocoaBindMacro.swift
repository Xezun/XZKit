//
//  XZMocoaBindMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/10.
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
            throw XZMacroError(message: "@bind: 没有找到属性类型")
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
            throw XZMacroError(message: "@bind: 请使用 var view: UIView = .init() 的形式初始化属性")
            // 由于表达式的返回值值及返回值的可选性无法推断，因此如下获取获取类型，必准确
            //if let expression = initializer.value.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base {
            //    return (expression.trimmedDescription, .unwrapped)
            //}
        }
        
        throw XZMacroError(message: "@bind: 无法解析属性类型")
    }
    
    /// 解析视图中的 @bind 宏，返回待绑定的键和方法。
    public static func viewBindArguments(forMacro macroNode: SwiftSyntax.AttributeSyntax, forVariable property: (name: String, type: String)) throws -> (selector: String, key: String) {
        // 获取宏参数
        let macroArguments = macroNode.arguments?.arrayRepresentation ?? []
        
        var selector = ""
        var vmkey    = ""
        
        switch macroArguments.count {
        case 0:
            // 1、根据属性名确定 vmKey，根据属性类型确定 vSelector
            // 2、无法确定用 默认值
            guard property.type.hasPrefix("UI") else {
                throw XZMacroError(message: "@bind: 自定义类型，请使用 @bind(\"vmKey\", \"vkey\") 或 @bind(property:) 进行绑定")
            }
            
            let typeName = String(property.type[property.type.index(property.type.startIndex, offsetBy: 2)...]);
            if property.name.hasSuffix(typeName) {
                vmkey = String(property.name[..<property.name.index(property.name.endIndex, offsetBy: -typeName.count)])
            }
            
            switch property.type {
            case "UILabel":
                if vmkey.isEmpty {
                    vmkey = "text"
                }
                selector = "#selector(setter: UILabel.text)"
            case "UIImageView":
                if vmkey.isEmpty {
                    vmkey = "image"
                }
                selector = "#selector(setter: UIImageView.image)"
            case "UITextView":
                if vmkey.isEmpty {
                    vmkey = "text"
                }
                selector = "#selector(setter: UITextView.text)"
            case "UITextField":
                if vmkey.isEmpty {
                    vmkey = "text"
                }
                selector = "#selector(setter: UITextField.text)"
            case "UISwitch":
                if vmkey.isEmpty {
                    vmkey = "isOn"
                }
                selector = "#selector(setter: UISwitch.isOn)"
            case "UIButton":
                if vmkey.isEmpty {
                    vmkey = "title"
                }
                selector = "#selector(setter: UIButton.title)"
            case "UIView":
                if vmkey.isEmpty {
                    vmkey = "backgroundColor"
                }
                selector = "#selector(setter: UIView.backgroundColor)"
            default:
                throw XZMacroError(message: "@bind: 请使用 @bind(\"vmKey\", \"vKey\") 的方式进行绑定")
            }
            
        case 1:
            let macroArgument = macroArguments[0]
            
            // 只有一个参数，那么参数值为 ViewModel 属性
            if let key = macroArgument.representedLiteralValue {
                vmkey = key;
            } else {
                vmkey = String(macroArgument.value[macroArgument.value.index(after: macroArgument.value.startIndex)...])
            }
            
            if let label = macroArgument.label {
                // 有标签，标签为 View 属性
                selector = "#selector(setter: \(property.type).\(label))"
            } else {
                // 没有标签，查找默认值，否则使用参数
                if property.type.hasPrefix("UI") {
                    switch property.type {
                    case "UILabel":
                        selector = "#selector(setter: UILabel.text)"
                    case "UIImageView":
                        selector = "#selector(setter: UIImageView.image)"
                    case "UITextView":
                        selector = "#selector(setter: UITextView.text)"
                    case "UITextField":
                        selector = "#selector(setter: UITextField.text)"
                    case "UISwitch":
                        selector = "#selector(setter: UISwitch.isOn)"
                    case "UIButton":
                        selector = "#selector(setter: UIButton.title)"
                    case "UIView":
                        selector = "#selector(setter: UIView.backgroundColor)"
                    default:
                        selector = "#selector(setter: UIView.\(vmkey))"
                    }
                } else {
                    selector = "#selector(setter: UIView.\(vmkey))"
                }
            }
        case 2:
            let macroArgument0 = macroArguments[0]
            if let key = macroArgument0.representedLiteralValue {
                vmkey = key
            } else {
                vmkey = String(macroArgument0.value[macroArgument0.value.index(after: macroArgument0.value.startIndex)...])
            }
            
            let macroArgument1 = macroArguments[1]
            if macroArgument1.label == "selector" {
                selector = macroArgument1.value;
            } else if let key = macroArgument1.representedLiteralValue {
                selector = "#selector(setter: \(property.type).\(key))"
            } else  {
                selector = "#selector(setter: \(property.type)\(macroArgument1.value))"
            }
            
        default:
            throw XZMacroError(message: "@bind: 参数错误，仅支持两个个参数")
        }
        
        return (selector, vmkey)
    }
    
    /// 为被 @bind 标记的属性，生成绑定代码
    public static func viewBindStatements(forMacros macroNodes: [SwiftSyntax.AttributeSyntax], forVariable declaration: VariableDeclSyntax) throws -> String {
        if macroNodes.isEmpty {
            return ""
        }
        
        guard let propertyName = declaration.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw XZMacroError(message: "@bind: 无法确定属性名")
        }
        
        let propertyType = try Self.type(forVariable: declaration)
        
        let statements = try macroNodes.map({ macroNode throws -> String in
            let arguments = try Self.viewBindArguments(forMacro: macroNode, forVariable: (propertyName, propertyType.name))
            return "viewModel.addTarget(\(propertyName), action: \(arguments.selector), forKey: \"\(arguments.key)\", value: nil)"
        }).joined(separator: "\n")
        
        if propertyType.optional != .unwrapped {
            return "if let \(propertyName) = self.\(propertyName) { \(statements) }"
        }
        return statements
    }
    
    /// 获取被 @bind(key) 修饰的方法中，获取
    /// selector:2、方法名
    /// key: 宏参数key，或者方法的第一个参数名
    public static func viewBindArguments(forMacro macroNode: SwiftSyntax.AttributeSyntax, forFunction declaration: FunctionDeclSyntax) throws -> (selector: String, keys: [String]) {
        var keys = [String]()
        
        if case let .argumentList( arguments ) = macroNode.arguments {
            for item in arguments {
                keys.append(item.expression.trimmedDescription)
            }
        }
        
        let usesArgumentsAsKey = keys.isEmpty
        
        // 遍历方法参数，拼接方法名
        var selector = "#selector(Self.\(declaration.name.text)("
        for parameter in declaration.signature.parameterClause.parameters {
            let argumentLabel = parameter.firstName.text;
            selector += argumentLabel + ":"
            if usesArgumentsAsKey {
                keys.append("\"\(parameter.secondName?.text ?? argumentLabel)\"")
            }
        }
        selector += "))"
        
        return (selector, keys)
    }
    
    // 为 View 绑定 ViewModel.key 生成绑定代码
    public static func viewBindStatement(forMacro macroNode: SwiftSyntax.AttributeSyntax, forFunction declaration: FunctionDeclSyntax) throws -> String {
        let arguments = try Self.viewBindArguments(forMacro: macroNode, forFunction: declaration)
        guard arguments.keys.count == 1 else {
            throw XZMacroError(message: "@bind: View 支持绑定一个 key")
        }
        return "viewModel.addTarget(self, action: \(arguments.selector), forKey: \(arguments.keys[0]), value: nil)"
    }
    
    public static func isValid(forMacro node: SwiftSyntax.AttributeSyntax, forFunction declaration: FunctionDeclSyntax, for role: XZMocoaRole) throws {
        switch role {
        case .m:
            throw XZMacroError(message: "@bind: 暂不支持 .m 角色")
            
        case .v:
            let methodArgumentsCount = declaration.signature.parameterClause.parameters.count;
            guard methodArgumentsCount <= 3 else {
                throw XZMacroError(message: "@bind: 仅支持绑定 value、key-value、sender-key-value 三种参数形式的方法")
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
                            throw XZMacroError(message: "@bind: 指定键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                    default:
                        throw XZMacroError(message: "@bind: 仅可指定 key 一个参数")
                    }
                    
                default:
                    throw XZMacroError(message: "@bind: 不支持绑定当前的键类型")
                }
            }
            
        case .vm:
            let methodArgumentsCount = declaration.signature.parameterClause.parameters.count;
            
            // 函数参数的数量
            guard methodArgumentsCount > 0 else {
                throw XZMacroError(message: "@bind: 函数没有参数，无法接收被绑定的键值")
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
                            throw XZMacroError(message: "@bind: 指定键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                        break
                    default:
                        throw XZMacroError(message: "@bind: 函数的参数与绑定的键数量不一致")
                    }

                default:
                    throw XZMacroError(message: "@bind: 不支持绑定当前的键类型")
                }
            }
        }
    }
    
    public static func isValid(forMacro node: SwiftSyntax.AttributeSyntax, forVariable declaration: VariableDeclSyntax, for role: XZMocoaRole) throws -> OptionalType {
        switch role {
        case .m:
            throw XZMacroError(message: "@bind: 暂不支持 .m 角色")
            
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
                        case "UITextView":
                            break
                        case "UITextField":
                            break
                        case "UIImageView":
                            break
                        case "UISwitch":
                            break
                        default:
                            throw XZMacroError(message: "@bind: 默认绑定还不支持 \(propertyType.name) 类型")
                        }
                    case 1:
                        let macroArgument = macroArguments[macroArguments.startIndex]
                        if let label = macroArgument.label?.trimmedDescription {
                            if label != "key" {
                                throw XZMacroError(message: "@bind: 单个参数仅支持 key 标签（指定 View 属性）")
                            }
                        } else {
                            switch propertyType.name {
                            case "UILabel":
                                break
                            case "UITextView":
                                break
                            case "UITextField":
                                break
                            case "UIImageView":
                                break
                            case "UISwitch":
                                break
                            default:
                                throw XZMacroError(message: "@bind: 默认绑定还不支持 \(propertyType.name) 类型")
                            }
                        }
                    case 2:
                        let firstExpression = macroArguments[macroArguments.startIndex].expression
                        if let stringValue = firstExpression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw XZMacroError(message: "@bind: 第一个参数不能为空，若仅指定 view 属性名，可使用 @bind(key:) 宏")
                            }
                        } else if firstExpression.as(MemberAccessExprSyntax.self) == nil {
                            throw XZMacroError(message: "@bind: 绑定 ViewModel 键名必须是 String 字面量或 XZMocoaKey 枚举值")
                        }
                        
                        let secondExpression = macroArguments[macroArguments.index(after: macroArguments.startIndex)].expression
                        if let stringValue = secondExpression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw XZMacroError(message: "@bind: 绑定 View 键名不能为空；若 View 支持默认键名，请不要提供第二参数")
                            }
                        } else if secondExpression.as(MemberAccessExprSyntax.self) == nil {
                            throw XZMacroError(message: "@bind: 绑定 View 键名必须是 String 字面量或 XZMocoaKey 枚举值")
                        }
                        
                    default:
                        throw XZMacroError(message: "@bind: 仅支持 (.vmKey)、(.vmKey, .vKey) 两种形式的参数")
                    }
                    
                default:
                    throw XZMacroError(message: "@bind: 不支持绑定当前的键类型")
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
                            throw XZMacroError(message: "@bind: 在 ViewModel 上不支持该绑定，请移除参数标签")
                        }
                        let expression = macroArgument.expression
                        if let stringValue = expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                            guard stringValue.count > 0 else {
                                throw XZMacroError(message: "@bind: 绑定 ViewModel 键名不能为空，若 Model 键与 ViewModel 属性同名，可省略参数")
                            }
                        } else if expression.as(MemberAccessExprSyntax.self) == nil {
                            throw XZMacroError(message: "@bind: 绑定 ViewModel 属性的键名必须为 String 字面量或 XZMocoaKey 枚举值")
                        }
                        break
                    default:
                        throw XZMacroError(message: "@bind: 绑定 ViewModel 属性仅支持一个参数")
                    }

                default:
                    throw XZMacroError(message: "@bind: 不支持绑定当前的键类型")
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

/// for @bind(key:)
public struct XZMocoaBindViewMacro {
    
}


extension XZMocoaBindViewMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw XZMacroError(message: "@bind(key:) 仅支持属性")
        }
        
        let type = try XZMocoaBindMacro.type(forVariable: declaration);
        
        for binding in declaration.bindings {
            guard let accessorBlock = binding.accessorBlock else {
                continue
            }
            switch accessorBlock.accessors {
            case .getter:
                if type.optional == .wrapped {
                    XZMacroDiagnose(context, node: node, message: "@bind: 可选类型的只读计算属性，可能无法实时绑定，如果该属性不为 nil 请使用非可选或隐式可选类型，以消除此警告", severity: .warning)
                }
                return []
                
            case .accessors(let accessors):
                for accessor in accessors {
                    switch accessor.accessorSpecifier.text {
                    case "didSet":
                        XZMacroDiagnose(context, node: node, message: "@bind: 已自定义 didSet 无法绑定动态监听，若已自行处理，请使用 @bind(vmKey, vKey) 以消除此警告", severity: .warning)
                        return []
                    default:
                        break
                    }
                }
            }
        }
        
        guard type.optional == .wrapped else {
            return []
        }
        
        let statements = try XZMocoaBindMacro.viewBindStatements(forMacros: declaration.attributes.compactMap({ attribute in
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

