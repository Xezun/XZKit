//
//  XZMocoaMacros.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/7.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics

public struct XZMocoaMacros: Sendable {
    
    nonisolated(unsafe) static let providingMacros: [Macro.Type] = [
        XZMocoaMacro.self,
        XZMocoaModuleMacro.self,
        XZMocoaKeyMacro.self,
        XZMocoaBindMacro.self,
        XZMocoaBindViewMacro.self,
        XZMocoaReadyMacro.self
    ]
    
}

public enum XZMocoaRole: String {
    case m
    case v
    case vm
}
