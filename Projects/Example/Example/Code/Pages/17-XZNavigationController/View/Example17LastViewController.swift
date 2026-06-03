//
//  Example17LastViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/18.
//

import UIKit
import XZKit

class Example17LastViewController: Example17ViewController, XZNavigationBarCustomizable {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.title        = "导航页"
        navigationBar.barTintColor = .orange
    }
    
}

class ExampleTestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .magenta
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}
