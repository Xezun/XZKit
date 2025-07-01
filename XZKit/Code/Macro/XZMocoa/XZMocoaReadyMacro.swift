//
//  XZMocoaReadyMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/13.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

public struct XZMocoaReadyMacro: BodyMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingBodyFor declaration: some SwiftSyntax.DeclSyntaxProtocol & SwiftSyntax.WithOptionalCodeBlockSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            throw Message("@ready: 仅可用于方法")
        }
        guard declaration.signature.parameterClause.parameters.count == 0 else {
            throw Message("@ready: 初始化方法没有参数")
        }
        
        guard declaration.modifiers.contains(where: { $0.name.text == "private" || $0.name.text == "fileprivate" }) else {
            throw Message("@ready: 初始化方法必须使用 private 或 fileprivate 标记")
        }
        
        return []
    }
    
}
