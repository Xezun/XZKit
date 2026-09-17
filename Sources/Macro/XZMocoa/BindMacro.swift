//
//  BindMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import Foundation

/// 类型的包装形式。
public enum TypeWrapation {
    /// 非可选
    case unwrapped
    /// 可选
    case optional
    /// 隐式可选
    case autoUnwrapped
    
    init?(_ type: TypeSyntax?) {
        guard let type = type else { return nil }
        if let _ = type.as(OptionalTypeSyntax.self) {
            self = .optional
        } else if let _ = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            self = .autoUnwrapped
        } else {
            self = .unwrapped
        }
    }
}



public struct ViewBindMacro {
    
}

/// 绑定代码由 @mocoa 宏实现。
///
/// - 协议 PeerMacro 让宏支持修饰属性和方法，协议实现仅做合法性校验。
/// - 协议 AccessorMacro 添加 didSet 让可选类型的在改变值之后，依然可以绑定事件。
/// - 绑定代码由 @mocoa 宏实现。
///
/// | Macro                  | Role      | For              | Description                        |
/// |:-----------------------|:----------|:-----------------|:-----------------------------------|
/// | `@bind`, `@bind(key)`  | View      | Property, Method | key => setProperty:, key => Method |
/// | `@bind(prop: key)`     | View      | Property         | key => Property.setProp:           |
/// | `@bind(key, selector)` | View      | Property         | key => Property.selector           |
/// | `@bind`, `@bind(key)`  | ViewModel | Property, Method | key => setProperty:, key => Method |
/// | `@bind(key, ...)`      | ViewModel | Method           | key => Method                      |
public struct BindMacro: PeerMacro, AccessorMacro {
    
    // PeerMacro 协议
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        switch try MocoaRole.init(node: node, context: context) {
        case .m:
            throw XZMacroError(node, message: "不支持 Model 角色")
            
        case .v:
            if let propertyDecl = declaration.as(VariableDeclSyntax.self) {
                if case let .argumentList(arguments) = node.arguments, arguments.count > 0 {
                    // @bind 带参数
                    switch arguments.count {
                    case 1:
                        let first = arguments[arguments.startIndex]
                        if first.label == nil {
                            // 无标签，绑定属性的 setter，必须可写
                            if propertyDecl.isReadOnlyProperty {
                                throw XZMacroError(node, message: "无法将视图模型 \(first.expression.trimmedDescription) 的值绑定到只读属性")
                            }
                        } else {
                            // 有标签，绑定属性值属性的 setter 方法。
                        }
                    case 2:
                        let keyArgument = arguments[arguments.startIndex]
                        let selArgument = arguments[arguments.index(after: arguments.startIndex)]
                        if keyArgument.label != nil || selArgument.label?.text != "selector" {
                            throw XZMacroError(node, message: "两个参数仅支持 (key, selector:) 这一种形式")
                        }
                    default:
                        throw XZMacroError(node, message: "参数数量超出限制，仅支持 (key)、(text: key)、(key, selector:) 三种形式")
                    }
                } else {
                    // @key 不带参数，绑定属性的setter，必须可写
                    if propertyDecl.isReadOnlyProperty {
                        throw XZMacroError(node, message: "只读属性不支持绑定")
                    }
                }
                break
            }
            
            if let methodDecl = declaration.as(FunctionDeclSyntax.self) {
                // 根据 KTA 机制，方法最多支持三个参数 (XZMocoaViewModel, XZMocoaKey, value)
                if methodDecl.signature.parameterClause.parameters.count > 3 {
                    throw XZMacroError(node, message: "仅支持绑定一个参数的方法")
                }
                // 修饰视图的方法，仅支持一个参数，不带标签
                if case let .argumentList(arguments) = node.arguments, arguments.count > 0 {
                    if arguments.count > 1 {
                        throw XZMacroError(node, message: "仅支持绑定一个键到方法")
                    }
                    if let label = arguments[arguments.startIndex].label?.text {
                        throw XZMacroError(node, message: "请移除 \(label) 参数标签")
                    }
                }
            }
            
            throw XZMacroError(node, message: "不支持此成员")
            
        case .vm:
            if let propertyDecl = declaration.as(VariableDeclSyntax.self) {
                if case let .argumentList(arguments) = node.arguments, arguments.count > 0 {
                    if arguments.count > 1 {
                        throw XZMacroError(node, message: "仅支持将一个键绑定到属性")
                    }
                    let keyArgument = arguments[arguments.startIndex]
                } else if let name = propertyDecl.name {
                    if propertyDecl.isReadOnlyProperty {
                        throw XZMacroError(node, message: "无法将数据模型的 \(name) 的值绑定到只读属性")
                    }
                } else {
                    throw XZMacroError(node, message: "无法确定属性名")
                }
            }
            
            if let methodDecl = declaration.as(FunctionDeclSyntax.self) {
                let count = methodDecl.signature.parameterClause.parameters.count
                if case let .argumentList(arguments) = node.arguments, arguments.count > 0 {
                    if arguments.count > count {
                        throw XZMacroError(node, message: "绑定的键不能比方法参数多")
                    }
                    for argument in arguments {
                        if let label = argument.label?.text {
                            throw XZMacroError(node, message: "请移除 \(label) 参数标签")
                        }
                    }
                } else {
                    // 没有参数，使用方法参数名作为键
                }
            }
            
            throw XZMacroError(node, message: "不支持此成员")
        }
        
        return []
    }
    
    // AccessorMacro 协议
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let propertyDecl = declaration.as(VariableDeclSyntax.self) else {
            throw XZMacroError(node, message: "仅支持属性")
        }
        
        switch try MocoaRole.init(node: node, context: context) {
        case .m:
            return []
        
        case .v:
            switch TypeWrapation(propertyDecl.bindings.first?.typeAnnotation?.type) {
            case .optional:
                fallthrough
            case .autoUnwrapped:
                let macroName = node.attributeName.trimmedDescription
                
                if propertyDecl.isReadOnlyProperty {
                    if !propertyDecl.trimmedDescription.contains("\(macroName)Target") {
                        XZMacroDiagnose(context, node: node, message: "可选类型的只读属性，绑定可能实效，请自行调用 \(macroName)Target(_:action:forKey:) 方法实现绑定", severity: .warning)
                    }
                    return []
                }
                
                if propertyDecl.containsAccessors(["set", "didSet"]) {
                    if !propertyDecl.trimmedDescription.contains("\(macroName)Target") {
                        XZMacroDiagnose(context, node: node, message: "无法为可选类型的属性，添加 didSet 方法，绑定可能实现，请自行调用 \(macroName)Target(_:action:forKey:) 方法实现绑定", severity: .warning)
                    }
                    return []
                }
                
                let statements = try self.viewBindStatements(forMacros: propertyDecl.attributes.compactMap({ attribute in
                    switch attribute {
                    case .attribute(let macroNode):
                        switch macroNode.attributeName.trimmedDescription {
                        case "bind":
                            fallthrough
                        case "link":
                            return macroNode
                        default:
                            return nil
                        }
                    case .ifConfigDecl:
                        return nil
                    }
                }), forVariable: propertyDecl)
                
                return [
                    """
                    didSet {
                        guard let viewModel = self.viewModel else { return }
                        \(raw: statements)
                    }
                    """
                ]
                
            default:
                return []
            }
            
        case .vm:
            return []
        }
    }
    
    
    // 为 @mocoa 宏提供 @bind 语句
    public static func expansion(of node: AttributeSyntax, providingStatementsOf propertyDecl: VariableDeclSyntax, in context: some MacroExpansionContext, for role: MocoaRole) throws -> [String] {
        return []
    }
    
    // 为 @mocoa 宏提供 @bind 语句
    public static func expansion(of node: AttributeSyntax, providingStatementsOf methodDecl: FunctionDeclSyntax, in context: some MacroExpansionContext, for role: MocoaRole) throws -> [String] {
        return []
    }
    
    // - old methods
    
    /// 从属性的声明，获取属性的类型。
    /// - Parameter variableDecl: 声明属性的语句
    /// - Returns: 属性的类型名，属性的可选类型
    public static func typeInfo(from variableDecl: VariableDeclSyntax) throws -> (typeName: String, wrappedType: TypeWrapation) {
        guard let expression = variableDecl.bindings.first else {
            throw XZMacroError(message: "@bind: 没有找到属性类型")
        }
        
        // 示例：var textLabel: UILabel!
        if let type = expression.typeAnnotation?.type {
            if let op = type.as(OptionalTypeSyntax.self) {
                return (op.wrappedType.trimmedDescription, .optional)
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
                case "UIView":
                    selector = try UIViewSelector(forBindingKey: vmkey)
                case "UILabel":
                    selector = try UILabelSelector(forBindingKey: vmkey)
                case "UIImageView":
                    selector = try UIImageViewSelector(forBindingKey: vmkey)
                case "UITextView":
                    selector = try UITextViewSelector(forBindingKey: vmkey)
                case "UITextField":
                    selector = try UITextFieldSelector(forBindingKey: vmkey)
                case "UISwitch":
                    selector = try UISwitchSelector(forBindingKey: vmkey)
                case "UIButton":
                    selector = try UIButtonSelector(forBindingKey: vmkey)
                default:
                    selector = try UIViewSelector(forBindingKey: vmkey)
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
            throw XZMacroError(message: "@bind: 参数错误")
        }
        
        guard let propertyName = declaration.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw XZMacroError(message: "@bind: 无法确定属性名")
        }
        
        let propertyType = try Self.typeInfo(from: declaration)
        
        let statements = try macroNodes.map({ macroNode throws -> String in
            let type = macroNode.attributeName.trimmedDescription
            let arguments = try Self.viewBindArguments(forMacro: macroNode, forVariable: (propertyName, propertyType.typeName))
            return "viewModel.\(type)Target(\(propertyName), action: \(arguments.selector), forKey: \"\(arguments.key)\")"
        })//
        
        if propertyType.wrappedType != .unwrapped {
            return """
            if let \(propertyName) = self.\(propertyName) { 
                    \(statements.joined(separator: "\n        "))
            }
            """
        }
        return statements.joined(separator: "\n    ")
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
        let type = macroNode.attributeName.trimmedDescription
        return "viewModel.\(type)Target(self, action: \(arguments.selector), forKey: \(arguments.keys[0]))"
    }
    
    public static func isValid(forMacro node: SwiftSyntax.AttributeSyntax, forFunction declaration: FunctionDeclSyntax, for role: MocoaRole) throws {
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
    
    public static func isValid(forMacro node: SwiftSyntax.AttributeSyntax, forVariable declaration: VariableDeclSyntax, for role: MocoaRole) throws -> TypeWrapation {
        switch role {
        case .m:
            throw XZMacroError(message: "@bind: 暂不支持 .m 角色")
            
        case .v:
            let propertyType = try self.typeInfo(from: declaration)
            
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
            
            return propertyType.wrappedType
            
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

extension BindMacro {
    
    /// 供 @mooca 宏调用，为 @bind 或 @link 宏标记的属性，添加 @objc 标记。
    ///
    /// 调用此方法前 @mocoa 宏已确定所有参数类型。
    /// - Parameters:
    ///   - node: `@bind` 宏
    ///   - declaration: 被 @bind 宏修饰的属性
    ///   - context: @mocoa 宏的上下文
    /// - Returns: 属性
    public static func expansion(of node: AttributeSyntax, providingAttributesFor propertyDecl: VariableDeclSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext, for role: MocoaRole) throws -> [SwiftSyntax.AttributeSyntax] {
        switch role {
        case .m:
            throw XZMacroError(message: "@\(node.attributeName): 不支持 Model 角色")
            
        case .v:
            // @bind 宏的合法性由自身校验，此方法为 @mocoa 宏调用，不校验合法性
            // 已有 @objc 标记
            if propertyDecl.containsAttributes(["objc", "key", "IBOutlet"], .or) {
                return []
            }
            return ["@objc"]
        case .vm:
            // 已包含 @objc
            if propertyDecl.containsAttributes(["objc", "key", "NSManaged"], .or) {
                return []
            }
            return ["@objc"]
        }
    }
    
    /// 供 @mooca 宏调用，为 @bind 宏标记的方法，添加 @objc 标记。
    ///
    /// 调用此方法前 @mocoa 宏已确定所有参数类型。
    /// - Parameters:
    ///   - node: `@bind` 宏
    ///   - declaration: 被 @bind 宏修饰的方法
    ///   - context: @mocoa 宏的上下文
    /// - Returns: 属性
    public static func expansion(of node: AttributeSyntax, providingAttributesFor methodDecl: FunctionDeclSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext, for role: MocoaRole) throws -> [SwiftSyntax.AttributeSyntax] {
        switch role {
        case .m:
            throw XZMacroError(message: "@\(node.attributeName): 不支持 Model 角色")
        case .v:
            if methodDecl.containsAttributes(["objc", "IBAction"], .or) {
                return []
            }
            return ["@objc"]
        case .vm:
            if methodDecl.containsAttributes(["objc", "IBAction"], .or) {
                return []
            }
            return ["@objc"]
        }
    }
    
}


fileprivate func UIViewSelector(forBindingKey vmkey: String) throws -> String {
    if regexTest(vmkey, pattern: "hidden$") {
        return "#selector(setter: UIView.isHidden)"
    } else if regexTest(vmkey, pattern: "alpha$") {
        return "#selector(setter: UIView.alpha)"
    } else if regexTest(vmkey, pattern: "frame$") {
        return "#selector(setter: UIView.frame)"
    } else if regexTest(vmkey, pattern: "bounds$") {
        return "#selector(setter: UIView.bounds)"
    } else if regexTest(vmkey, pattern: "center$") {
        return "#selector(setter: UIView.center)"
    } else if regexTest(vmkey, pattern: "transform$") {
        return "#selector(setter: UIView.transform)"
    } else if regexTest(vmkey, pattern: "tintColor$") {
        return "#selector(setter: UIView.tintColor)"
    } else if (regexTest(vmkey, pattern: "backgroundColor$")) {
        return "#selector(setter: UIView.backgroundColor)"
    } else {
        throw XZMacroError(message: "@bind: 无法为 \(vmkey) 推断要绑定的视图属性或视图方法")
    }
}

private let kGeneralTextKeys  = "text|title|name|description|detail|content|string"
private let kGeneralImageKeys = "image|icon|avatar|photo|picture|thumbnail"

fileprivate func UITextSelector(forBindingKey vmkey: String, forView view: String) throws -> String {
    if regexTest(vmkey, pattern: "attributed(\(kGeneralTextKeys))$") {
        return "#selector(setter: \(view).attributedText)"
    } else if regexTest(vmkey, pattern: "textAlignment$") {
        return "#selector(setter: \(view).textAlignment)"
    } else if regexTest(vmkey, pattern: "(\(kGeneralTextKeys))$") {
        return "#selector(setter: \(view).text)"
    } else if regexTest(vmkey, pattern: "(\(kGeneralTextKeys))Color$") {
        return "#selector(setter: \(view).textColor)"
    } else if regexTest(vmkey, pattern: "font$") {
        return "#selector(setter: \(view).font)"
    } else {
        return try UIViewSelector(forBindingKey: vmkey)
    }
}

fileprivate func UILabelSelector(forBindingKey vmkey: String) throws -> String {
    return try UITextSelector(forBindingKey: vmkey, forView: "UILabel")
}

fileprivate func UIImageViewSelector(forBindingKey vmkey: String) throws -> String {
    if regexTest(vmkey, pattern: "(\(kGeneralImageKeys))$") {
        return "#selector(setter: UIImageView.image)"
    } else if regexTest(vmkey, pattern: "(\(kGeneralImageKeys))s$") {
        return "#selector(setter: UIImageView.animationImages)"
    } else {
        return try UIViewSelector(forBindingKey: vmkey)
    }
}

fileprivate func UITextViewSelector(forBindingKey vmkey: String) throws -> String {
    return try UITextSelector(forBindingKey: vmkey, forView: "UITextView")
}

fileprivate func UITextFieldSelector(forBindingKey vmkey: String) throws -> String {
    if regexTest(vmkey, pattern: "attributedPlaceholder$") {
        return "#selector(setter: UITextField.attributedPlaceholder)"
    } else if regexTest(vmkey, pattern: "placeholder$") {
        return "#selector(setter: UITextField.placeholder)"
    } else {
        return try UITextSelector(forBindingKey: vmkey, forView: "UITextField")
    }
}

fileprivate func UISwitchSelector(forBindingKey vmkey: String) throws -> String {
    if regexTest(vmkey, pattern: "onTintColor$") {
        return "#selector(setter: UISwitch.onTintColor)"
    } else if regexTest(vmkey, pattern: "thumbTintColor$") {
        return "#selector(setter: UISwitch.thumbTintColor)"
    } else if regexTest(vmkey, pattern: "onImage$") {
        return "#selector(setter: UISwitch.onImage)"
    } else if regexTest(vmkey, pattern: "offImage$") {
        return "#selector(setter: UISwitch.offImage)"
    } else {
        return try UIViewSelector(forBindingKey: vmkey)
    }
}

fileprivate func UIButtonSelector(forBindingKey vmkey: String) throws -> String {
    if regexTest(vmkey, pattern: "attributed(\(kGeneralTextKeys))$") {
        return "#selector(UIButton.__xz_bind_attributedTitle_normal(_:))"
    } else if regexTest(vmkey, pattern: "(\(kGeneralTextKeys))$"){
        return "#selector(UIButton.__xz_bind_title_normal(_:))"
    } else if regexTest(vmkey, pattern: "(\(kGeneralTextKeys))ShadowColor$") {
        return "#selector(UIButton.__xz_bind_titleShadowColor_normal(_:))"
    } else if regexTest(vmkey, pattern: "(\(kGeneralTextKeys))Color$") {
        return "#selector(UIButton.__xz_bind_titleColor_normal(_:))"
    } else if regexTest(vmkey, pattern: "backgroundImage$") {
        return "#selector(UIButton.__xz_bind_backgroundImage_normal(_:))"
    } else if regexTest(vmkey, pattern: "image$") {
        return "#selector(UIButton.__xz_bind_image_normal(_:))"
    } else {
        return try UIViewSelector(forBindingKey: vmkey)
    }
}

// 测试字符串是否匹配正则。
fileprivate func regexTest(_ aString: String, pattern: String) -> Bool {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return false }
    return regex.rangeOfFirstMatch(in: aString, range: NSMakeRange(0, (aString as NSString).length)).length > 0
}
