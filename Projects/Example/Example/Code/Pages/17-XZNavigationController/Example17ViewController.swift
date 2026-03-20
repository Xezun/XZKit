//
//  Example17ViewController.swift
//  Example
//
//  Created by 徐臻 on 2026/2/12.
//

import UIKit
import XZKit

enum Example17PageType: String, CaseIterable {
    
    case DingZhi
    case DaoHang
    case ShouShi
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

@objc class Example17Configuration: NSObject {
    @objc var isHidden = false
    @objc var isTranslucent = true
    @objc var prefersLargeTitles = false
}

@mocoa(.m)
@objc class Example17Model: NSObject, XZMocoaModel {
    
    @objc var current: Example17Configuration
    @objc var next  = Example17Configuration.init()
    
    init(current: Example17Configuration = .init()) {
        self.current = current
        super.init()
        
        self.addObserver(self, forKeyPath: "current.isHidden", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        #XZLog("KVO: \(keyPath) => \(object)")
    }
    
}

@mocoa(.vm)
class Example17ViewModel: XZMocoaViewModel {
    
    override var shouldObserveModelKeysActively: Bool {
        return true
    }
    
    @key(value: false)
    @bind("current.isHidden")
    var currentHidden: Bool
    
    @key(value: true)
    @bind("current.isTranslucent")
    var currentTranslucent: Bool
    
    @key(value: false)
    @bind("current.prefersLargeTitles")
    var currentLargeTitles: Bool
    
    @key(value: false)
    @bind("next.isHidden")
    var nextHidden: Bool
    
    @key(value: true)
    @bind("next.isTranslucent")
    var nextTranslucent: Bool
    
    @key(value: false)
    @bind("next.prefersLargeTitles")
    var nextLargeTitles: Bool
    
    var next: Example17ViewModel {
        let model = Example17Model.init(current: (self.model as! Example17Model).next)
        return .init(model: model)
    }
        
    func currentHiddenChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.current.isHidden = newValue
    }
    
    func currentTranslucentChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.current.isTranslucent = newValue
    }
    
    func currentLargeTitlesChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.current.prefersLargeTitles = newValue
    }
    
    func nextHiddenChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.next.isHidden = newValue
    }
    
    func nextTranslucentChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.next.isTranslucent = newValue
    }
    
    func nextLargeTitlesChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.next.prefersLargeTitles = newValue
    }
    
}



/// 基类。
@mocoa(.v)
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
        
        if self.viewModel == nil {
            self.viewModel = Example17ViewModel.init(model: Example17Model.init())
        }
        
        
//        // 设置当前页的导航栏样式
//        if let navigationBar = (self as? XZNavigationBarCustomizable)?.navigationBar {
//            navigationBar.isHidden = pageConfiguration.isHidden
//            navigationBar.isTranslucent = pageConfiguration.isTranslucent
//            navigationBar.prefersLargeTitles = pageConfiguration.prefersLargeTitles
//        }
//        
//        // 同步数据
//        self.nextHiddenSwitch.isOn = nextHiddenSwitch.isOn
//        self.nextTranslucentSwitch.isOn = nextTranslucentSwitch.isOn
//        self.nextLargeTitlesSwitch.isOn = nextLargeTitlesSwitch.isOn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 未定制导航栏的控制器设置导航栏样式
        if self is XZNavigationBarCustomizable {
            return
        }
//        if let navigationController = self.navigationController {
//            let uiNavigationBar = navigationController.navigationBar;
//            uiNavigationBar.isTranslucent = pageConfiguration.isTranslucent
//            uiNavigationBar.prefersLargeTitles = pageConfiguration.prefersLargeTitles
//            navigationController.setNavigationBarHidden(pageConfiguration.isHidden, animated: animated)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #XZLog("isModalInPresentation: \(self.isModalInPresentation)")
    }
    
    @IBAction func currentHiddenSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.currentHiddenChangeValue(sender.isOn)
        
        self.navigationController?.setNavigationBarHidden(sender.isOn, animated: true)
    }
    
    @IBAction func currentTranslucentSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.currentTranslucentChangeValue(sender.isOn)
        
        self.navigationController?.navigationBar.isTranslucent = sender.isOn
    }
    
    @IBAction func currentLargeTitlesSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.currentLargeTitlesChangeValue(sender.isOn)
        
        self.navigationController?.navigationBar.prefersLargeTitles = sender.isOn
    }
    
    @IBAction func nextHiddenSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.nextHiddenChangeValue(sender.isOn)
    }
    
    @IBAction func nextTranslucentSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.nextTranslucentChangeValue(sender.isOn)
    }
    
    @IBAction func nextLargeTitlesSwitchValueChanged(_ sender: UISwitch) {
        let viewModel = self.viewModel as! Example17ViewModel
        viewModel.nextLargeTitlesChangeValue(sender.isOn)
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
