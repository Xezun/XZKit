//
//  ViewController.swift
//  Example
//
//  Created by Xezun on 2019/3/13.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didRecevieRedirection(_ redirection: Any) -> UIViewController? {
        print("收到重定向消息：\(redirection)")
        self.textLabel.text  = String.init(describing: redirection)
        return nil
    }
}

