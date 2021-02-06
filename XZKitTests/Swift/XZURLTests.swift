//
//  XZURLTests.swift
//  XZKitTests
//
//  Created by 徐臻 on 2020/5/16.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import XCTest
import XZKit

class XZURLTests: XCTestCase {

    override func setUpWithError() throws {
        print("XZKit Debug Mode: \(XZKit.isDebugMode)")
    }

    override func tearDownWithError() throws {
        
    }

    func testExample() throws {
        guard var url = URL(string: "https://www.xezun.com/s?a=1&b=2&c=3&e=&f&=g&a=11") else { return }
        XZLog("queryComponent: %@", url.queryComponent)
        
        XZLog("验证 keyedValues 属性：\n%@", String(json: url.queryComponent?.keyedValues, options: .prettyPrinted))
        
        
        
        url.queryComponent?.addValue("addValue", forKey: "d")
        XZLog("%@", url)
    }
    
    func testSetValueForKey() throws {
        XZLog("测试 setValue(_:forKey:) 方法开始！")
        
        guard var url = URL(string: "https://www.xezun.com/?b=3&c=7&d=1&d=2") else { return }
        XZLog("原始URL：%@", url)
        
        url.queryComponent?.setValue("a1", forKey: "a")
        XZLog("设置字段a=a1：%@", url)
        
        url.queryComponent?.setValue(NSNull.init(), forKey: "a")
        XZLog("设置字段a=NSNull：%@", url)
        
        url.queryComponent?.setValue(2, forKey: "a")
        XZLog("设置字段a=2：%@", url)
        
        url.queryComponent?.setValue(nil, forKey: "a")
        XZLog("设置字段a=nil：%@", url)
        
        url.queryComponent?.setValue(["a1"], forKey: "a")
        XZLog("设置字段a=[a1]：%@", url)
        
        url.queryComponent?.setValue(["a2", "a3"], forKey: "a")
        XZLog("设置字段a=[a2, a3]：%@", url)
        
        url.queryComponent?.setValue(["a4", "a5", "a6"], forKey: "a")
        XZLog("设置字段a=[a4, a5, a6]：%@", url)
        
        url.queryComponent?.setValue(["a7", "a8"], forKey: "a")
        XZLog("设置字段a=[a7, a8]：%@", url)
        
        url.queryComponent?.setValue(["a9"], forKey: "a")
        XZLog("设置字段a=[a9]：%@", url)
        
        url.queryComponent?.setValue(["a4", "a5", "a6"], forKey: "a")
        XZLog("设置字段a=[a4, a5, a6]：%@", url)
        
        url.queryComponent?.setValue("a7", forKey: "a")
        XZLog("设置字段a=[a7]：%@", url)
        
        url.queryComponent?.setValue(["a4", "a5", "a6"], forKey: "a")
        XZLog("设置字段a=[a4, a5, a6]：%@", url)
        
        url.queryComponent?.setValue(nil, forKey: "a")
        XZLog("设置字段a=nil：%@", url)
        
        XZLog("测试 setValue(_:forKey:) 方法结束！")
    }
    
    func testAddValueForKey() throws {
        guard var url = URL(string: "https://www.xezun.com/?b=3&c=7&d=1&d=2") else { return }
        XZLog("原始URL：%@", url)
        
        url.queryComponent?.addValue("a1", forKey: "a")
        XZLog("%@", url)
        
        url.queryComponent?.addValue("b1", forKey: "b")
        XZLog("%@", url)
        
        url.queryComponent?.addValue(["b4", "b2"], forKey: "b")
        XZLog("%@", url)
        
        url.queryComponent?.addValue(nil, forKey: "b")
        XZLog("%@", url)
    }
    
    func testValueForKey() throws {
        guard let url = URL(string: "https://www.xezun.com/?b=3&c=7&d=1&d=2") else { return }
        XZLog("原始URL：%@", url)
        
        XZLog("%@", url.queryComponent?.value(forKey: "a"))
        XZLog("%@", url.queryComponent?.value(forKey: "b"))
        XZLog("%@", url.queryComponent?.value(forKey: "c"))
        XZLog("%@", url.queryComponent?.value(forKey: "d"))
    }

    func testRemoveValueForKey() {
        guard var url = URL(string: "https://www.xezun.com/?b=3&c=7&d=1&d=2") else { return }
        XZLog("原始URL：%@", url)
        
        url.queryComponent?.removeValue(nil, forKey: "a")
        XZLog("%@", url)
        
        url.queryComponent?.removeValue("3", forKey: "b")
        XZLog("%@", url)
        
        url.queryComponent?.removeValue(["1", "2"], forKey: "d")
        XZLog("%@", url)
    }
    
    func testRemoveValueForKey2() {
        guard var url = URL(string: "https://www.xezun.com/?b=3&c=7&d=1&d=2") else { return }
        XZLog("原始URL：%@", url)
        
        url.queryComponent?.removeValue(forKey: "b")
        XZLog("%@", url)
        
        url.queryComponent?.removeValue(forKey: "d")
        XZLog("%@", url)
    }
    
    
    func testContainsKey() {
        guard let url = URL(string: "https://www.xezun.com/?b=3&c=7&d=1&d=2") else { return }
        XZLog("原始URL：%@", url)
        
        XZLog("%@", url.queryComponent?.contains(key: "a"))
        XZLog("%@", url.queryComponent?.contains(key: "b"))
        XZLog("%@", url.queryComponent?.contains(key: "d"))
    }
    
    func testAddValuesForKeysFrom() {
        guard var url = URL(string: "https://www.xezun.com/?b=3&c=7&d=1&d=2") else { return }
        XZLog("原始URL：%@", url)
        
        url.queryComponent?.addValuesForKeys(from: "a")
        XZLog("%@", url)
        
        url.queryComponent?.addValuesForKeys(from: "b")
        XZLog("%@", url)
        
        url.queryComponent?.addValuesForKeys(from: ["a": 1, "b": "2"])
        XZLog("%@", url)
        
        url.queryComponent?.addValuesForKeys(from: ["c", "d"])
        XZLog("%@", url)
    }
    
    func testSetValuesForKeysFrom() {
        guard var url = URL(string: "https://www.xezun.com/?b=3&c=7&d=1&d=2") else { return }
        XZLog("原始URL：%@", url)
        
        url.queryComponent?.setValuesForKeys(from: "a")
        XZLog("%@", url)
        
        url.queryComponent?.setValuesForKeys(from: "b")
        XZLog("%@", url)
        
        url.queryComponent?.setValuesForKeys(from: ["a": 1, "b": "2"])
        XZLog("%@", url)
        
        url.queryComponent?.setValuesForKeys(from: ["c", "d"])
        XZLog("%@", url)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
