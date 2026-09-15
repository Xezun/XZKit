//
//  XZFormatStringTests.swift
//  ExampleTests
//
//  Created by Mac on 2026/9/15.
//

import UIKit
import XCTest
import XZKit

class XZFormatStringTests: XCTestCase {
    
    override class func setUp() {
        
    }
    
    func testCase1() {
        let string = String.init(formal: "This is %.2f", 12.0);
        print(string)
        XCTAssertEqual(string, "This is 12.00")
    }
    
    func testCase2() {
        struct Foobar {
            let a: Int
            let b: Int
        }
        let value = Foobar.init(a: 1, b: 2)
        let string = String(formal: "This is %@", value)
        print(string)
        XCTAssertEqual(string, "This is \(value)")
    }
    
    func testCase3() {
        
    }
    
}
