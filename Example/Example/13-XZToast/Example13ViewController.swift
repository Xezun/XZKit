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
    
    deinit {
        NSLog("\(self) is deinit");
    }
    
    var index = 0
    
    var position = XZToast.Position.middle;
    
    var isExclusive = false
    var reuseMode = false
    
    weak var loadingToast: XZToast?
    
    @IBOutlet weak var toastControllerSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
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
                showMessage("操作成功", style: .success)
                
            case 8:
                showMessage("操作失败", style: .failure)
            
            case 9:
                showMessage("请耐心等待", style: .waiting)
                
            case 10:
                showMessage("非法访问", style: .warning)
                
            case 11:
                showMessage("处理中", style: .loading)
                
            default:
                self.hideToast();
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                guard loadingToast == nil else { return }
                loadingToast = showToast(.loading(nil), duration: 0, position: position, exclusive: true) { [weak self] finished in
                    NSLog("加载类型的 XZToast 展示结束：\(finished)")
                    self?.loadingToast = nil;
                }
            case 1:
                break
            case 2:
                self.hideToast()
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    func showMessage(_ message: String, style: XZToast.Style = .message, duration: TimeInterval = 3.0) {
        let start = timestamp()
        let index = self.index
        let text  = "\(index). \(message)"
        let completion: XZToast.Completion = { finished in
            let end = timestamp()
            let delta = String.init(format: "%.2f", end - start);
            NSLog("消息：\(index). \(message) \n状态：\(finished) \n定时：\(duration) \n耗时：\(delta)")
        };
        
        if reuseMode {
            showToast(.shared(for: style, text: text, image: nil), duration: duration, position: self.position, exclusive: self.isExclusive, completion: completion)
        } else {
            switch style {
            case .message:
                showToast(.message(text), duration: duration, position: position, exclusive: isExclusive, completion: completion)
            case .loading:
                showToast(.loading(text), duration: duration, position: position, exclusive: isExclusive, completion: completion)
            case .success:
                showToast(.success(text), duration: duration, position: position, exclusive: isExclusive, completion: completion)
            case .failure:
                showToast(.failure(text), duration: duration, position: position, exclusive: isExclusive, completion: completion)
            case .warning:
                showToast(.warning(text), duration: duration, position: position, exclusive: isExclusive, completion: completion)
            case .waiting:
                showToast(.waiting(text), duration: duration, position: position, exclusive: isExclusive, completion: completion)
            @unknown default:
                showToast(.message(text), duration: duration, position: position, exclusive: isExclusive, completion: completion)
            }
        }
        
        self.index = index + 1;
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
        self.hideToast()
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        guard let select = unwindSegue.source as? Example13SelectViewController else { return }
        switch unwindSegue.identifier {
        case "position":
            self.position = XZToast.Position.init(rawValue: select.value)!
            if let cell = tableView.cellForRow(at: .init(row: 0, section: 2)) {
                cell.detailTextLabel?.text = position.description
            }
        case "maximumNumberOfToasts":
            self.maximumNumberOfToasts = select.value
            if let cell = tableView.cellForRow(at: .init(row: 1, section: 2)) {
                cell.detailTextLabel?.text = select.value.description
            }
        default:
            break
        }
    }

    @IBAction func exclusiveSwitchValueChanged(_ sender: UISwitch) {
        self.isExclusive = sender.isOn
    }
    
    @IBAction func reuseModeSwitchValueChanged(_ sender: UISwitch) {
        self.reuseMode = sender.isOn
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        guard let loadingToast = self.loadingToast else { return }
        if sender.value == 0 {
            loadingToast.text = nil;
        } else if sender.value == 100.0 {
            loadingToast.text = "加载成功"
        } else {
            loadingToast.text = String.init(format: "加载进度 %.2f%%", sender.value);
        }
    }
    
    // 由于当前容器视图为 UITableView 所以在
    override var toastController: UIViewController? {
        return toastControllerSwitch.isOn ? navigationController : self
    }
}
