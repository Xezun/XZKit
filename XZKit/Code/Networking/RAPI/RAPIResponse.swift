//
//  RAPIResponse.swift
//  XZKit
//
//  Created by Xezun on 2020/6/29.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

/// 网络接口数据模型的基本规范。
public protocol RAPIResponse {
    
    /// 接口请求的类型。
    associatedtype Request: RAPIRequest
    
    /// 接口数据模型的必须构造方法。
    ///
    /// - Parameters:
    ///   - request: 接口请求。
    ///   - data: 接口请求的原始数据。
    /// - Throws: 构造接口数据模型过程中的异常。
    init(_ request: Request, data: Any?) throws
    
}
