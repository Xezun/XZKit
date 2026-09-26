//
//  XZDataDigesterTests.swift
//  XZKitTests
//
//  Created by 徐臻 on 2026/9/25.
//

import Testing
import XZKit

struct XZDataDigesterTests {

    @Test func sha1() async throws {
        let string = "123"
        #expect(string.sha1 == "40bd001563085fc35165329ea1ff5c5ecbdbbeef")
        #expect(string.sha256 == "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3")
    }

}
