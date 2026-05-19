//
//  Example13ViewController.swift
//  Example
//
//  Created by Xezun on 2025/1/5.
//

import UIKit
import XZKit

class Example13ViewController: UITableViewController {
    
    deinit {
        NSLog("\(self) is deinit");
    }
    
    var index = 0
    var position = XZToast.Position.middle;
    var isExclusive = false
    var loadingToast: XZToast.Task?
    
    @IBOutlet weak var toastControllerSwitch: UISwitch!
    @IBOutlet weak var toastBackgroundColorPreviewr: UIView!
    @IBOutlet weak var toastTextColorPreviewr: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        toastBackgroundColorPreviewr.layer.cornerRadius = 12.0;
        toastBackgroundColorPreviewr.layer.borderWidth = 1.0;
        toastBackgroundColorPreviewr.layer.borderColor = UIColor.black.cgColor;
        
        toastTextColorPreviewr.layer.cornerRadius = 12.0;
        toastTextColorPreviewr.layer.borderWidth = 1.0;
        toastTextColorPreviewr.layer.borderColor = UIColor.black.cgColor;
        
        toastBackgroundColorPreviewr.backgroundColor = toastManager.backgroundColor ?? XZToast.backgroundColor;
        toastTextColorPreviewr.backgroundColor       = toastManager.textColor ?? XZToast.textColor;
        
        toastManager.font = UIFont.monospacedSystemFont(ofSize: 17.0, weight: .regular)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let duration = TimeInterval(arc4random_uniform(300)) / 100 + 1.0;
                let length = Int(arc4random_uniform(18)) + 2;
                let message = "随机消息".padding(toLength: length, withPad: "消息", startingAt: 0);
                showMessage(message, duration: duration)
                
            case 1:
                showMessage("时长 0.1 秒的消息", duration: 0.1)
            
            case 2:
                showMessage("消息A", duration: 3.0);
                showMessage("消息B", duration: 3.0 - XZToast.animationDuration);
                showMessage("消息C", duration: 3.0 - XZToast.animationDuration * 2.5);
                
            case 3:
                let toast1 = showMessage("消息1", duration: 1.0).toast;
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + XZToast.animationDuration * 1.1) {
                    let view1 = toast1.view;
                    let toast2 = self.showMessage("消息2：检测视图复用中", duration: 3.0).toast;
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if toast2.view == view1 {
                            toast2.text = "消息2：复用了消息1的视图"
                        } else {
                            toast2.text = "消息2：没有发生视图复用"
                        }
                    }
                }
                
            case 4:
                showMessage("字数特别多，分两行的信息\n长度特别长的超级长消息")
                
            case 5:
                showMessage("字数特别多、长度特别长的超级长消息")
                
            case 6:
                showMessage("短消息")
            
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
                
            }
        case 1:
            switch indexPath.row {
            case 0:
                guard loadingToast == nil else { return }
                loadingToast = showToast(.loading("请稍后"), duration: 0, position: position, exclusive: true) { [weak self] finished in
                    #XZLog("加载 loading 类型的消息，展示完成：\(finished)")
                    self?.loadingToast = nil;
                }
            case 1:
                break
            case 2:
                guard let loadingToast = loadingToast else { return }
                loadingToast.hide {
                    #XZLog("隐藏 loading 类型的消息，操作完成：\(loadingToast)");
                }
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    @discardableResult
    func showMessage(_ message: String, style: XZToast.Style = .message, duration: TimeInterval = 1.0) -> XZToast.Task {
        let start = timestamp()
        let index = self.index
        let completion: XZToast.Completion = { finished in
            let end = timestamp()
            let delta = String.init(format: "%.2f", end - start);
            let format = XZDateFormatStyle.init(rawValue: "yyyy-MM-dd hh:mm:ss.SSS")
            #XZLog("消息：\(index). \(message) \n状态：\(finished) \n定时：\(duration) \n耗时：\(delta) \n时间：\(Date().formatted(using: format.dateFormatter))")
        };
        self.index = index + 1;
        
        switch style {
        case .message:
            return showToast(.message(message), duration: duration, position: position, exclusive: isExclusive, completion: completion)
        case .loading:
            return showToast(.loading(message), duration: duration, position: position, exclusive: isExclusive, completion: completion)
        case .success:
            return showToast(.success(message), duration: duration, position: position, exclusive: isExclusive, completion: completion)
        case .failure:
            return showToast(.failure(message), duration: duration, position: position, exclusive: isExclusive, completion: completion)
        case .warning:
            return showToast(.warning(message), duration: duration, position: position, exclusive: isExclusive, completion: completion)
        case .waiting:
            return showToast(.waiting(message), duration: duration, position: position, exclusive: isExclusive, completion: completion)
        @unknown default:
            return showToast(.message(message), duration: duration, position: position, exclusive: isExclusive, completion: completion)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "backgroundColorPicker":
            guard let picker = segue.destination as? Example13ColorViewController else { return }
            picker.color = self.toastManager.backgroundColor ?? XZToast.backgroundColor;
            picker.identifier = segue.identifier;
        case "textColorPicker":
            guard let picker = segue.destination as? Example13ColorViewController else { return }
            picker.color = self.toastManager.textColor ?? XZToast.textColor;
            picker.identifier = segue.identifier;
        default:
            break
        }
    }
    
    @IBAction func hideButtonAction(_ sender: UIBarButtonItem) {
        self.hideToast()
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        switch unwindSegue.identifier {
        case "colorPicker":
            guard let picker = unwindSegue.source as? Example13ColorViewController else { return }
            switch picker.identifier {
            case "backgroundColorPicker":
                self.toastManager.backgroundColor = picker.color;
                self.toastBackgroundColorPreviewr.backgroundColor = picker.color;
            case "textColorPicker":
                self.toastManager.textColor = picker.color;
                self.toastTextColorPreviewr.backgroundColor = picker.color;
            default:
                break;
            }
        default:
            break
        }
    }

    @IBAction func exclusiveSwitchValueChanged(_ sender: UISwitch) {
        self.isExclusive = sender.isOn
    }
    
    @IBAction func positionButtonValueChanged(_ sender: UISegmentedControl) {
        guard let position = XZToast.Position.init(rawValue: sender.selectedSegmentIndex) else { return }
        self.position = position;
    }
    
    @IBAction func countButtonValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.toastManager.maximumNumberOfToasts -= 1;
        case 1:
            return
        case 2:
            self.toastManager.maximumNumberOfToasts += 1;
        default:
            return
        }
        sender.setTitle("\(self.toastManager.maximumNumberOfToasts)", forSegmentAt: 1)
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        guard let loadingToast = self.loadingToast?.toast else { return }
        
        if sender.value == 0 {
            loadingToast.text = "请稍后";
        } else if sender.value == 100.0 {
            loadingToast.text = "加载成功"
        } else {
            loadingToast.text =  String.init(format: "已加载 %0.2f%%", sender.value);
        }
        loadingToast.progress = CGFloat(sender.value / 100);
    }
    
    @IBAction func toastControllerSwitchValueChanged(_ sender: UISwitch) {
        navigationController?.showToast(sender.isOn ? "基于“当前控制器”进行展示" : "基于“导航控制器”进行展示")
    }
    
    override var toastManager: XZToastManager {
        return self.toastControllerSwitch.isOn ? super.toastManager : navigationController!.toastManager
    }
    
}
