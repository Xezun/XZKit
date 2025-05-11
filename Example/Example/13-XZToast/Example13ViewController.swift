//
//  Example13ViewController.swift
//  Example
//
//  Created by Xezun on 2025/1/5.
//

import UIKit
import XZToast
import XZMocoa
import XZLocale
import XZDefines

class Example13ViewController: UITableViewController {
    
    var index = 0
    
    var position = XZToast.Position.middle;
    
    unowned var toastController: UIViewController! = nil
    
    var isExclusive = false
    
    lazy var loadingView = XZToastActivityIndicatorView.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toastController = self
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath);
        switch indexPath.section {
        case 0:
            break
        case 1:
            break
        case 2:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = "\(self.position)"
            case 1:
                cell.detailTextLabel?.text = "\(self.maximumNumberOfToasts)"
            default:
                break
            }
            break
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let duration = TimeInterval(arc4random_uniform(3)) + 2.0;
                let length = Int(arc4random_uniform(18)) + 2;
                let message = String(format: "[%.2f] %@", duration, "消息".padding(toLength: length, withPad: "消息", startingAt: 0));
                showMessage(message, duration: duration)
            case 1:
                showMessage("这个消息时长很短", duration: 0.1)
            
            case 2: // 1、2 同时消失
                showMessage("消息A", duration: 3.0);
                showMessage("消息B", duration: 3.0 - XZToast.animationDuration);
                showMessage("消息C", duration: 3.0 - XZToast.animationDuration * 2.5);
                
            case 3: // 2、3 同时消失
                showMessage("消息A", duration: 3.0);
                showMessage("消息B", duration: 3.0 - XZToast.animationDuration * 0.5);
                showMessage("消息C", duration: 3.0 - XZToast.animationDuration * 1.5);
                
            case 4: // 1、3 同时消失
                showMessage("消息A", duration: 3.0);
                showMessage("消息B", duration: 3.0 - XZToast.animationDuration * 1.5);
                showMessage("消息C", duration: 3.0 - XZToast.animationDuration * 2.0);
                
            case 5:
                showMessage("字数特别多、长度特别长的超级长消息", duration: 3.0)
                
            case 6:
                showMessage("短消息", duration: 3.0)
            
            case 7:
                toastController.showToast(.loading("加载中"), duration: 0, position: position, exclusive: isExclusive)
                
            case 10:
                toastController.showToast(.message("这是消息2"), duration: 3.0, position: position, exclusive: isExclusive)
                toastController.showToast(.message("这是消息3"), duration: 2.0, position: position, exclusive: isExclusive)
                toastController.showToast(.loading("加载中..."))
                break
            default:
                toastController.hideToast();
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                loadingView.text = "加载中"
                loadingView.startAnimating()
                toastController.showToast(.init(view: loadingView), duration: 0, position: position, exclusive: true) { finished in
                    NSLog("加载类型的 XZToast 展示结束：\(finished)")
                }
            case 1:
                break
            case 2:
                toastController.hideToast()
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    func showMessage(_ message: String, duration: TimeInterval) {
        let start = timestamp()
        let index = self.index
        toastController.showToast(.message("\(index). \(message)"), duration: duration, position: self.position, exclusive: self.isExclusive) { finished in
            let end = timestamp()
            let delta = String.init(format: "%.2f", end - start);
            NSLog("消息：\(index). \(message) \n状态：\(finished) \n定时：\(duration) \n耗时：\(delta)")
        }
        self.index += 1;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let select = segue.destination as? Example13SelectViewController else { return }
        switch segue.identifier {
        case "position":
            select.value = position.rawValue
        case "maximumNumberOfToasts":
            select.value = self.maximumNumberOfToasts;
        default:
            break
        }
    }
    
    @IBAction func hideButtonAction(_ sender: UIBarButtonItem) {
        toastController.hideToast()
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        guard let select = unwindSegue.source as? Example13SelectViewController else { return }
        switch unwindSegue.identifier {
        case "position":
            self.position = XZToast.Position.init(rawValue: select.value)!
            tableView.reloadRows(at: [.init(row: 0, section: 2)], with: .none)
        case "maximumNumberOfToasts":
            toastController.maximumNumberOfToasts = select.value
            tableView.reloadRows(at: [.init(row: 1, section: 2)], with: .none)
        default:
            break
        }
    }

    @IBAction func exclusiveSwitchValueChanged(_ sender: UISwitch) {
        self.isExclusive = sender.isOn
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        loadingView.text = String.init(format: "加载进度 %.2f%%", sender.value);
        toastController.showToast(.init(view: loadingView))
    }
    
    @IBAction func toastControllerSwitchValueChanged(_ sender: UISwitch) {
        toastController = sender.isOn ? navigationController! : self
    }
}
