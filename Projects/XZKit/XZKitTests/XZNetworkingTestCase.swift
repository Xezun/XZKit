//
//  XZNetworkingTestCase.swift
//  XZKitTests
//
//  Created by 徐臻 on 2020/6/14.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import XCTest
import XZKit

class XZNetworkingTestCase: XCTestCase, TestAPIManagerDelegate {
    
    var logs = [Int: [String]]()
    
    func manager(_ manager: TestAPIManager, request: Int, didReceive message: String) {
        if var array = logs[request] {
            array.append(message)
            logs[request] = array
        } else {
            logs[request] = [message]
        }
    }
    
    lazy var manager = TestAPIManager.init()
    var count = 0
    
    override func setUp() {
        manager.delegate = self
    }
    
    lazy var exp = XCTestExpectation.init(description: "")
    
    func testSend() {
        
        exp = self.expectation(description: "")
        
        count = 0
        for id in 0 ..< 100 {
            DispatchQueue.global().async {
                switch Int.random(in: 0...3) {
                case 0:
                    self.manager.send(.a(id: id))
                case 1:
                    self.manager.send(.b(id: id))
                case 2:
                    self.manager.send(.c(id: id))
                case 3:
                    self.manager.send(.d(id: id))
                default:
                    break
                }
            }
        }
        
        self.waitForExpectations(timeout: 30) { (error) in
            XZLog("%@", String.init(json: self.logs, options: [.prettyPrinted, .sortedKeys]))
        }
        
    }
    
    
    
}


enum TestAPIRequest: CustomStringConvertible, APIRequest {
    
    case a(id: Int)
    case b(id: Int)
    case c(id: Int)
    case d(id: Int)
    
    var url: URL {
        return URL(string: "https://api.xezun.com/app/\(self)")!
    }
    
    var description: String {
        switch self {
        case .a(let id):
            return "a\(id)"
        case .b(let id):
            return "b\(id)"
        case .c(let id):
            return "c\(id)"
        case .d(let id):
            return "d\(id)"
        }
    }
    
    var concurrencyPolicy: APIConcurrency.Policy {
        switch self {
        case .a:
            return .default
        case .b:
            return .cancelOthers
        case .c:
            return .ignoreCurrent
        case .d(let v):
            return .wait(priority: APIConcurrency.Priority(rawValue: v))
        }
    }
    
    var retryIfFailed: Bool {
        return true
    }
    
}

struct TestAPIResponse: APIResponse {
    
    let result: String
    
    init(_ request: TestAPIRequest, data: Any?) throws {
        guard let result = data as? String else { throw APIError.unexpectedResponse }
        self.result = String(formats: "%@, %@", request, result)
    }
    
    typealias Request = TestAPIRequest
    
}

protocol TestAPIManagerDelegate: class {
    
    func manager(_ manager: TestAPIManager, request: Int, didReceive message: String)
}

class TestAPIManager: APIManager {
    
    weak var delegate: TestAPIManagerDelegate?
    
    func request(_ request: TestAPIRequest, didProcess progress: (value: Int64, scale: Int64)) {
        XZLog("%@: %.2f", request, Double(fraction: progress))
    }
    
    
    func request(_ request: TestAPIRequest, didCollect data: Any?) throws -> TestAPIResponse {
        guard let dict = data as? [String: Any] else { throw APIError.unexpectedResponse }
        guard let code = dict["code"] as? Int else { throw APIError.unexpectedResponse }
        guard code == noErr else {
            let message = dict["message"] as? String
            throw APIError.init(code: code, message: message ?? "Unknown")
        }
        return try TestAPIResponse(request, data: dict["result"])
    }
    
    func request(_ request: TestAPIRequest, didReceive response: TestAPIResponse) {
        DispatchQueue.main.async {
            let message = String(formats: "%.3f：成功！", TimeInterval.since1970)
            switch request {
            case .a(let id): self.delegate?.manager(self, request: id, didReceive: message)
            case .b(let id): self.delegate?.manager(self, request: id, didReceive: message)
            case .c(let id): self.delegate?.manager(self, request: id, didReceive: message)
            case .d(let id): self.delegate?.manager(self, request: id, didReceive: message)
            }
        }
    }
    
    func request(_ request: TestAPIRequest, didFailWith error: APIError) -> TimeInterval? {
        if request.retryIfFailed {
            let d = Int.random(in: 1 ... 5)
            if error.numberOfRetries < d {
                
                let delay = TimeInterval.random(in: 1.0 ... 2.0);
                DispatchQueue.main.async {
                    let message = String(formats: "%.3f：%.3f秒后重试！", TimeInterval.since1970, delay)
                    switch request {
                    case .a(let id): self.delegate?.manager(self, request: id, didReceive: message)
                    case .b(let id): self.delegate?.manager(self, request: id, didReceive: message)
                    case .c(let id): self.delegate?.manager(self, request: id, didReceive: message)
                    case .d(let id): self.delegate?.manager(self, request: id, didReceive: message)
                    }
                }
                
                return delay
            }
        }
        
        DispatchQueue.main.async {
            let message = String(formats: "%.3f：失败，共重试%ld次！", TimeInterval.since1970, error.numberOfRetries)
            switch request {
            case .a(let id): self.delegate?.manager(self, request: id, didReceive: message)
            case .b(let id): self.delegate?.manager(self, request: id, didReceive: message)
            case .c(let id): self.delegate?.manager(self, request: id, didReceive: message)
            case .d(let id): self.delegate?.manager(self, request: id, didReceive: message)
            }
        }
        
        return nil
    }
    
    typealias Request = TestAPIRequest
    
    typealias Response = TestAPIResponse
    
    func dataTask(for request: APIRequest, progress: @escaping (Int64, Int64) -> Void, completion: @escaping (Any?, Error?) -> Void) throws -> URLSessionDataTask? {
        Networking.queue.asyncAfter(TimeInterval.random(in: 1.0 ... 2.0)) {
            completion([
                "code": 0,
                "message": "OK",
                "result": ""
            ], nil)
        }
        return nil
    }
    
    
}
