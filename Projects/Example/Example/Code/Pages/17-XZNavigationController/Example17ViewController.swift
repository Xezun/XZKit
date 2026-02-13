//
//  Example17ViewController.swift
//  Example
//
//  Created by 徐臻 on 2026/2/12.
//

import UIKit
import XZKit

enum Example17Page: String, CaseIterable {
    
    case DING_ZHI
    case DAO_HANG
    case SHOU_SHI
    case YUAN_SEN
    
    var name: String {
        switch self {
        case .DING_ZHI:
            return "定制页"
        case .DAO_HANG:
            return "导航页"
        case .SHOU_SHI:
            return "手势页"
        case .YUAN_SEN:
            return "原生页"
        }
    }
    
    var viewController: Example17ViewController {
        let storyboard = UIStoryboard(name: "Example17", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: self.rawValue) as! Example17ViewController
    }
    
}

/// 基类。
class Example17ViewController: UITableViewController {
    
    @IBOutlet weak var hiddenSwitch: UISwitch!
    @IBOutlet weak var translucentSwitch: UISwitch!
    @IBOutlet weak var largeTitlesSwitch: UISwitch!
    
    @IBOutlet weak var nextHiddenSwitch: UISwitch!
    @IBOutlet weak var nextTranslucentSwitch: UISwitch!
    @IBOutlet weak var nextLargeTitlesSwitch: UISwitch!
    
    /// 当前页面的导航栏外观样式。在 viewWillAppear 之后，表示预设的下一页导航栏样式。
    var currentAppearance = NavigationAppearance.init()
    var nextAppearance = NavigationAppearance.init()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ( self is XZNavigationBarCustomizable ? .lightContent : .darkContent )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置当前页的导航栏样式
        if let navigationBar = (self as? XZNavigationBarCustomizable)?.navigationBar {
            navigationBar.isHidden = currentAppearance.isHidden
            navigationBar.isTranslucent = currentAppearance.isTranslucent
            navigationBar.prefersLargeTitles = currentAppearance.prefersLargeTitles
        }
        
        // 同步数据
        self.nextHiddenSwitch.isOn = nextHiddenSwitch.isOn
        self.nextTranslucentSwitch.isOn = nextTranslucentSwitch.isOn
        self.nextLargeTitlesSwitch.isOn = nextLargeTitlesSwitch.isOn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 未定制导航栏的控制器设置导航栏样式
        if self is XZNavigationBarCustomizable {
            return
        }
        if let navigationController = self.navigationController {
            let uiNavigationBar = navigationController.navigationBar;
            uiNavigationBar.isTranslucent = currentAppearance.isTranslucent
            uiNavigationBar.prefersLargeTitles = currentAppearance.prefersLargeTitles
            navigationController.setNavigationBarHidden(currentAppearance.isHidden, animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        #XZLog("UINavigationBar => safeAreaInsets: \(navigationBar.safeAreaInsets) bounds: \(navigationBar.bounds) frame: \(navigationBar.frame)")
    }
    
    @IBAction func currentHiddenSwitchValueChanged(_ sender: UISwitch) {
        currentAppearance.isHidden = sender.isOn
        self.navigationController?.setNavigationBarHidden(sender.isOn, animated: true)
    }
    
    @IBAction func currentTranslucentSwitchValueChanged(_ sender: UISwitch) {
        currentAppearance.isTranslucent = sender.isOn
        self.navigationController?.navigationBar.isTranslucent = sender.isOn
    }
    
    @IBAction func currentLargeTitlesSwitchValueChanged(_ sender: UISwitch) {
        currentAppearance.prefersLargeTitles = sender.isOn
        self.navigationController?.navigationBar.prefersLargeTitles = sender.isOn
    }
    
    @IBAction func nextHiddenSwitchValueChanged(_ sender: UISwitch) {
        nextAppearance.isHidden = sender.isOn
    }
    
    @IBAction func nextTranslucentSwitchValueChanged(_ sender: UISwitch) {
        nextAppearance.isTranslucent = sender.isOn
    }
    
    @IBAction func nextLargeTitlesSwitchValueChanged(_ sender: UISwitch) {
        nextAppearance.prefersLargeTitles = sender.isOn
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Example17ViewController {
            destination.currentAppearance = self.nextAppearance;
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            navigationController?.popViewController(animated: true)
        case 1:
            break;
        case 2:
            break;
        case 3:
            let nextVC = Example17Page.allCases[indexPath.row].viewController
            nextVC.currentAppearance = nextAppearance
            navigationController?.pushViewController(nextVC, animated: true)
        default:
            break
        }
    }
    
}
