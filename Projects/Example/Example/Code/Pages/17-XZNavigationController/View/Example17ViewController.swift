//
//  Example17ViewController.swift
//  Example
//
//  Created by 徐臻 on 2026/2/12.
//

import UIKit
import XZKit

/// 基类。
@mocoa
class Example17ViewController: UITableViewController, XZMocoaView {
    
    @bind("currentHidden", v: .isOn)
    @IBOutlet weak var hiddenSwitch: UISwitch!
    
    @bind("currentTranslucent", v: .isOn)
    @IBOutlet weak var translucentSwitch: UISwitch!
    
    @bind("currentLargeTitles", v: .isOn)
    @IBOutlet weak var largeTitlesSwitch: UISwitch!
    
    @bind("nextHidden", v: .isOn)
    @IBOutlet weak var nextHiddenSwitch: UISwitch!
    
    @bind("nextTranslucent", v: .isOn)
    @IBOutlet weak var nextTranslucentSwitch: UISwitch!
    
    @bind("nextLargeTitles", v: .isOn)
    @IBOutlet weak var nextLargeTitlesSwitch: UISwitch!
    
    /// 当前页面的导航栏外观样式。在 viewWillAppear 之后，表示预设的下一页导航栏样式。
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ( self is XZNavigationBarCustomizable ? .lightContent : .darkContent )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 首个控制器需要自己创建视图模型。
        if self.viewModel == nil {
            self.viewModel = Example17ViewModel.init(model: Example17Model.init())
        }
        
        // 设置当前页的导航栏样式
        if let navigationBar = (self as? XZNavigationBarCustomizable)?.navigationBar {
            let viewModel = self.viewModel as! Example17ViewModel
            navigationBar.isHidden           = viewModel.currentHidden
            navigationBar.isTranslucent      = viewModel.currentTranslucent
            navigationBar.prefersLargeTitles = viewModel.currentLargeTitles
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #XZLog("isModalInPresentation: \(self.isModalInPresentation)")
    }
    
    @IBAction func currentHiddenSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.currentHidden = sender.isOn;
        
        self.navigationController?.setNavigationBarHidden(sender.isOn, animated: true)
    }
    
    @IBAction func currentTranslucentSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.currentTranslucent = sender.isOn
        
        self.navigationController?.navigationBar.isTranslucent = sender.isOn
    }
    
    @IBAction func currentLargeTitlesSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.currentLargeTitles = sender.isOn
        
        self.navigationController?.navigationBar.prefersLargeTitles = sender.isOn
    }
    
    @IBAction func nextHiddenSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.nextHidden = sender.isOn
    }
    
    @IBAction func nextTranslucentSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.nextTranslucent = sender.isOn
    }
    
    @IBAction func nextLargeTitlesSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.nextLargeTitles = sender.isOn
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Example17ViewController {
            let viewModel = self.viewModel as! Example17ViewModel
            destination.viewModel = viewModel.next
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
            let viewModel = self.viewModel as! Example17ViewModel
            let nextVC = Example17PageType.allCases[indexPath.row].viewController
            nextVC.viewModel = viewModel.next
            navigationController?.pushViewController(nextVC, animated: true)
        default:
            break
        }
    }
    
}


enum Example17PageType: String, CaseIterable {
    
    /// 定制页
    case DingZhi
    /// 导航页
    case DaoHang
    /// 手势页
    case ShouShi
    /// 原生页
    case YuanSen
    
    var name: String {
        switch self {
        case .DingZhi:
            return "定制页"
        case .DaoHang:
            return "导航页"
        case .ShouShi:
            return "手势页"
        case .YuanSen:
            return "原生页"
        }
    }
    
    var viewController: Example17ViewController {
        let storyboard = UIStoryboard(name: "Example17", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: self.rawValue) as! Example17ViewController
    }
    
}
