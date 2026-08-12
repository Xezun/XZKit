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
            throw XZMacroError(message: "@bind: 请通过参数 (viewModel, view) 指定待绑定的 XZMocoaKey 和属性")
            
        case 1:
            // 只有一个参数
            let argument0 = macroArguments[0]
            
            // 参数值 XZMocoaKey
            if let key = argument0.representedLiteralValue {
                vmkey = key;
            } else {
                vmkey = String(argument0.value.dropFirst())
            }
            
            if let label = argument0.label {
                // 有标签：标签为 View 属性
                selector = "#selector(setter: \(property.type).\(label))"
            } else {
                // 无标签：查找 view 默认属性，或使用参数相同的属性
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
                    selector = "#selector(setter: \(property.type).\(vmkey))"
                }
            }
            
        case 2:
            let argument0 = macroArguments[0]
            // 解析第一个参数为 vmkey（XZMocoaKey 字符串字面量）
            if let key = argument0.representedLiteralValue {
                vmkey = key
            } else {
                // XZMocoaKey 枚举：".title" → "title"
                vmkey = String(argument0.value.dropFirst())
            }

            let argument1 = macroArguments[1]

            // 形式 3: @bind(title:key, for:state) / @bind(image:key, for:state) / 等
            // 第一参数标签作为 __xz_bind_<title>_<state> 的一部分（仅支持 UIButton）。
            switch argument1.label {
            case "for":
                guard let title = argument0.label else {
                    throw XZMacroError(message: "@bind: 与 for: 配套的第一参数必须带标签（如 title:、image:）")
                }
                let state = argument1.value.dropFirst()
                selector = "#selector(\(property.type).__xz_bind_\(title)_\(state)(_:))"
            case "selector":
                selector = argument1.value
            default:
                if let vKey = argument1.representedLiteralValue {
                    selector = "#selector(setter: \(property.type).\(vKey))"
                } else {
                    selector = "#selector(setter: \(property.type)\(argument1.value))"
                }
            }
            
        default:
            throw XZMacroError(message: "@bind: 参数错误，仅支持两个参数")
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
    
    /// 获取被 `@bind(key)` 修饰的方法的绑定参数。
    /// - Returns:
    ///   - selector: 方法选择器
    ///   - keys: 宏参数 key 列表，若宏未指定参数，则为方法参数名列表
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
                        throw XZMacroError(message: "@bind: 为视图建立绑定需指定参数")
                        
                    case 1:
                        break
                        
                    case 2:
                        let firstArg = macroArguments[macroArguments.startIndex]
                        let secondArg = macroArguments[macroArguments.index(after: macroArguments.startIndex)]
                        let firstLabel  = firstArg.label?.text
                        let secondLabel = secondArg.label?.text
                        
                        switch secondLabel {
                        case "for":
                            if firstLabel == nil {
                                throw XZMacroError(message: "@bind: 第一个参数必须有标签")
                            }
                        case "selector":
                            if firstLabel != nil {
                                throw XZMacroError(message: "@bind: 第一个参数必须无标签")
                            }
                        default:
                            if firstLabel != nil || secondLabel != nil {
                                throw XZMacroError(message: "@bind: 移除参数标签")
                            }
                        }
                    default:
                        throw XZMacroError(message: "@bind: 两个参数仅支持 (vmKey, vKey) / (key, selector: aSelector) / (title:key, for:state) 三种形式")
                    }
                default:
                    throw XZMacroError(message: "@bind: 语法错误")
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

