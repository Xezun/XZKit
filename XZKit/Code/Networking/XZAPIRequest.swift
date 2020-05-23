//
//  APIRequest.swift
//  XZKit
//
//  Created by Xezun on 2017/7/31.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit

/// API 定义了接口特征，如请求参数、缓存策略等。
public protocol APIRequest {
    
    /// 接口地址。
    var url: URL { get }
    
    /// 接口请求方式，默认 GET 。
    var method: APIMethod { get }
    
    /// 请求头，默认 nil 。
    /// - Note: 请求头必须以 Key-Value 的形式提供。
    var headers: [String: CustomStringConvertible]? { get }
    
    /// 请求数据，默认 nil 。
    /// - Note: 对于 POST 请求，data 将作为 HTTPBody 传递。
    /// - Note: 对于 GET 请求，data 将作为 Query 传递。
    var data: Any? { get }
    
    /// 接口需要上传的文件，默认 nil 。
    /// - Note: 建议将键名作为附件字段名。
    /// - Note: 建议键值为 Data、UIImage、URL、(name, mimeType, data) 等描述附件的对象，全局统一。
    var attachments: [String: Any]? { get }
    
    /// 缓存策略，默认 .useProtocolCachePolicy 。
    var cachePolicy: NSURLRequest.CachePolicy { get }
    
    /// 超时时间，默认 60 秒。
    var timeoutInterval: TimeInterval { get }
    
    /// 网络请求从开始到终止的时间间隔。如果请求开始后，在指定时间内没有完成，则请求终止并抛出 APIError.overtime 异常。
    /// - Note: 如果已设置自动重试，超时的任务会进入自动重试状态，每次重试的请求，重新计算截止时间。
    var deadlineInterval: TimeInterval? { get }
    
    /// 网络请求失败时是否重试，默认 false 。自动重拾的任务，除一下子情况外，在任务失败时，将不断重试直至成功，且期间不会触发错误回调。
    /// - Note: 任务被取消或者因并发策略忽略而被忽略，自动重试将终止，并触发错误回调。
    /// - Note: 网络请求成功，但数据解析失败，也会触发自动重试（与 4.0 版本以前规则不同）。
    /// - Note: 自动重试任务除了受重试时间影响外，并发策略也会影响任务实际执行的时间。
    var retryIfFailed: Bool { get }
    
    /// 并发策略，默认 .default 。
    var concurrencyPolicy: APIConcurrency.Policy { get }
    
}


extension APIRequest {
    
    public var method: APIMethod {
        return .GET
    }
    
    public var headers: [String: CustomStringConvertible]? {
        return nil
    }
    
    public var data: Any? {
        return nil
    }
    
    public var attachments: [String: Any]? {
        return nil
    }
    
    public var cachePolicy: NSURLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    
    public var timeoutInterval: TimeInterval {
        return 60.0
    }
    
    public var deadlineInterval: TimeInterval? {
        return nil
    }

    public var retryIfFailed: Bool {
        return false
    }
    
    public var concurrencyPolicy: APIConcurrency.Policy {
        return .default
    }
    
}


