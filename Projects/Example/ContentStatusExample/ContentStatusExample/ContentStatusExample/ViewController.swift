//
//  ViewController.swift
//  ContentStatusExample
//
//  Created by 徐臻 on 2019/3/29.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

extension UIView: ContentStatusRepresentable {
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        XZLog("%@", view.contentStatus);
    }


}

