//
//  NSURLMacro.swift
//  XZKit
//
//  Created by 徐臻 on 2026/7/25.
//

import Foundation

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

/// 宏 `URL(_:)` 的实现。
public struct NSURLMacro: ExpressionMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard let expression = node.arguments.first?.expression else {
            throw XZMacroError(message: "#URL: 缺少参数")
        }
        guard let urlString = expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue else {
            throw XZMacroError(message: "#URL: 请使用静态字符串")
        }
        guard URL(string: urlString) != nil else {
            throw XZMacroError(message: "#URL: 参数不合法")
        }
        return "URL(string: \(raw: expression))!"
    }
    
}
