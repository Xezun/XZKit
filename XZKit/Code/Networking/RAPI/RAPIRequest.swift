//
//  RAPIRequest.swift
//  XZKit
//
//  Created by Xezun on 2020/6/29.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

public protocol RAPIRequest {
    
    var url: URL { get }
    
    var method: APIMethod { get }
    
    var headers: [String: CustomStringConvertible]? { get }
    
    var data: Any? { get }
    
    var attachments: [String: Any]? { get }
    
    var cachePolicy: NSURLRequest.CachePolicy { get }
    
    var timeout: TimeInterval { get }
    
    var deadline: TimeInterval? { get }
    
    var retryIfFailed: Bool { get }
    
    var concurrency: RAPIConcurrency { get }
    
}


extension RAPIRequest {
    
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
    
    public var timeout: TimeInterval {
        return 60.0
    }
    
    public var deadline: TimeInterval? {
        return nil
    }

    public var retryIfFailed: Bool {
        return false
    }
    
    public var concurrencyPolicy: APIConcurrency.Policy {
        return .default
    }
    
}
