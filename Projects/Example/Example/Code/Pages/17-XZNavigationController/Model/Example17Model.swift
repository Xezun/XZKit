//
//  Example17Model.swift
//  Example
//
//  Created by Xezun on 2026/3/21.
//

import UIKit
import XZKit

@mocoa
class Example17Model: NSObject, XZMocoaModel {
    
    dynamic var current : Example17Configuration
    dynamic var next    : Example17Configuration
    
    init(current: Example17Configuration = .init()) {
        self.current = current
        self.next = Example17Configuration.init()
        super.init()
    }
    
}

@objc class Example17Configuration: NSObject {
    @objc dynamic var isHidden = false
    @objc dynamic var isTranslucent = true
    @objc dynamic var prefersLargeTitles = false
}
