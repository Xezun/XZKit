//
//  RAPITask.swift
//  XZKit
//
//  Created by Xezun on 2020/6/29.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

public class RAPITask<Request: RAPIRequest> {
    
    public let request: Request
    
    /// 已重试次数。
    public internal(set) var retries = 0
    
    public init(_ request: Request) {
        self.request = request
    }
}
