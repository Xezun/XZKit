//
//  Example17HomeViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/12.
//

import UIKit
import XZNavigationController

// 自定义功能的导航栈中，普通控制器与在普通的导航栈中没有任何区别的，但是对于声明遵循 XZNavigationBarCustomizable 自定义导航条协议的控制器：。
// 1、导航栈自动根据自定义导航条，配置原生导航条状态。
// 2、自定义导航条，将会覆盖在原生导航条之上。
// 3、在转场完成之前，即 viewDidAppear 之前，直接对原生导航条的操作（hidden/translucent/largeTitles），会被自定义导航条配置的状态覆盖。
// 4、在转场之后，不论是直接操作原生导航条，还是操作自定义导航条，其作用和效果都是一样的。
//
// 声明遵循 XZNavigationGestureDrivable 将自动获得全屏手势导航的能力，当然默认只有返回，前进需要实现协议中的方法，且通过协议中的方法，
// 还可以控制手势返回的行为。
class Example17HomeViewController: UITableViewController, XZNavigationBarCustomizable, XZNavigationGestureDrivable {
    
    @IBOutlet weak var hiddenSwitch: UISwitch!
    @IBOutlet weak var translucentSwitch: UISwitch!
    @IBOutlet weak var prefersLargeTitlesSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title         = "首页"
        navigationBar.barTintColor  = .brown
        navigationBar.isTranslucent = true
        
        navigationBar.backTitle = "返回"
        navigationBar.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navigationController = navigationController {
            hiddenSwitch.isOn = navigationController.isNavigationBarHidden
            translucentSwitch.isOn = navigationController.navigationBar.isTranslucent
            prefersLargeTitlesSwitch.isOn = navigationController.navigationBar.prefersLargeTitles
        }
    }
    
    @objc func backButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "dismiss", sender: sender)
    }
    
    @IBAction func isCustomizableValueChanged(_ sender: UISwitch) {
        guard let navigationController = self.navigationController as? XZNavigationController else { return }
        
        navigationController.isCustomizable = sender.isOn
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    // 自定义手势前进的页面。
    func navigationController(_ navigationController: UINavigationController, viewControllerForGestureNavigation operation: UINavigationController.Operation) -> UIViewController? {
        if operation == .push {
            let sb = UIStoryboard.init(name: "Example17ViewController", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "next")
            if let navigationBar = (vc as? XZNavigationBarCustomizable)?.navigationBarIfLoaded {
                navigationBar.isHidden = nextHiddenSwitch.isOn
                navigationBar.isTranslucent = nextTranslucentSwitch.isOn
                navigationBar.prefersLargeTitles = nextPrefersLargeTitlesSwitch.isOn
            }
            return vc
        }
        return nil
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
