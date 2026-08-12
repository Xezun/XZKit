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
    
    @bind
    let nameLabel: UILabel = .init()
    
    @bind(.icon)
    let imageView: UIImageView = .init(image: nil)
}
