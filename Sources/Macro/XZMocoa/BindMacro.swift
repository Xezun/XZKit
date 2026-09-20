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

/// 绑定代码由 @mocoa 宏实现。
///
/// - 协议 PeerMacro 让宏支持修饰属性和方法，协议实现仅做合法性校验。
/// - 协议 AccessorMacro 添加 didSet 让可选类型的在改变值之后，依然可以绑定事件。
/// - 绑定代码由 @mocoa 宏负责生成。
public struct BindMacro: PeerMacro, AccessorMacro {
    
    // PeerMacro 协议：校验 @bind @link 宏的合法性。
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        switch try XZMacroMocoaRole.init(node: node, context: context) {
        case .m:
            throw XZMacroError(node, message: "不支持 Model 角色")
            
        case .v:
            // 修饰视图的属性
            if let propertyDecl = declaration.as(VariableDeclSyntax.self) {
                let property = try XZMacroPropertyInfomation(node, propertyDecl)
                
                let arguments = node.representedArrayArguments
                switch arguments.count {
                case 0:
                    // 无参数，绑定属性的 setter
                    if property.readability.isReadonly {
                        // ❌ 只读属性没有 setter 无法绑定
                        throw XZMacroError(node, message: "只读属性不支持绑定，若要绑定属性值的属性，请使用带参数标签的宏")
                    } else {
                        // ✅ 属性可写，可正常绑定
                    }
                    
                case 1:
                    // 一个参数的情形：
                    // @bind(.key)
                    // @bind(title: .key)
                    if let _ = arguments[0].label {
                        // ✅ 有标签，绑定属性的属性，宏无法检查“属性的属性”是否可写，不处理
                    } else {
                        // 无标签，绑定属性的 setter
                        if property.readability.isReadonly {
                            // ❌ 只读属性无法绑定
                            throw XZMacroError(node, message: "无法将键绑定给只读属性，若要绑定属性值的属性，请使用带参数标签的宏")
                        } else {
                            // ✅ 可写属性，可正常绑定
                        }
                    }
                    
                case 2:
                    // 两个参数的情形：
                    // @bind(.vmkey, key: .viewKey)
                    // @bind(.vmkey, selector: viewSelector)
                    // @bind(title: .vmkey, for: .selected)
                    if let _ = arguments[0].label {
                        // 第一个参数有标签，第二参数也必须有标签
                        // 不校验必须为 for 标签，增加拓展性
                        guard let _ = arguments[1].label else {
                            throw XZMacroError(node, message: "宏不支持此属性")
                        }
                    } else if let label = arguments[1].label {
                        // 第一个参数无标签，第二个参数标签必须为 key 或 selector
                        switch label {
                        case "key", "selector":
                            break;
                        default:
                            throw XZMacroError(node, message: "宏不支持此属性")
                        }
                    } else {
                        throw XZMacroError(node, message: "宏不支持此属性")
                    }
                    
                default:
                    // 不支持更多参数
                    throw XZMacroError(node, message: "宏不支持此属性，参数超出限制")
                }
                
                return []
            }
            
            // 修饰视图的方法
            if let methodDecl = declaration.as(FunctionDeclSyntax.self) {
                let method = XZMacroMethodInformation(node, methodDecl)
                
                // 根据 KTA 机制，方法最多支持三个参数 (XZMocoaViewModel, XZMocoaKey, value)
                if method.parameters.count > 3 {
                    throw XZMacroError(node, message: "根据 KTA 机制，绑定方法最多支持三个参数")
                }
                
                // 修饰视图的方法，仅支持一个参数，不带标签
                let nodeArguments = node.representedArrayArguments
                if nodeArguments.count > 1 {
                    throw XZMacroError(node, message: "根据 KTA 机制，仅支持绑定单个 XZMocoaKey 到方法")
                }
                if let label = nodeArguments.first?.label {
                    throw XZMacroError(node, message: "请移除 \(label) 参数标签")
                }
                return []
            }
            
            throw XZMacroError(node, message: "不支持此成员，请移除宏标记")
            
        case .vm:
            // 修饰视图模型的属性
            if let propertyDecl = declaration.as(VariableDeclSyntax.self) {
                let nodeArguments = node.representedArrayArguments
                // 有参数，仅支持单参数
                if nodeArguments.count > 1 {
                    throw XZMacroError(node, message: "仅支持一个参数，若要绑定多个键，可添加多个宏")
                }
                
                // 绑定视图模型属性，不支持标签
                if let label = nodeArguments.first?.label {
                    throw XZMacroError(node, message: "请移除 \(label) 参数标签")
                }
                
                let property = try XZMacroPropertyInfomation(node, propertyDecl)
                
                // 只读属性没有 setter 无法绑定
                if property.readability.isReadonly {
                    throw XZMacroError(node, message: "只读属性不支持绑定")
                }
                
                return []
            }
            // 修饰视图模型的方法
            if let methodDecl = declaration.as(FunctionDeclSyntax.self) {
                let method = XZMacroMethodInformation(node, methodDecl)
                let nodeArguments = node.representedArrayArguments
                
                if nodeArguments.count > method.parameters.count {
                    throw XZMacroError(node, message: "绑定的键数量，超出了方法参数个数")
                }
                
                // 每个参数都不能带标签
                for nodeArgument in nodeArguments {
                    if let label = nodeArgument.label {
                        throw XZMacroError(node, message: "请移除 \(label) 参数标签")
                    }
                }
                
                return []
            }
            
            throw XZMacroError(node, message: "不支持此成员，请移除宏标记")
        }
    }
    
    // AccessorMacro 协议：为可选属性生成 didSet 方法。
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let propertyDecl = declaration.as(VariableDeclSyntax.self) else {
            throw XZMacroError(node, message: "仅支持属性")
        }
        
        switch try XZMacroMocoaRole.init(node: node, context: context) {
        case .m:
            return []
            
        case .v:
            // 找到符合条件的宏：只有绑定属性值（子视图）的属性，才需要添加 didSet 方法
            var bindNodes = [(method: String, node: AttributeSyntax, arguments: [(expression: LabeledExprSyntax, label: String?)])]()
            // 只需要为第一个符合条件的宏生成 didSet 方法
            var shouldProvideAccessor: Bool? = nil
            for bindNode in propertyDecl.attributes {
                guard case let .attribute(bindNode) = bindNode else {
                    continue
                }
                guard let bindMethod = bindNode.attributeName.as(IdentifierTypeSyntax.self)?.name.text else {
                    continue
                }
                guard bindMethod == "bind" || bindMethod == "link" else {
                    continue
                }
                
                let arguments = node.representedArrayArguments;
                
                switch arguments.count {
                case 0:
                    // 绑定 setter 不需要 didSet
                    continue
                case 1:
                    // 单个参数
                    // @bind(title:)
                    guard arguments[0].label != nil else {
                        continue
                    }
                case 2:
                    // @bind(_:selector:)
                    // @bind(_:key:)
                    // @bind(title:for:)
                    guard arguments[1].label != nil else {
                        continue
                    }
                default:
                    continue
                }
                
                // 没赋值表示遇到第一个符合条件的 bind/link 宏
                if shouldProvideAccessor == nil {
                    // 直接比较 node 无法确认第一个，始终是 false
                    shouldProvideAccessor = (bindNode.description == node.description)
                }
                
                // 为 false 表示 node 不是第一个 bind/link 宏，不需要继续处理（因为第一个已经处理了）。
                guard shouldProvideAccessor! else {
                    return []
                }
                
                bindNodes.append((bindMethod, bindNode, arguments))
            }
            
            if bindNodes.isEmpty {
                return []
            }
            
            let property = try XZMacroPropertyInfomation(node, propertyDecl);
            
            switch property.readability {
            case .constant:
                // let 只读属性
                return []
                
            case .computed:
                for (method, node, _) in bindNodes {
                    let method = "\(method)Target"
                    if propertyDecl.trimmedDescription.contains(method) {
                        continue
                    }
                    XZMacroDiagnose(context, node: node, message: "计算属性需自行调用 \(method)(_:action:forKey:) 方法实现绑定，添加注释可消除警告", severity: .warning)
                }
                return []
                
            case .variable:
                if property.accessors.contains("set") || property.accessors.contains("didSet") {
                    for (method, node, _) in bindNodes {
                        let method = "\(method)Target"
                        if propertyDecl.trimmedDescription.contains(method) {
                            continue
                        }
                        XZMacroDiagnose(context, node: node, message: "无法生成 didSet 方法，需自行调用 \(method)(_:action:forKey:) 方法实现绑定，添加注释可消除警告", severity: .warning)
                    }
                    return []
                }
                
                var bindStatements = [String]()
                var removeStatements = [String]()
                
                for (method, node, arguments) in bindNodes {
                    switch arguments.count {
                    case 1:
                        let argument = arguments[0]
                        let label = argument.label!
                        let key   = try XZMocoaKey(node, argument: argument.expression)
                        bindStatements.append("viewModel.\(method)Target(newValue, action: #selector(setter: \(property.type.name).\(label)), forKey: \"\(key)\")")
                        removeStatements.append("viewModel.removeTarget(oldValue, action: #selector(setter: \(property.type.name).\(label)), forKey: \"\(key)\")")
                        
                    case 2:
                        let argument0 = arguments[0]
                        let argument1 = arguments[1]
                        
                        let vmKey = try XZMocoaKey(node, argument: argument0.expression)
                        
                        if let viewKey = argument0.label {
                            // bind(title: .vmKey, for: .normal)
                            let stateKey = try XZMocoaKey(node, argument: argument1.expression)
                            let selector = "__mocoa_bind_\(viewKey)_\(stateKey)(_:)"
                            bindStatements.append("viewModel.\(method)Target(newValue, action: #selector(\(property.type.name).\(selector)), forKey: \"\(vmKey)\")")
                            removeStatements.append("viewModel.removeTarget(oldValue, action: #selector(\(property.type.name).\(selector)), forKey: \"\(vmKey)\")")
                        } else if let viewKeyType = argument1.label {
                            switch viewKeyType {
                            case "key":
                                let viewKey = try XZMocoaKey(node, argument: argument1.expression)
                                bindStatements.append("viewModel.\(method)Target(newValue, action: #selector(setter: \(property.type.name).\(viewKey)), forKey: \"\(vmKey)\")")
                                removeStatements.append("viewModel.removeTarget(oldValue, action: #selector(setter: \(property.type.name).\(viewKey)), forKey: \"\(vmKey)\")")
                            case "selector":
                                let selector = argument1.expression.expression.trimmedDescription
                                bindStatements.append("viewModel.\(method)Target(newValue, action: \(selector), forKey: \"\(vmKey)\")")
                                removeStatements.append("viewModel.removeTarget(oldValue, action: \(selector), forKey: \"\(vmKey)\")")
                            default:
                                continue
                            }
                        } else {
                            continue
                        }
                        
                    default:
                        continue
                    }
                }
                
                switch property.type.wrapation {
                case .unwrapped:
                    return [
                        """
                        didSet {
                            guard let viewModel = self.viewModel else { return }
                            \(raw: removeStatements.joined(separator: "\n"))
                            let newValue = self.\(raw: property.name)
                            \(raw: bindStatements.joined(separator: "\n"))
                        }
                        """
                    ]
                    
                case .autoUnwrapped:
                    fallthrough
                case .optional:
                    return [
                        """
                        didSet {
                            guard let viewModel = self.viewModel else { return }
                            if let oldValue = oldValue {
                                \(raw: removeStatements.joined(separator: "\n"))
                            }
                            if let newValue = self.\(raw: property.name) { 
                                \(raw: bindStatements.joined(separator: "\n"))
                            }
                        }
                        """
                    ]
                }
            }
            
        case .vm:
            return []
        }
    }
    
}

extension BindMacro {
    
    /// 供 @mocoa 宏调用，为属性生成绑定代码。
    public static func expansion(of role: XZMacroMocoaRole, providingStatementsOf property: XZMacroPropertyInfomation, in context: some MacroExpansionContext) throws -> String? {
        switch role {
        case .m:
            throw XZMacroError(message: "@bind: 数据模型 Model 不支持绑定")
            
        case .v:
            return try self.view(role, providingStatementsOf: property, in: context)
            
        case .vm:
            return try self.viewModel(role, providingStatementsOf: property, in: context)
        }
    }
    
    /// 供 @mocoa 宏调用，为方法生成绑定代码。
    public static func expansion(of role: XZMacroMocoaRole, providingStatementsOf method: XZMacroMethodInformation, in context: some MacroExpansionContext) throws -> String? {
        switch role {
        case .m:
            throw XZMacroError(message: "@bind: 数据模型 Model 不支持绑定")
            
        case .v:
            return try self.view(role, providingStatementsOf: method, in: context)
            
        case .vm:
            return try self.viewModel(role, providingStatementsOf: method, in: context)
        }
    }
    
    /// 为 View 的属性生成绑定代码。
    private static func view(_ view: Any, providingStatementsOf property: XZMacroPropertyInfomation, in context: some MacroExpansionContext) throws -> String? {
        var statements = [String]()
        for bindNode in property.declaration.attributes {
            guard case let .attribute(bindNode) = bindNode else {
                continue
            }
            guard let bindMethod = bindNode.attributeName.as(IdentifierTypeSyntax.self)?.name.text else {
                continue
            }
            guard bindMethod == "bind" || bindMethod == "link" else {
                continue
            }
            
            let bindArguments = bindNode.representedArrayArguments;
            switch bindArguments.count {
            case 0:
                // 没有参数，绑定属性的 setter
                if property.readability.isReadonly {
                    // 只读属性，没有 setter 不绑定
                    continue
                }
                statements.append("viewModel.\(bindMethod)Target(self, action: #selector(setter: Self.\(property.name)), forKey: \"\(property.name)\")")
                
            case 1:
                let argument = bindArguments[0]
                if let valuePropertyName = argument.label {
                    // 有参数标签，为绑定值的属性的 setter
                    let key = try XZMocoaKey(bindNode, argument: argument.expression)
                    statements.append("viewModel.\(bindMethod)Target(\(property.name), action: #selector(setter: \(property.type.name).\(valuePropertyName)), forKey: \"\(key)\")")
                } else if property.readability.isReadonly {
                    // 无参数标签，绑定属性的 setter，只读属性不绑定
                    continue
                } else {
                    // 无参数标签，绑定属性的 setter
                    let key = try XZMocoaKey(bindNode, argument: argument.expression)
                    statements.append("viewModel.\(bindMethod)Target(self, action: #selector(setter: Self.\(property.name)), forKey: \"\(key)\")")
                }
                
            case 2:
                let argument0 = bindArguments[0]
                let argument1 = bindArguments[1]
                
                let vmKey = try XZMocoaKey(bindNode, argument: argument0.expression)
                
                if let viewKey = argument0.label {
                    // @bind(title: .vmKey, for: .normal)
                    let stateKey = try XZMocoaKey(bindNode, argument: argument1.expression)
                    let selector = "__mocoa_bind_\(viewKey)_\(stateKey)(_:)"
                    statements.append("viewModel.\(bindMethod)Target(\(property.name), action: #selector(\(property.type.name).\(selector)), forKey: \"\(vmKey)\")")
                } else if let viewKeyType = argument1.label {
                    switch viewKeyType {
                    case "key":
                        // @bind(.vmKey, key: vKey)
                        let viewKey = try XZMocoaKey(bindNode, argument: argument1.expression)
                        statements.append("viewModel.\(bindMethod)Target(\(property.name), action: #selector(setter: \(property.type.name).\(viewKey)), forKey: \"\(vmKey)\")")
                    case "selector":
                        // @bind(.vmkey, selector: vSEL)
                        let viewSEL = argument1.expression.expression.trimmedDescription
                        statements.append("viewModel.\(bindMethod)Target(\(property.name), action: \(viewSEL), forKey: \"\(vmKey)\")")
                    default:
                        continue
                    }
                } else {
                    continue
                }
                
            default:
                throw XZMacroError(bindNode, message: "参数错误")
            }
        }
        
        if statements.isEmpty {
            return nil
        }
        
        switch property.type.wrapation {
        case .unwrapped:
            return statements.joined(separator: "\n")
        case .optional:
            fallthrough
        case .autoUnwrapped:
            return """
            if let \(property.name) = self.\(property.name) {
                \(statements.joined(separator: "\n    "))
            }
            """
        }
    }
    
    /// 为 View 的方法生成绑定代码。
    private static func view(_ view: Any, providingStatementsOf method: XZMacroMethodInformation, in context: some MacroExpansionContext) throws -> String? {
        var statements = [String]()
        for bindNode in method.declaration.attributes {
            guard case let .attribute(bindNode) = bindNode else {
                continue
            }
            guard let bindMethod = bindNode.attributeName.as(IdentifierTypeSyntax.self)?.name.text else {
                continue
            }
            guard bindMethod == "bind" || bindMethod == "link" else {
                continue
            }
            
            let bindArguments = bindNode.representedArrayArguments;
            switch bindArguments.count {
            case 0:
                // 宏没有参数，使用方法的参数名作为 key
                // 根据 KTA 机制，绑定的方法的参数不同，值的位置也不同
                switch method.parameters.count {
                case 0:
                    // keyDidChange() 绑定方法没有参数，宏没有没有指定键名，绑定默认键 .None
                    statements.append("viewModel.\(bindMethod)Target(self, action: #selector(Self.\(method.selector)), forKey: .None)")
                case 1:
                    // keyDidChange(value:)
                    let key = method.parameters[0]
                    statements.append("viewModel.\(bindMethod)Target(self, action: #selector(Self.\(method.selector)), forKey: \"\(key)\")")
                case 2:
                    // key(_:didChangeValue:)
                    let key = method.parameters[1]
                    statements.append("viewModel.\(bindMethod)Target(self, action: #selector(Self.\(method.selector)), forKey: \"\(key)\")")
                case 3:
                    // viewModel(_:key:didChangeValue:)
                    let key = method.parameters[2]
                    statements.append("viewModel.\(bindMethod)Target(self, action: #selector(Self.\(method.selector)), forKey: \"\(key)\")")
                default:
                    continue
                }
                
            case 1:
                let key = try XZMocoaKey(bindNode, argument: bindArguments[0].expression)
                statements.append("viewModel.\(bindMethod)Target(self, action: #selector(Self.\(method.selector)), forKey: \"\(key)\")")
                
            default:
                throw XZMacroError(bindNode, message: "参数错误")
            }
        }
        
        if statements.isEmpty {
            return nil
        }
        
        return statements.joined(separator: "\n")
    }
    /// 为 ViewModel 的属性，生成绑定代码。
    private static func viewModel(_ viewModel: Any, providingStatementsOf property: XZMacroPropertyInfomation, in context: some MacroExpansionContext) throws -> String? {
        var statements = [String]()
        for bindNode in property.declaration.attributes {
            guard case let .attribute(bindNode) = bindNode else {
                continue
            }
            guard let method = bindNode.attributeName.as(IdentifierTypeSyntax.self)?.name.text else {
                continue
            }
            guard method == "bind" || method == "link" else {
                continue
            }
            
            // VM 不支持绑定属性的属性，所以只读属性不绑定。
            if property.readability.isReadonly {
                continue
            }
            
            let bindArguments = bindNode.representedArrayArguments;
            switch bindArguments.count {
            case 0:
                statements.append("NSStringFromSelector(#selector(setter: Self.\(property.name))): \"\(property.name)\"")
                
            case 1:
                let key = try XZMocoaKey(bindNode, argument: bindArguments[0].expression)
                statements.append("NSStringFromSelector(#selector(setter: Self.\(property.name))): \"\(key)\"")
                
            default:
                throw XZMacroError(bindNode, message: "参数错误")
            }
        }
        
        if statements.isEmpty {
            return nil
        }
        
        return statements.joined(separator: ", \n")
    }
    
    private static func viewModel(_ viewModel: Any, providingStatementsOf method: XZMacroMethodInformation, in context: some MacroExpansionContext) throws -> String? {
        var statements = [String]()
        for bindNode in method.declaration.attributes {
            guard case let .attribute(bindNode) = bindNode else {
                continue
            }
            guard let bindMethod = bindNode.attributeName.as(IdentifierTypeSyntax.self)?.name.text else {
                continue
            }
            guard bindMethod == "bind" || bindMethod == "link" else {
                continue
            }
            
            let bindArguments = bindNode.representedArrayArguments;
            switch bindArguments.count {
            case 0:
                switch method.parameters.count {
                case 0:
                    continue
                case 1:
                    statements.append("NSStringFromSelector(#selector(Self.\(method.selector))): \"\(method.parameters[0])\"")
                default:
                    let keys = method.parameters.map({ argument in
                        return "\"\(argument)\""
                    }).joined(separator: ", ")
                    statements.append("NSStringFromSelector(#selector(Self.\(method.selector))): [\(keys)]")
                }
                
            default:
                if bindArguments.count > method.parameters.count {
                    // 绑定的键，不能比方法参数多
                    continue
                }
                var keys = try bindArguments.map({ (expression: LabeledExprSyntax, label: String?) in
                    return try XZMocoaKey(bindNode, argument: expression)
                });
                if bindArguments.count < method.parameters.count {
                    for index in bindArguments.count ..< method.parameters.count {
                        keys.append(method.parameters[index])
                    }
                }
                
                let keyString = keys.map({ argument in
                    return "\"\(argument)\""
                }).joined(separator: ", ")
                
                statements.append("NSStringFromSelector(#selector(Self.\(method.selector))): [\(keyString)]")
            }
        }
        
        if statements.isEmpty {
            return nil
        }
        
        return statements.joined(separator: ", \n")
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
    public static func expansion(of node: AttributeSyntax, providingAttributesFor propertyDecl: VariableDeclSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext, for role: XZMacroMocoaRole) throws -> [SwiftSyntax.AttributeSyntax] {
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
    public static func expansion(of node: AttributeSyntax, providingAttributesFor methodDecl: FunctionDeclSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext, for role: XZMacroMocoaRole) throws -> [SwiftSyntax.AttributeSyntax] {
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
