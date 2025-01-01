//
//  FoundationSwiftTests.swift
//  XZKitTests
//
//  Created by Xezun on 2021/2/15.
//

import Foundation
import XCTest
import XZKit

class FoundationSwiftTests: XCTestCase {
    
    func testXZLog() {
        XZLog("查看控制台输出，带额外字符文件、方法、时间信息：%@", self);
    }
    
    func testHexEncoding() {
        let contentRAW = "XZKit - iOS框架";
        let contentHexLower = "585a4b6974202d20694f53e6a186e69eb6";
        let contentHexUpper = "585A4B6974202D20694F53E6A186E69EB6";
        
        if contentRAW.addingHexEncoding != contentHexLower {
            XCTFail("编码 16 进制小写失败");
        }
        
        if contentHexLower.removingHexEncoding != contentRAW {
            XCTFail("解码 16 进制失败");
        }
        
        if contentRAW.addingHexEncoding(with: .uppercase) != contentHexUpper {
            XCTFail("编码 16 进制大写失败");
        }
        
        if contentHexUpper.removingHexEncoding != contentRAW {
            XCTFail("解码 16 进制失败");
        }
    }
    
    func testJSON() {
        let dict = ["name": "John"];
        
        XZLog("%@", dict.JSON(encoding: .utf8));
        XZLog("%@", ["John", "Smith"].JSON(encoding: .utf8));
        
        let json = "{\"name\":\"John\"}"
        
        XZLog("%@", Dictionary<NSString, Any>.init(JSON: json))
    }
    
}
