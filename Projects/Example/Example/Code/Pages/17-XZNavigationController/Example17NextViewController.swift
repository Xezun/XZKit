//
//  Example17NextViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/16.
//

import UIKit
import XZKit

class Example17NextViewController: Example17ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.title        = "导航栏和导航手势定制页"
        navigationBar.barTintColor = .systemOrange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
}

extension Example17NextViewController: XZNavigationBarCustomizable {
 

}

extension Example17NextViewController: XZNavigationGestureDrivable {
    
    func navigationController(_ navigationController: UINavigationController, viewControllerForGestureNavigation operation: UINavigationController.Operation) -> UIViewController? {
        if operation == .push {
            let sb = UIStoryboard.init(name: "Example17", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "last")
            if let nextVC = vc as? Example17ViewController {
                nextVC.navigationAppearance = self.navigationAppearance
            }
            return vc
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, edgeInsetsForGestureNavigation operation: UINavigationController.Operation) -> NSDirectionalEdgeInsets? {
        return .init(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
    
}
