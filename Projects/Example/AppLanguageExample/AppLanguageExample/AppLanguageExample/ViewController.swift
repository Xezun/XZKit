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
        
        print("当前语言：\(AppLanguage.preferred)")
    }

}

