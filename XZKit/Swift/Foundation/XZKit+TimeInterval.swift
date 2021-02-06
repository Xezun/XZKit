//
//  XZKit+TimeInterval.swift
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    /// 格林尼治起始时间到现在的时间间隔。
    public static var since1970: TimeInterval {
        return __XZTimestamp();
    }
    
}
