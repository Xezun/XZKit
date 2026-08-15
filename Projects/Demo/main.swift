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
    @bind(.textColor)
    let button: UIButton = .init()
    
    @bind(.backgroundColor)
    let view: TestView = .init()
    
    @objc dynamic var name: String?
    
    @objc func foobar(_ name: String?) {
        
    }
    
    @bind(.reload, selector: #selector(UITableView.reloadData))
    let tableView: UITableView = .init()
 
}
