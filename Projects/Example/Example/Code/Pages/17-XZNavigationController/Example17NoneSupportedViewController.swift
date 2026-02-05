//
//  Example17NoneSupportedViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/21.
//

import UIKit
import XZKit

class Example17NoneSupportedViewController: UITableViewController {
    
    @IBOutlet weak var hiddenSwitch: UISwitch!
    @IBOutlet weak var translucentSwitch: UISwitch!
    @IBOutlet weak var prefersLargeTitlesSwitch: UISwitch!
    @IBOutlet weak var customavigationTranstionSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navigationController = navigationController {
            hiddenSwitch.isOn = navigationController.isNavigationBarHidden
            translucentSwitch.isOn = navigationController.navigationBar.isTranslucent
            prefersLargeTitlesSwitch.isOn = navigationController.navigationBar.prefersLargeTitles
        }
        customavigationTranstionSwitch.isOn = navigationController?.delegate?.isEqual(self) == true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.delegate = nil;
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func navigationBarHiddenChanged(_ sender: UISwitch) {
        navigationController?.setNavigationBarHidden(sender.isOn, animated: true)
    }

    @IBAction func navigationBarTranslucentChanged(_ sender: UISwitch) {
        navigationController?.navigationBar.isTranslucent = sender.isOn
    }

    @IBAction func navigationBarPrefersLargeTitlesChanged(_ sender: UISwitch) {
        navigationController?.navigationBar.prefersLargeTitles = sender.isOn
    }

    @IBAction func customNavigationTranstionChanged(_ sender: UISwitch) {
        navigationController?.delegate = sender.isOn ? self : nil
    }
}

extension Example17NoneSupportedViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navigationController = navigationController as? XZNavigationController else { return nil }
        return ExampleNativeCustomAnimationController.init(for: navigationController, operation: operation, isInteractive: false)
    }
}

class ExampleNativeCustomAnimationController : XZNavigationAnimationController {
    
}
