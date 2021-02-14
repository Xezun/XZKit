//
//  XZKitConstantsSwiftTests.swift
//  XZKitTests
//
//  Created by 徐臻 on 2020/1/30.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import XCTest
import XZKit
import System

class XZKitConstantsSwiftTests: XCTestCase {

    override func setUp() {
        XZLog("isDebugMode: %@", isDebugMode);
    }

    override func tearDown() {
        
    }

    func testTimestamp() {
        // 测试时间戳
        let ts1 = TimeInterval.since1970;
        let ts2 = Date().timeIntervalSince1970;
        XZLog("当前时间戳：%f -- %f", ts1, ts2);
        
        XCTAssert(ts2 - ts1 < 1, "时间戳校验失败")
    }
    
    func testString() {
//        let string1 = String.init(formats: "%@ %02ld %.2f", "对象", 2, CGFloat.pi);
//        let string2 = String.init(formats: "%@ %@ %@", "对象", 2, CGFloat.pi);
//        XZLog("string1: \(string1), \nstring2: \(string2)")
//
//        XZLog("cast NSNull to string: %@", String(casting: NSNull()))
//        XZLog("cast object to string: %@", String(casting: self))
//        XZLog("cast option to string: %@", self.accessibilityAttributedLabel)
//
//        NSLog("----%@", self);
//
//        XZLog("%@", String(isolating: "We are Super Man.", direction: .leftToRight));
//        XZLog("%@", String(isolating: "We are Super Man.", direction: .rightToLeft));
//        XZLog("%@", String(isolating: "We are Super Man.", direction: .firstStrong));
//
//        XZLog("%@", "   234f \n".trimmingCharacters(in: " \t\n"))
//        XZLog("%@", "我是中国人".transformingMandarinToLatin);
//
//        XZLog("%@", "https://www.baidu.com/?keyword=中国#2".addingURIEncoding)
//        XZLog("%@", "https://www.baidu.com/?keyword=中国#2".addingURIComponentEncoding)
//
//        XZLog("%@", """
//        第一行：ABC
//        第二行：EDF
//        """)
//
//
    }

    func testPerformanceExample() {
        // [0.011290, 0.008196, 0.007949, 0.008206, 0.008206, 0.008253, 0.008267, 0.008579, 0.008491, 0.008132]
        // Date: [0.011474, 0.008832, 0.008229, 0.008394, 0.008201, 0.008248, 0.008208, 0.008573, 0.008843, 0.008660]
        //                            _ = TimeInterval.since1970
        self.measure {
//            for _ in 0 ..< 1000 {
//
//            }
            var i = 0
            while i < 10000 {
                i += 1
            }
            
        }
        

        
    }
    
}



