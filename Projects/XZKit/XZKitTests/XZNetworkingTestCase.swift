//
//  XZNetworkingTestCase.swift
//  XZKitTests
//
//  Created by Xezun on 2020/6/14.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import XCTest
import XZKit

//class XZNetworkingTestCase: XCTestCase, TestAPIManagerDelegate {
//    
//    var finished = [Int]()
//    
//    func manager(_ manager: TestAPIManager, request: TestAPIRequest, didFailWith error: APIError) {
//        exp.fulfill()
//    }
//    
//    func manager(_ manager: TestAPIManager, request: TestAPIRequest, didReceive response: TestAPIResponse) {
//        exp.fulfill()
//        finished.append(request.index)
//    }
//    
//    var manager1: TestAPIManager! = TestAPIManager.init()
//    var manager2: TestAPIManager! = TestAPIManager.init()
//    
//    lazy var group: APIGroup! = APIGroup.init()
//    
//    override func setUp() {
//        manager1.delegate = self
//        manager2.delegate = self
//
//        manager1.group = group
//        manager2.group = group
//    }
//    
//    override func tearDown() {
//        manager1 = nil
//        manager2 = nil
//        group = nil
//    }
//    
//    lazy var exp = XCTestExpectation.init(description: "")
//    
//    func testSend() {
//        
//        exp = self.expectation(description: "")
//        
//        exp.expectedFulfillmentCount = 20
//        
//        for id in 0 ..< 10 {
//            self.manager1.send(.init(index: id))
//        }
//        
//        for id in 10 ..< 20 {
//            self.manager2.send(.init(index: id))
//        }
//        
//        self.waitForExpectations(timeout: 60) { (error) in
//            XZLog("%@", String.init(json: self.finished, options: [.prettyPrinted, .sortedKeys]))
//        }
//        
//    }
//    
//}
//
//
//struct TestAPIRequest: APIRequest {
//    
//    init(index: Int) {
//        self.index = index
//    }
//    
//    let index: Int
//    
//    var url: URL {
//        return URL(string: "https://api.xezun.com/app/\(index)")!
//    }
//    
//    var concurrencyPolicy: APIConcurrency.Policy {
//        return .wait(priority: APIConcurrency.Priority.init(rawValue: index))
//    }
//    
//    var retryIfFailed: Bool {
//        return false
//    }
//    
//}
//
//struct TestAPIResponse: APIResponse {
//    
//    let result: URL
//    
//    init(_ request: TestAPIRequest, data: Any?) throws {
//        guard let result = data as? URL else { throw APIError.unexpectedResponse }
//        self.result = result
//    }
//    
//    typealias Request = TestAPIRequest
//    
//}
//
//protocol TestAPIManagerDelegate: class {
//    
//    func manager(_ manager: TestAPIManager, request: TestAPIRequest, didFailWith error: APIError)
//    func manager(_ manager: TestAPIManager, request: TestAPIRequest, didReceive response: TestAPIResponse)
//}
//
//class TestAPIManager: APIManager {
//    
//    weak var delegate: TestAPIManagerDelegate?
//    
//    func request(_ request: TestAPIRequest, didProcess progress: (completed: Int64, total: Int64)) {
//        XZLog("%@: %.2f", request, Double(fraction: progress))
//    }
//    
//    
//    func request(_ request: TestAPIRequest, didCollect data: Any?) throws -> TestAPIResponse {
//        guard let dict = data as? [String: Any] else { throw APIError.unexpectedResponse }
//        guard let code = dict["code"] as? Int else { throw APIError.unexpectedResponse }
//        guard code == noErr else {
//            let message = dict["message"] as? String
//            throw APIError.init(code: code, message: message ?? "Unknown")
//        }
//        return try TestAPIResponse(request, data: dict["result"])
//    }
//    
//    func request(_ request: TestAPIRequest, didReceive response: TestAPIResponse) {
//        delegate?.manager(self, request: request, didReceive: response)
//    }
//    
//    func request(_ request: TestAPIRequest, didFailWith error: APIError) -> TimeInterval? {
//        if let numberOfRetries = error.numberOfRetries {
//            let d = Int.random(in: 1 ... 5)
//            if numberOfRetries < d {
//                let delay = TimeInterval.random(in: 1.0 ... 2.0);
//                return delay
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.delegate?.manager(self, request: request, didFailWith: error)
//        }
//        
//        return nil
//    }
//    
//    typealias Request = TestAPIRequest
//    
//    typealias Response = TestAPIResponse
//    
//}
//
//
//// MARK: - APIManager
//
//extension APINetworking {
//    
//    public func dataTask(for request: APIRequest, progress: @escaping (Int64, Int64) -> Void, completion: @escaping (Any?, Error?) -> Void) throws -> URLSessionDataTask? {
//        
//        self.doProgress(from: 0) { (value) -> Bool in
//            if value < 100 {
//                progress(value, 100)
//                return true
//            }
//            progress(100, 100)
//            DispatchQueue.global().async(execute: {
//                completion([
//                    "code": 0,
//                    "message": "OK",
//                    "result": request.url
//                ], nil)
//            })
//            return false
//        }
//        
//        
//        return nil
//    }
//    
//    private func doProgress(from value: Int64, handler: @escaping (Int64) -> Bool) {
//        let increment = min(Int64.random(in: 10 ... 20), 100 - value)
//        DispatchQueue.global().asyncAfter(TimeInterval(increment) * 0.01, execute: {
//            let next = increment + value
//            if handler(next) {
//                self.doProgress(from: next, handler: handler)
//            }
//        })
//    }
//}
