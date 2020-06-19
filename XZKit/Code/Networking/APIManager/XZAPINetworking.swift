//
//  XZAPINetworking.swift
//  XZKit
//
//  Created by Xezun on 2020/6/20.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

/// 网络协议。
public protocol APINetworking: AnyObject {
    
    /// 根据接口请求对象，创建并执行网络请求。
    /// - Note: 返回值为已经启动的 URLSessionDataTask 对象。
    /// - Note: 默认情况下，APIManager 不在主线程执行此方法。
    /// - Note: 回调需要在异步执行。
    /// - Parameters:
    ///   - request: 接口请求。
    ///   - progress: 请求进度回调。
    ///   - bytes: 已传送的数据量（字节）。
    ///   - totalBytes: 总共需传送的数据量（字节）。
    ///   - completion: 请求完成回调。
    ///   - data: 请求成功所获得的应答数据。
    ///   - error: 请求失败所产生的错误信息。
    /// - Returns: 执行网络请求的 Task 。
    /// - Throws: 创建网络请求时可能发生的错误。
    func dataTask(for request: APIRequest, progress: @escaping (_ bytes: Int64, _ totalBytes: Int64) -> Void, completion: @escaping (_ data: Any?, _ error: Error?) -> Void) throws -> URLSessionDataTask?
    
}
