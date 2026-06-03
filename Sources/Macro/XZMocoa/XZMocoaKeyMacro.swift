//
//  XZMocoaKeyMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

// @key
// @key("name")
// @key("name", value: "123")

public struct XZMocoaKeyMacro {
    
    /// 解析 `@key` 宏的参数。供外部调用。
    public static func arguments(from node: SwiftSyntax.AttributeSyntax, for declaration: VariableDeclSyntax) throws -> (name: String, initialValue: String?) {
        guard let expression = declaration.bindings.first else {
            throw XZMacroError(message: "@key: 无法确定属性名")
        }
        return try arguments(forMacro: node, forVariable: expression)
    }
    
    /// 解析 `@key` 宏的参数。
    /// - Parameters:
    ///   - node: 宏节点
    ///   - expression: 属性表达式
    /// - Returns: 表示键名的 name 和初始值 value 的元组
    public static func arguments(forMacro node: SwiftSyntax.AttributeSyntax, forVariable expression: PatternBindingSyntax) throws -> (name: String, initialValue: String?) {
        guard let macroArguments = node.arguments else {
            guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                throw XZMacroError(message: "@key: 无法确定属性名")
            }
            return (name, nil)
        }
        return try arguments(froMarco: macroArguments, forVariable: expression)
    }
    
    /// 解析宏 `@key` 的参数。
    private static func arguments(froMarco arguments: SwiftSyntax.AttributeSyntax.Arguments, forVariable expression: PatternBindingSyntax) throws -> (name: String, initialValue: String?) {
        switch arguments {
        case .argumentList(let arguments):
            switch arguments.count {
            case 0:
                // 没有参数，使用属性名
                guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                    throw XZMacroError(message: "@key: 无法确定属性名")
                }
                return (name, nil)
                
            case 1:
                let firstArgument = arguments[arguments.startIndex]
                
                if let label = firstArgument.label?.trimmedDescription {
                    if label == "value" {
                        guard let name = expression.pattern.as(IdentifierPatternSyntax.self)?.identifier.text, name.count > 0 else {
                            throw XZMacroError(message: "@key: 无法确定属性名")
                        }
                        return (name, firstArgument.expression.trimmedDescription)
                    }
                    throw XZMacroError(message: "@key: 第一个参数必须是 value 标签，而不能是 \(label) 标签")
                }
                
                if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
                    if let stringValue = stringLiteral.representedLiteralValue?.replacingOccurrences(of: ".", with: "_"), stringValue.count > 0 {
                        return (stringValue, nil)
                    }
                } else if let mocoaKeySyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
                    let mocoaKey = mocoaKeySyntax.declName.trimmedDescription
                    return (mocoaKey, nil)
                }
                
                throw XZMacroError(message: "@key: 第一个参数必须为 String 字面量或 XZMocoaKey 枚举，而不能是 \(firstArgument.expression) 值")
                
            case 2:
                let value = arguments[arguments.index(after: arguments.startIndex)].expression.trimmedDescription
                
                let firstArgument = arguments[arguments.startIndex]
                
                // 检查是否为字面量
                if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
                    if let stringValue = stringLiteral.representedLiteralValue?.replacingOccurrences(of: ".", with: "_"), stringValue.count > 0 {
                        return (stringValue, value)
                    }
                    throw XZMacroError(message: "@key: 第一参数不能为空，若不想提供，请使用 value 标签直接提供第二个参数")
                }
                
                // 检查是否 .key 语法
                if let mocoaKeySyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
                    let mocoaKey = mocoaKeySyntax.declName.trimmedDescription
                    return (mocoaKey, value)
                }
                
                throw XZMacroError(message: "@key: 第一个参数必须为 String 字面量或 XZMocoaKey 枚举，而不能是 \(firstArgument.expression) 值")
                
            default:
                throw XZMacroError(message: "@key: 最多支持两个参数（name, initialValue)")
                
            }
        default:
            throw XZMacroError(message: "@key: not supported arguments \(arguments)")
        }
    }
    
    
    public static func keyName(from node: SwiftSyntax.AttributeSyntax) -> String? {
        guard let firstArgument = node.arguments?.first?.value else {
            return nil
        }
            
        if let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self) {
            if let stringValue = stringLiteral.representedLiteralValue?.replacingOccurrences(of: ".", with: "_"), stringValue.count > 0 {
                return stringValue
            }
            return nil
        }
        
        if let memberSyntax = firstArgument.expression.as(MemberAccessExprSyntax.self) {
            return memberSyntax.declName.trimmedDescription
        }
        
        return nil
    }
}

extension XZMocoaKeyMacro: PeerMacro {
    
    /// 校验属性和宏，并生成存储属性。
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        switch try XZMocoaRole.init(node: node, context: context) {
        case .m:
            return []
            
        case .v:
            return []
            
        default:
            guard let propertyDecl = declaration.as(VariableDeclSyntax.self) else {
                throw XZMacroError(message: "@key: 此宏只能附加到 var 属性");
            }
            
            guard propertyDecl.bindingSpecifier.text == "var" else {
                throw XZMacroError(message: "@key: 此宏只能附加到 var 属性")
            }
            
            guard propertyDecl.bindings.count == 1, let binding = propertyDecl.bindings.first else {
                throw XZMacroError(message: "@key: 此宏无法同时附加给多个属性")
            }
            
            if let arguments = node.arguments, arguments.count > 1 {
                throw XZMacroError(message: "@key: 此宏的参数仅支持指定名称，不支持其它参数")
            }
            
            guard let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                throw XZMacroError(message: "@key: 宏无法确定属性名")
            }
            
            if let propertyType = binding.typeAnnotation?.type.trimmedDescription {
                if let initializer = propertyDecl.bindings.first?.initializer?.value.trimmedDescription {
                    return ["private var _\(raw: propertyName) : \(raw: propertyType) = \(raw: initializer)"]
                }
                
                return ["private var _\(raw: propertyName) : \(raw: propertyType)"]
            }
            
            guard let initializer = propertyDecl.bindings.first?.initializer?.value.trimmedDescription else {
                throw XZMacroError(message: "@key: 宏无法确定属性值类型")
            }
            
            return ["private var _\(raw: propertyName) = \(raw: initializer)"]
        }
    }
    
}

/// 宏 `@key("key")` 的实现： 生成 setter/getter 方法。
extension XZMocoaKeyMacro: AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        switch try XZMocoaRole(node: node, context: context) {
        case .m:
            throw XZMacroError(message: "@key: 此宏暂不支持在 Model 角色中使用，若要观察该属性，请使用 dynamic 修饰符")
            
        case .v:
            throw XZMacroError(message: "@key: 此宏暂不支持在 View 角色中使用")
            
        case .vm:
            guard let propertyDecl = declaration.as(VariableDeclSyntax.self) else {
                throw XZMacroError.init(message: "@key: 只支持属性")
            }
            
            let binding = propertyDecl.bindings[propertyDecl.bindings.startIndex]
            
            var setAccessor : SwiftSyntax.AccessorDeclSyntax? = nil;
            var getAccessor : SwiftSyntax.AccessorDeclSyntax? = nil;
            var didSetAccessor: SwiftSyntax.AccessorDeclSyntax? = nil;
            var willSetAccessor: SwiftSyntax.AccessorDeclSyntax? = nil;
            
            if let block = binding.accessorBlock {
                switch block.accessors {
                case .accessors(let list):
                    for item in list {
                        switch item.accessorSpecifier.text {
                        case "get":
                            getAccessor = item
                        case "set":
                            setAccessor = item;
                        case "didSet":
                            didSetAccessor = item;
                        case "willSet":
                            willSetAccessor = item;
                        default:
                            break
                        }
                    }
                    break
                case .getter:
                    throw XZMacroError(message: "@key: 只读属性无法作为 key 使用");
                }
            }
            
            guard let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                throw XZMacroError(message: "@key: 宏无法确定属性名")
            }
            
            var results = [AccessorDeclSyntax]()
            
            if getAccessor == nil {
                results.append("""
                get { 
                    return _\(raw: propertyName) 
                }
                """)
            }
            
            let keyName = self.keyName(from: node) ?? propertyName
            
            if let setAccessor = setAccessor {
                if let setAccessor = setAccessor.body?.statements {
                    results.append(
                        """
                        set {
                            defer {
                                \(setAccessor)
                            }
                            
                            if _\(raw: propertyName) != newValue {
                                _\(raw: propertyName) = newValue
                                sendActions(forKey: "\(raw: keyName)", value: newValue)
                            }
                        }
                        """
                    )
                } else {
                    results.append(
                        """
                        set {
                            if _\(raw: propertyName) != newValue {
                                _\(raw: propertyName) = newValue
                                sendActions(forKey: "\(raw: keyName)", value: newValue)
                            }
                        }
                        """
                    )
                }
            } else {
                if let willSetAccessor = willSetAccessor?.body?.statements {
                    if let didSetAccessor = didSetAccessor?.body?.statements {
                        results.append(
                            """
                            set {
                                ({ // willSet
                                    \(willSetAccessor)
                                })()
                            
                                if _\(raw: propertyName) != newValue {
                                    _\(raw: propertyName) = newValue
                                    sendActions(forKey: "\(raw: keyName)", value: newValue)
                                }
                                
                                ({ // didSet
                                    \(didSetAccessor)
                                })()
                            }
                            """
                        )
                    } else {
                        results.append(
                            """
                            set {
                                ({ // willSet
                                    \(willSetAccessor)
                                })()
                            
                                if _\(raw: propertyName) != newValue {
                                    _\(raw: propertyName) = newValue
                                    sendActions(forKey: "\(raw: keyName)", value: newValue)
                                }
                            }
                            """
                        )
                    }
                } else if let didSetAccessor = didSetAccessor?.body?.statements {
                    results.append(
                        """
                        set {
                            if _\(raw: propertyName) != newValue {
                                _\(raw: propertyName) = newValue
                                sendActions(forKey: "\(raw: keyName)", value: newValue)
                            }
                            
                            ({ // didSet
                                \(didSetAccessor)
                            })()
                        }
                        """
                    )
                } else {
                    results.append(
                        """
                        set {
                            if _\(raw: propertyName) != newValue {
                                _\(raw: propertyName) = newValue
                                sendActions(forKey: "\(raw: keyName)", value: newValue)
                            }
                        }
                        """
                    )
                }
            }
            
            return results
        }
        
        
    }
    
}


