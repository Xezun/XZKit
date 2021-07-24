//
//  CategorySwiftTests.swift
//  XZKitTests
//
//  Created by Xezun on 2021/2/16.
//

import XCTest
import XZKit

class CategorySwiftTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUIColor() throws {
        do { // 测试 rgb 函数
            let color = rgb(0x112233);
            let value = color.xzColor
            XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0xff);
        }; do {
            let color = rgb(0x11, 0x22, 0x33);
            let value = color.xzColor
            XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0xff);
        }; do {
            let color = rgb(0.1, 0.2, 0.3);
            let value = color.xzColor
            XCTAssert(
                value.red == Int(round(0.1 * 255))
                    && value.green == Int(round(0.2 * 255))
                    && value.blue == Int(round(0.3 * 255))
                    && value.alpha == 0xff
            );
        }; do {
            let color = rgb("0x112233");
            let value = color.xzColor
            XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0xff);
        }
        
        do { // 测试 rgba 函数
            let color = rgba(0x11223344);
            let value = color.xzColor
            XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0x44);
        }; do {
            let color = rgba(0x11, 0x22, 0x33, 0x44);
            let value = color.xzColor
            XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0x44);
        }; do {
            let color = rgba(0.1, 0.2, 0.3, 0.4);
            let value = color.xzColor
            XCTAssert(value.red == Int(round(0.1 * 255)) && value.green == Int(round(0.2 * 255)) && value.blue == Int(round(0.3 * 255)) && value.alpha == Int(round(0.4 * 255)));
        }; do {
            let color = rgba("0x11223344");
            let value = color.xzColor
            XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0x44);
        }
        
        do { // 异常 case 测试
            let color = rgba("color: #00FF0033;");
            let value = color.xzColor
            XCTAssert(value.red == 0x00 && value.green == 0xff && value.blue == 0x00 && value.alpha == 0x33);
        }; do {
            let color = rgba("1234567890");
            let value = color.xzColor
            XCTAssert(value.red == 0x12 && value.green == 0x34 && value.blue == 0x56 && value.alpha == 0x78);
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
