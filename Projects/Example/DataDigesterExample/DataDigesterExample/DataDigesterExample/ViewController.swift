//
//  ViewController.swift
//  DataDigesterExample
//
//  Created by Xezun on 2019/3/30.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(DataDigester.digest("123".data(using: .utf8)!, algorithm: .MD5, hexadecimalEncoding: .uppercase))
    }


}

