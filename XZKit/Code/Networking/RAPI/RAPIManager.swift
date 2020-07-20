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


open class RometeAPI<Response: RAPIResponse> {
    
    public typealias Request  = Response.Request
    public typealias Progress = (completed: Int64, total: Int64)
    
    @discardableResult
    open func send(_ request: Request) -> RAPITask<Request> {
        return RAPITask.init(request)
    }
    
    open func apiTask(_ apiTask: RAPITask<Request>, didProcess progress: Progress) {
        
    }
    
    open func apiTask(_ apiTask: RAPITask<Request>, didCollect data: Any?) throws -> Response {
        throw APIError.undefined
    }
    
    open func apiTask(_ apiTask: RAPITask<Request>, didReceive response: Response) {
        
    }
    
    @discardableResult
    open func apiTask(_ apiTask: RAPITask<Request>, didFailWith error: RAPIError) -> TimeInterval? {
        if apiTask.request.retryIfFailed {
            switch apiTask.retriedCount {
            case 0 ..< 100:
                return TimeInterval(apiTask.retriedCount)
            default:
                return nil
            }
        }
        return nil
    }
}
