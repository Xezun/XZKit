//
//  XZMocoaModuleMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import Foundation

/// 宏 `#module(URL)` 的实现。
public struct XZMocoaModuleMacro: ExpressionMacro {
    
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard node.arguments.count == 1, let argument = node.arguments.first else {
            throw XZMocoaMacroError.message("仅支持“模块地址”作为参数")
        }
        
        if let exprSyntax = argument.expression.as(StringLiteralExprSyntax.self) {
            guard let string = exprSyntax.representedLiteralValue, string.count > 0 else {
                throw XZMocoaMacroError.message("模块地址不能为空")
            }
            guard URL.init(string: string) != nil else {
                throw XZMocoaMacroError.message("模块地址不是合法的 URL 字符串")
            }
            return "XZMocoaModule(for: URL(string: \(raw: exprSyntax.trimmedDescription)))!"
        }
        
        return "XZMocoaModule(for: \(raw: argument.expression.trimmedDescription))!"
    }
}
