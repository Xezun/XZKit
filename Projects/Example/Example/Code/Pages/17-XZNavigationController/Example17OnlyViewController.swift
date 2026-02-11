//
//  Example17OnlyViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/19.
//

import UIKit
import XZKit

class Example17OnlyViewController: Example17ViewController, XZNavigationGestureDrivable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func navigationController(_ navigationController: UINavigationController, viewControllerForGestureNavigation operation: UINavigationController.Operation) -> UIViewController? {
        if operation == .push {
            let sb = UIStoryboard.init(name: "Example17", bundle: nil)
            return sb.instantiateViewController(withIdentifier: "next")
        }
        return nil
    }

    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
}
