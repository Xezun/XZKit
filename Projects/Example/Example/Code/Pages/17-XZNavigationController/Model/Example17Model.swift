//
//  Example17Model.swift
//  Example
//
//  Created by 徐臻 on 2026/3/21.
//

import UIKit
import XZKit

@mocoa
class Example17Model: NSObject, XZMocoaModel {
    
    var current: Example17Configuration
    dynamic var next  = Example17Configuration.init()
    
    init(current: Example17Configuration = .init()) {
        self.current = current
        super.init()
    }
    
}

@mocoa(.m)
class Example17Configuration: NSObject {
    dynamic var isHidden = false
    dynamic var isTranslucent = true
    dynamic var prefersLargeTitles = false
}
