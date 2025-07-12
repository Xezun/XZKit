//
//  XZKitMacros.swift
//  XZKit
//
//  Created by 徐臻 on 2025/7/11.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

@main
struct XZKitMacros: CompilerPlugin {
    
    let providingMacros: [Macro.Type]
    
    init() {
        var providingMacros = [Macro.Type]()
        
        providingMacros.append(contentsOf: XZLogMacros.providingMacros)
        providingMacros.append(contentsOf: XZMocoaMacros.providingMacros)
        
        self.providingMacros = providingMacros
    }
    
}
