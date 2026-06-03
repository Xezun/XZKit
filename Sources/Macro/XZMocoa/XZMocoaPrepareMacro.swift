//
//  XZMocoaPrepareMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/13.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

public struct XZMocoaPrepareMacro: BodyMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingBodyFor declaration: some SwiftSyntax.DeclSyntaxProtocol & SwiftSyntax.WithOptionalCodeBlockSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            throw XZMacroError(message: "@prepare: 仅可用于方法")
        }
        
        guard declaration.signature.parameterClause.parameters.count == 0 else {
            throw XZMacroError(message: "@prepare: 初始化方法没有参数")
        }
        
        return []
    }
    
}
