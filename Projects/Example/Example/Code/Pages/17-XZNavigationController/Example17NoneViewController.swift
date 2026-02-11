//
//  Example17NoneViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/21.
//

import UIKit
import XZKit

class Example17NoneViewController: Example17ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
}

extension Example17NoneViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navigationController = navigationController as? XZNavigationController else { return nil }
        return ExampleNativeCustomAnimationController.init(for: navigationController, operation: operation, isInteractive: false)
    }
}

class ExampleNativeCustomAnimationController : XZNavigationAnimationController {
    
}
