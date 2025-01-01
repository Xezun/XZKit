//
//  XZTimeTickerTests.swift
//  XZKitTests
//
//  Created by Xezun on 2021/2/6.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

import XCTest
import XZKit

class XZTimeTickerTests: XCTestCase, TimeTickerDelegate {
    
    let timeTiker = TimeTicker.init()
    var expectation: XCTestExpectation?
    

    override func setUpWithError() throws {
        timeTiker.delegate     = self
    }

    override func tearDownWithError() throws {
        
    }
    
    func testExample1() throws {
        expectation = expectation(description: "常规情况：时长与间隔能够整除")
        
        timeTiker.duration     = 3.0
        timeTiker.timeInterval = 1.0
        
        resumeTimeTicker()
    }
    
    func testExample2() throws {
        expectation = expectation(description: "常规情况：时长与间隔不能整除")
        
        timeTiker.duration     = 3.5
        timeTiker.timeInterval = 1.0
        
        resumeTimeTicker()
    }
    
    func testExample3() throws {
        expectation = expectation(description: "常规情况：使用默认值直接启动")
        
        resumeTimeTicker()
    }
    
    func testExample4() throws {
        expectation = expectation(description: "异常情况：时长为0.0，间隔为1.0")
        
        timeTiker.duration     = 0
        timeTiker.timeInterval = 1.0
        
        resumeTimeTicker()
    }
    
    func testExample5() throws {
        expectation = expectation(description: "异常情况：时长为1.0，间隔为0.0")
        
        timeTiker.duration     = 1.0
        timeTiker.timeInterval = 0.0
        
        resumeTimeTicker()
    }
    
    func testExample6() throws {
        expectation = expectation(description: "异常情况：时长为-1.0，间隔为-1.0")
        
        timeTiker.duration     = -1.0
        timeTiker.timeInterval = -1.0
        
        resumeTimeTicker()
    }
    
    func testExample7() throws {
        expectation = expectation(description: "异常情况：时长为+0.0，间隔为-1.0")
        
        timeTiker.duration     = +0.0
        timeTiker.timeInterval = -1.0
        
        resumeTimeTicker()
    }
    
    func testExample8() throws {
        expectation = expectation(description: "异常情况：时长为-1.0，间隔为+0.0")
        
        timeTiker.duration     = -1.0
        timeTiker.timeInterval = +0.0
        
        resumeTimeTicker()
    }
    
    func testExample9() throws {
        expectation = expectation(description: "异常情况：时长为+1.0，间隔为-1.0")
        
        timeTiker.duration     = +1.0
        timeTiker.timeInterval = -1.0
        
        resumeTimeTicker()
    }
    
    func testExample10() throws {
        expectation = expectation(description: "异常情况：时长为-1.0，间隔为+1.0")
        
        timeTiker.duration     = -1.0
        timeTiker.timeInterval = +1.0
        
        resumeTimeTicker()
    }
    
    func resumeTimeTicker() {
        timeTiker.resume()
        XZLog("%@", expectation?.expectationDescription)
        
        let timeout = max(0.1, timeTiker.duration + 0.5)
        self.waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XZLog("TimeTiker 执行出错：\(error)")
            } else {
                XZLog("TimeTiker 执行正常")
            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            
        }
    }
    
    func timeTicker(_ timeTicker: TimeTicker, didTick timeInterval: TimeInterval) {
        XZLog("%.2f/%.2f: %.2f", timeTiker.currentTime, timeTiker.duration, timeInterval)
        
        if timeTiker.isPaused {
            expectation?.fulfill()
        }
    }

}
