//
//  AppLanguage.swift
//  Example
//
//  Created by 徐臻 on 2019/3/13.
//  Copyright © 2019 mlibai. All rights reserved.
//

import Foundation
import XZKit

extension AppLanguage: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .English:
            return "English"
        case .Chinese:
            return "简体中文"
        default:
            return rawValue
        }
    }
}
