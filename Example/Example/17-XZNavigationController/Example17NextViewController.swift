//
//  Example17NextViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/16.
//

import UIKit
import XZNavigationController

class Example17NextViewController: UITableViewController {
    
    @IBOutlet weak var hiddenSwitch: UISwitch!
    @IBOutlet weak var translucentSwitch: UISwitch!
    @IBOutlet weak var prefersLargeTitlesSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.title        = "中间页"
        navigationBar.barTintColor = .systemOrange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navigationController = navigationController {
            hiddenSwitch.isOn = navigationController.isNavigationBarHidden
            translucentSwitch.isOn = navigationController.navigationBar.isTranslucent
            prefersLargeTitlesSwitch.isOn = navigationController.navigationBar.prefersLargeTitles
        }
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

    @IBOutlet weak var nextHiddenSwitch: UISwitch!
    @IBOutlet weak var nextTranslucentSwitch: UISwitch!
    @IBOutlet weak var nextPrefersLargeTitlesSwitch: UISwitch!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "next" else {
            return
        }
        if let navigationBar = (segue.destination as? XZNavigationBarCustomizable)?.navigationBarIfLoaded {
            navigationBar.isHidden           = nextHiddenSwitch.isOn
            navigationBar.isTranslucent      = nextTranslucentSwitch.isOn
            navigationBar.prefersLargeTitles = nextPrefersLargeTitlesSwitch.isOn
        }
    }
    
}

extension Example17NextViewController: XZNavigationBarCustomizable {
 

}

extension Example17NextViewController: XZNavigationGestureDrivable {
    
    func navigationController(_ navigationController: UINavigationController, viewControllerForGestureNavigation operation: UINavigationController.Operation) -> UIViewController? {
        if operation == .push {
            let sb = UIStoryboard.init(name: "Example17", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "last")
            if let navigationBar = (vc as? XZNavigationBarCustomizable)?.navigationBarIfLoaded {
                navigationBar.isHidden = nextHiddenSwitch.isOn
                navigationBar.isTranslucent = nextTranslucentSwitch.isOn
                navigationBar.prefersLargeTitles = nextPrefersLargeTitlesSwitch.isOn
            }
            return vc
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, edgeInsetsForGestureNavigation operation: UINavigationController.Operation) -> NSDirectionalEdgeInsets? {
        return .init(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
    
}
