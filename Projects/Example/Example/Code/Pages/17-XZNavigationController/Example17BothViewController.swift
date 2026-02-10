//
//  Example17BothViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/12.
//

import UIKit
import XZKit

class NavigationConfiguration {
    var isHidden: Bool = false
    var isTranslucent: Bool = true
    var prefersLargeTitles: Bool = false
}

// 自定义功能的导航栈中，普通控制器与在普通的导航栈中没有任何区别的，但是对于声明遵循 XZNavigationBarCustomizable 定制化导航栏协议的控制器：。
// 1、导航栈自动根据定制化导航栏，配置原生导航栏状态。
// 2、定制化导航栏，将会覆盖在原生导航栏之上。
// 3、在转场完成之前，即 viewDidAppear 之前，直接对原生导航栏的操作（hidden/translucent/largeTitles），会被定制化导航栏配置的状态覆盖。
// 4、在转场之后，不论是直接操作原生导航栏，还是操作定制化导航栏，其作用和效果都是一样的。
//
// 声明遵循 XZNavigationGestureDrivable 将自动获得全屏手势导航的能力，当然默认只有返回，前进需要实现协议中的方法，且通过协议中的方法，
// 还可以控制手势返回的行为。
class Example17BothViewController: Example17ViewController, XZNavigationBarCustomizable, XZNavigationGestureDrivable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title         = "首页"
        navigationBar.barTintColor  = .brown
        navigationBar.isTranslucent = true
        
        navigationBar.backTitle = "返回"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navigationBar = navigationController?.navigationBar {
            hiddenSwitch.isOn = navigationBar.isHidden
            translucentSwitch.isOn = navigationBar.isTranslucent
            largeTitlesSwitch.isOn = navigationBar.prefersLargeTitles
        }
    }
    
    @objc func backButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "dismiss", sender: sender)
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    // 自定义手势前进的页面。
    func navigationController(_ navigationController: UINavigationController, viewControllerForGestureNavigation operation: UINavigationController.Operation) -> UIViewController? {
        if operation == .push {
            let sb = UIStoryboard.init(name: "Example17", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "next") as? Example17ViewController {
                vc.configuration = configuration;
                return vc
            }
        }
        return nil
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}


class Example17ViewController: UITableViewController {
    
    @IBOutlet weak var hiddenSwitch: UISwitch!
    @IBOutlet weak var translucentSwitch: UISwitch!
    @IBOutlet weak var largeTitlesSwitch: UISwitch!
    
    var configuration = NavigationConfiguration.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func hiddenSwitchValueChanged(_ sender: UISwitch) {
        if let navigationBar = (self as? XZNavigationBarCustomizable)?.xzNavigationBar {
            navigationBar.isHidden = sender.isOn
        } else if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.isHidden = sender.isOn
        }
    }
    
    @IBAction func translucentSwitchValueChanged(_ sender: UISwitch) {
        if let navigationBar = (self as? XZNavigationBarCustomizable)?.xzNavigationBar {
            navigationBar.isTranslucent = sender.isOn
        } else if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.isTranslucent = sender.isOn
        }
    }
    
    @IBAction func largeTitlesSwitchValueChanged(_ sender: UISwitch) {
        if let navigationBar = (self as? XZNavigationBarCustomizable)?.xzNavigationBar {
            navigationBar.prefersLargeTitles = sender.isOn
        } else if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = sender.isOn
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Example17ConfigurationViewController {
            destination.configuration = self.configuration;
        }
    }
    
}

class Example17ConfigurationViewController: Example17ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hiddenSwitch.isOn = configuration.isHidden
        self.translucentSwitch.isOn = configuration.isTranslucent
        self.largeTitlesSwitch.isOn = configuration.prefersLargeTitles
    }
    
    @IBAction override func hiddenSwitchValueChanged(_ sender: UISwitch) {
        configuration.isHidden = sender.isOn
    }
    
    @IBAction override func translucentSwitchValueChanged(_ sender: UISwitch) {
        configuration.isTranslucent = sender.isOn
    }
    
    @IBAction override func largeTitlesSwitchValueChanged(_ sender: UISwitch) {
        configuration.prefersLargeTitles = sender.isOn
    }
    
}
