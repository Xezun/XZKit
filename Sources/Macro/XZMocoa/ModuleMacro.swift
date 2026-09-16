//
//  ModuleMacro.swift
//  XZKit
//
//  Created by Xezun on 2025/6/10.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import Foundation

/// 宏 `#module(URL)` 的实现。
public struct ModuleMacro: ExpressionMacro {
    
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard node.arguments.count == 1, let argument = node.arguments.first else {
            throw XZMacroError(message: "#module: 仅支持“模块地址”作为参数")
        }
        
        // 参数不是字符串
        guard let exprSyntax = argument.expression.as(StringLiteralExprSyntax.self) else {
            return "XZMocoaModule(for: \(raw: argument.expression.trimmedDescription))!"
        }
        
        // 参数是字符串
        guard let string = exprSyntax.representedLiteralValue, string.count > 0 else {
            throw XZMacroError(message: "#module: 模块地址不能为空")
        }
        
        // 字符串不是合法的 URL
        guard let url = URL.init(string: string) else {
            throw XZMacroError(message: "#module: 模块地址不是合法的 URL 字符串")
        }
        
        // 系统版本判断（实际无必要）
        guard #available(iOS 16.0, *) else {
            throw XZMacroError(message: "#module: 模块地址不是合法的 URL 字符串")
        }
        
        let path = url.path()
        
        // 校验字符串格式
        if path.count > 0 {
            if path.hasSuffix("/") {
                throw XZMacroError(message: "#module: 请移除模块地址末尾的“/”字符")
            }
            
            let range = NSMakeRange(0, (path as NSString).length);
            if self.regularExpression.rangeOfFirstMatch(in: path, range: range).location == NSNotFound {
                throw XZMacroError(message: "#module: 地址 path 不符合 kind:|kind:name|:|name 格式")
            }
        }
        
        return "XZMocoaModule(for: URL(string: \(raw: exprSyntax.trimmedDescription)))!"
    }
    
    static let regularExpression = try! NSRegularExpression(pattern: "^(/(([\\w\\-\\.]+:{0,1}[\\w\\-\\.]*)|(:)))+$")
}
