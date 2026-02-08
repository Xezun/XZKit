//
//  Example17HomeViewController.swift
//  Example
//
//  Created by 徐臻 on 2026/2/6.
//

import UIKit
import XZKit

class Example17HomeViewController: UITableViewController {
    
    @IBOutlet weak var navigationCustomizationSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationController = self.tabBarController?.viewControllers?.first as? XZNavigationController {
            navigationCustomizationSwitch.isOn = navigationController.isNavigationCustomizable
        } else {
            navigationCustomizationSwitch.isOn = false;
            navigationCustomizationSwitch.isEnabled = false;
        }
    }

    @IBAction func navigationCustomizationSwitchValueChanged(_ sender: UISwitch) {
        if let navigationController = self.tabBarController?.viewControllers?.first as? XZNavigationController {
            navigationController.isNavigationCustomizable = sender.isOn
        }
    }

}
