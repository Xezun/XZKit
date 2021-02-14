//
//  XZKit+TimeInterval.swift
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    /// 当前时间戳，格林尼治时间。
    public static var since1970: TimeInterval {
        return __XZTimestamp();
    }
    
}
