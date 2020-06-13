//
//  ExampleAPIManager.swift
//  XZKit_Example
//
//  Created by mlibai on 2017/11/28.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import Foundation
import XZKit
import AFNetworking

// MARK: - 公共部分

extension APINetworking {
    
    public func dataTask(for request: APIRequest, progress: @escaping (Int64, Int64) -> Void, completion: @escaping (Any?, Error?) -> Void) throws -> URLSessionDataTask? {
        let manager = AFHTTPSessionManager.init()
        
        _ = request.headers?.map({ (item) in
            manager.requestSerializer.setValue(String.init(describing: item.value), forHTTPHeaderField: item.key)
        })
        
        manager.requestSerializer.cachePolicy = request.cachePolicy
        manager.requestSerializer.timeoutInterval = request.timeoutInterval
        
        let urlString = request.url.absoluteString
        let data = request.data
        
        let timeInterval = TimeInterval(arc4random_uniform(10))
        
        let progressHandler = { (_ p: Progress) in
            progress(p.completedUnitCount, p.totalUnitCount)
        }
        
        let successHandler = { (_ task: URLSessionDataTask, _ responseObject: Any?) in
            completion(responseObject, nil)
        }
        
        let failureHandler = { (_ task: URLSessionDataTask?, _ error: Error) in
            completion(nil, error)
        }
        
        manager.completionQueue = DispatchQueue.global(qos: .background)
        
        switch request.method {
        case .GET:
            #if DEBUG
            var url = request.url;
            if let dict = request.data as? [String: Any] {
                url.queryComponent?.addValuesForKeys(from: dict)
            }
            let headers = manager.requestSerializer.httpRequestHeaders.map({ (itemClick) -> String in
                return "\(itemClick.key): \(itemClick.value)"
            }).joined(separator: "\n   ")
            XZLog("Method:  GET(\(timeInterval))\nURL:     %@\nHeaders: %@", url.absoluteString, headers)
            #endif
            return manager.get(urlString, parameters: data, progress: progressHandler, success: successHandler, failure: failureHandler)
            
            
        case .POST:
            #if DEBUG
            let headers = manager.requestSerializer.httpRequestHeaders.map({ (itemClick) -> String in
                return "\(itemClick.key): \(itemClick.value)"
            }).joined(separator: "\n   ")
            let dataString = (request.data as? [String: Any])?.map({ (itemClick) -> String in
                if let json = String.init(json: itemClick.value) {
                    return "\(itemClick.key): \(json.replacingOccurrences(of: "\\n", with: ""))"
                }
                return "\(itemClick.key): <非 JSON 数据类型>"
            }).joined(separator: "\n   ")
            let fileString = request.attachments?.map({ (item) -> String in
                return "\(item.key): \(item.value)"
            }).joined(separator: "\n   ")
            XZLog("Method:  POST(\(timeInterval))\nURL:     %@\nHeaders: %@\nData:    %@\nFile:    %@", urlString, headers, dataString, fileString)
            #endif
            if let attachments = request.attachments {
                return manager.post(urlString, parameters: data, constructingBodyWith: { (formData) in
                    for attachment in attachments {
                        if let image = attachment.value as? UIImage, let data = image.pngData() {
                            formData.appendPart(withFileData: data, name: attachment.key, fileName: "image", mimeType: "image/png")
                        } else if let data = attachment.value as? Data {
                            formData.appendPart(withForm: data, name: attachment.key)
                        } else if let url = attachment.value as? URL {
                            try? formData.appendPart(withFileURL: url, name: attachment.key)
                        }
                    }
                }, progress: progressHandler, success: successHandler, failure: failureHandler)
            }
            return manager.post(urlString, parameters: data, progress: progressHandler, success: successHandler, failure: failureHandler)
            
            
        default:
            throw APIError.invalidRequest
        }
    }
    
}

extension APIManager {
    
    public func request(_ request: Request, didProcess progress: Progress) {
        XZLog("链接: %@\n进度: %.2f", request.url, Double.init(fractional: progress))
    }
    
    public func request(_ request: Request, didCollect responseObject: Any?) throws -> Response {
        
        guard let dict = responseObject as? [String: Any]   else { throw APIError.unexpectedResponse }
        guard let code = dict["code"] as? Int               else { throw APIError.unexpectedResponse }
        guard let message = dict["message"] as? String      else { throw APIError.unexpectedResponse }
        
        guard code == noErr else {
            throw APIError.init(code: code, message: message)
        }
        
        return try Response.init(request: request, data: dict["results"])
    }
    
}

// MARK: - 具体接口

// 1. 定义接口请求参数。
struct ExampleAPIRequest: APIRequest {

    let url: URL = URL.init(string: "https://api.seniverse.com/v3/weather/now.json")!
    
    var data: Any? {
        return [
            "key": "z3plmlbgvez2ab2w",
            "language": "zh-Hans",
            "unit": "c",
            "location": city
        ]
    }

    var retryIfFailed: Bool {
        return false;
    }

    /// 同时只能发送一个请求，新的请求被忽略。
    var concurrencyPolicy: APIConcurrency.Policy = .ignoreCurrent;

    let city: String;

    init(city: String = "beijing") {
        self.city = city;
    }
    
    var deadlineInterval: TimeInterval? {
        return 5;
    }

}

// 2. 定义解析接口数据的方式。
struct ExampleAPIResponse: APIResponse {
    
    typealias Request = ExampleAPIRequest

    let date: String
    let weather: (id: String, text: String, temperature: String)
    let location: (id: String, name: String)

    init(request: ExampleAPIRequest, data: Any?) throws {
        guard let result = (data as? [[String : Any]])?.first else { throw APIError.unexpectedResponse }

        guard let date = result["last_update"] as? String else { throw APIError.unexpectedResponse }
        
        guard let weatherDict = result["now"] as? [String: Any] else { throw APIError.unexpectedResponse }
        guard let weatherID = weatherDict["code"] as? String else { throw APIError.unexpectedResponse }
        guard let weatherText = weatherDict["text"] as? String else { throw APIError.unexpectedResponse }
        guard let weatherTemperature = weatherDict["temperature"] as? String else { throw APIError.unexpectedResponse }
        
        guard let locationDict = result["location"] as? [String: Any] else { throw APIError.unexpectedResponse }
        guard let locationID = locationDict["id"] as? String else { throw APIError.unexpectedResponse }
        guard let locationName = locationDict["name"] as? String else { throw APIError.unexpectedResponse }
        
        self.date = date
        self.weather = (weatherID, weatherText, weatherTemperature)
        self.location = (locationID, locationName)
    }

}

/// 3. 自定义代理事件。
protocol ExampleAPIManagerDelegate: NSObjectProtocol  {

    func apiManager(_ apiManager: ExampleAPIManager, request: ExampleAPIRequest, didFailWith error: Error);
    func apiManager(_ apiManager: ExampleAPIManager, request: ExampleAPIRequest, didFinishWith apiResponse: ExampleAPIResponse);

}


// 4. 定义 APIManager
class ExampleAPIManager: APIManager {
    
    typealias Request   = ExampleAPIRequest
    typealias Response  = ExampleAPIResponse

    weak var delegate: ExampleAPIManagerDelegate?

    // 4.2 自定义接口逻辑。

    func weather(of city: String, policy: APIConcurrency.Policy) {
        var request = ExampleAPIRequest.init(city: city)
        request.concurrencyPolicy = policy;
        _ = send(request);
    }

    // 4.3 自定义基本数据验证（如果当前接口的数据格式与默认格式不同时）。
    
    func request(_ request: ExampleAPIRequest, didReceive response: ExampleAPIResponse) {
        DispatchQueue.main.async(execute: {
            self.delegate?.apiManager(self, request: request, didFinishWith: response)
        })
    }
    
//    func request(_ request: Request, didCollect responseObject: Any?) throws -> ExampleAPIResponse {
//        guard let data = responseObject as? [String: Any] else { throw APIError.unexpectedResponse }
//        return try ExampleAPIResponse.init(request: request, data: data["results"])
//    }

    // 4.4 自定义事件转发，未定义的事件将走默认代理方法。
    
    func request(_ request: ExampleAPIRequest, didFailWith error: APIError) -> TimeInterval? {
        DispatchQueue.main.async(execute: {
            self.delegate?.apiManager(self, request: request, didFailWith: error)
        })
        
        return 5.0
    }
    
    deinit {
        XZLog("%@ 已成功销毁！", self)
    }
    
}














