//
//  main.swift
//  Client
//
//  Created by Xezun on 2026/4/13.
//

import Foundation
import UIKit
import XZKit

@mocoa
class TestView: UIView, XZMocoaView {
    
    @bind(.name)
    @bind(.textColor)
    let nameLabel: UILabel = .init()
    
    @bind("icon")
    let imageView: UIImageView = .init(image: nil)
    
    @bind(title: "name", for: .normal)
    let button: UIButton = .init()
    
    @bind("name")
    let view: TestView = .init()
    
    @objc dynamic var name: String?
    
    @objc func foobar(_ name: String?) {
        
    }
 
}
