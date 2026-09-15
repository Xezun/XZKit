//
//  File.swift
//  XZKit
//
//  Created by Mac on 2026/9/15.
//

import XCTest
import XZKit

final class XZFormatStringTests: XCTestCase {
    
    override func setUp() {
        let string = String.init(formal: "This is %.2f", 12);
        print(string)
    }
}

