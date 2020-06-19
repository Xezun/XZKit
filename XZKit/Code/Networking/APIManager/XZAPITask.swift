//
//  XZAPITask.swift
//  XZKit
//
//  Created by Xezun on 2020/6/17.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

/// 记录了在执行 APIRequest 时的任务信息，提供了取消请求的入口。
public protocol APITask: class {
    
    /// 任务的唯一标识符。
    var identifier: UUID  { get }
    
    /// 已重试的次数。
    var numberOfRetries: Int { get }
    
    /// 执行任务的 URLSessionDataTask 对象。
    var dataTask: URLSessionDataTask? { get }
    
    /// 是否已取消。
    var isCancelled: Bool { get }
    
    /// 取消当前任务。
    func cancel() -> Void
    
    /// 任务截止时间。
    var deadline: DispatchTime? { get }
    
}
