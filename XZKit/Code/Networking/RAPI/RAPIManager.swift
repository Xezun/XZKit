//
//  RAPIManager.swift
//  XZKit
//
//  Created by Xezun on 2020/6/28.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

public protocol RAPIManager: RAPINetworking {
    
    associatedtype Response: RAPIResponse
    
    typealias Request = Response.Request
    
    /// 分数表示的进度，completed / total 得到百分比。
    typealias Progress = (completed: Int64, total: Int64)
    
    @discardableResult
    func send(_ request: Request) -> RAPITask<Request>
    
    func request(_ request: Request, didProcess progress: RAPIManager.Progress)
    
    func request(_ request: Request, didCollect data: Any?) throws -> Response
    
    func request(_ request: Request, didReceive response: Response)
    
    @discardableResult
    func request(_ request: Request, didFailWith error: APIError) -> TimeInterval?
    
}

public protocol RAPINetworking: AnyObject {
    
    func dataTask(for request: RAPIRequest, progress: @escaping (_ bytes: Int64, _ totalBytes: Int64) -> Void, completion: @escaping (_ data: Any?, _ error: Error?) -> Void) throws -> URLSessionDataTask?
    
}

