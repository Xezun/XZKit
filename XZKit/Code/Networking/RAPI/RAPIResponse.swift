//
//  RAPIResponse.swift
//  XZKit
//
//  Created by Xezun on 2020/6/29.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

public protocol RAPIResponse {
    
    associatedtype Request: RAPIRequest
    
    init(_ request: Request, data: Any?) throws
    
}
