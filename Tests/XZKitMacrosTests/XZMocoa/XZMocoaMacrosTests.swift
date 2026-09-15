//
//  XZMocoaMacrosTests.swift
//  XZKit
//
//  Created by Xezun on 2025/6/9.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(XZKitMacros)
import XZKitMacros

let testMacros: [String: Macro.Type] = [
    "URL": URLMacro.self,
    "XZLog": XZLogMacro.self
]

#endif

final class XZMocoaMacrosTests: XCTestCase {
    
    func testMacro() throws {
        #if canImport(XZKitMacros)
        assertMacroExpansion(
            """
            #URL("https://xzkit.xezun.com")
            """,
            expandedSource: """
            URL(string: "https://xzkit.xezun.com")!
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(XZKitMacros)
        assertMacroExpansion(
            #"""
            #XZLog("message")
            """#,
            expandedSource: #"""
            "message"
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
