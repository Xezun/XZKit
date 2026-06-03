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
                let message = "消息".padding(toLength: length, withPad: "消息", startingAt: 0);
                showMessage(message, duration: duration)
                
            case 1:
                showMessage("时长 0.1 秒的消息", duration: 0.1)
            
            case 2:
                showMessage("消息A", duration: 3.0);
                showMessage("消息B", duration: 3.0 - XZToast.animationDuration);
                showMessage("消息C", duration: 3.0 - XZToast.animationDuration * 2.5);
                
            case 3:
                showMessage("独占 3.0 秒时长", duration: 3, exclusive: true)
                
            case 4:
                showMessage("字数特别多、长度特别长的超级长消息")
                
            case 5:
                showMessage("字数特别多，分两行的信息\n长度特别长的超级长消息")
                
            case 6:
                showMessage("短消息")
            
            case 7:
                showMessage("登录成功", style: .success)
                
            case 8:
                showMessage("登录失败", style: .failure)
            
            case 9:
                showMessage("请30秒后再试", style: .waiting)
                
            case 10:
                showMessage("您无访问权限", style: .warning)
                
            case 11:
                showMessage("正在处理中", style: .loading)
                
            case 12:
                showToast(.loading("请稍后"), duration: 1.3, exclusive: true)
                showToast(.message("测试即将开始"), duration: 1.3, exclusive: true)
                showToast(.success("添加成功"), duration: 1.3, exclusive: true)
                showToast(.waiting("请等待倒计时结束"), duration: 1.3, exclusive: true)
                showToast(.warning("无权访问"), duration: 1.3, exclusive: true)
                showToast(.failure("网络不给力，请稍后再试"), duration: 1.3, exclusive: true)
                showToast(.message("测试加载进度"), duration: 1.3, exclusive: true)
                let loading = self.showToast(.loading("开始下载"), duration: 0.0, exclusive: true)
                DispatchQueue.global().async {
                    Thread.sleep(forTimeInterval: 15.0)
                    for i in 1 ... 100 {
                        Thread.sleep(forTimeInterval: 0.03)
                        DispatchQueue.main.sync {
                            let toast = loading.toast
                            toast.progress = CGFloat(i) / 100.0;
                            toast.text = String(format: "已下载 %.2f%%", CGFloat(i));
                        }
                    }
                    Thread.sleep(forTimeInterval: 1.0)
                    DispatchQueue.main.async {
                        loading.hide()
                        self.showToast(.success("下载成功"));
                    }
                }
                break
                
            case 13:
                let button = UIButton.init(type: .system)
                button.backgroundColor = UIColor.orange
                button.layer.cornerRadius = 8.0;
                button.setTitleColor(.white, for: .normal)
                button.setAttributedTitle(.init(string: "点击这里", attributes: [
                    .font: UIFont.systemFont(ofSize: 17.0, weight: .bold)
                ]), for: .normal)
                button.contentEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
                button.addTarget(self, action: #selector(customToastViewAction(_:)), for: .touchUpInside)
                self.showToast(.init(style: .message, view: button), duration: 0, position: .bottom)
                break
                
            case 14:
                self.showToast(.message("请打开日志查看消息是否复用")) { _ in
                    self.showToast(.message("回调中的消息"))
                }
                break
                
            default:
                self.hideToast();
                
            }
        case 1:
            switch indexPath.row {
            case 0:
                guard loadingToast == nil else { return }
                loadingToast = showMessage("开始加载", style: .loading, duration: 0, exclusive: true);
                
            case 1:
                break
                
            case 2:
                guard let loadingToast = loadingToast else { return }
                self.loadingToast = nil;
                loadingToast.hide()
                if loadingToast.toast.progress == 1.0 {
                    showMessage("加载成功", style: .success)
                } else {
                    showMessage("加载失败", style: .failure)
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
    func showMessage(_ message: String, style: XZToast.Style = .message, duration: TimeInterval = 1.0, exclusive: Bool? = nil) -> XZToast.Task {
        let start = timestamp()
        let index = self.index
        let completion: XZToast.Completion = { finished in
            let end = timestamp()
            let delta = String.init(format: "%.2f", end - start);
            let date = Date().formatted(using: .msecDateTime)
            let message = message.replacingOccurrences(of: "\n", with: "\\n")
            #XZLog("消息：\(index). \(message) \n状态：\(finished) \n定时：\(duration) \n耗时：\(delta) \n时间：\(date)")
        };
        self.index = index + 1;
        
        let isExclusive = exclusive ?? self.isExclusive
        
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
    
    @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
        tableView.scrollToRow(at: .init(row: 0, section: 2), at: .top, animated: true)
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
        
        loadingToast.text     = String.init(format: "已加载 %0.2f%%", sender.value);
        loadingToast.progress = CGFloat(sender.value / 100);
    }
    
    @IBAction func toastControllerSwitchValueChanged(_ sender: UISwitch) {
        navigationController?.showToast(sender.isOn ? "基于“当前控制器”进行展示" : "基于“导航控制器”进行展示")
    }
    
    @objc func customToastViewAction(_ sender: Any) {
        self.showToast(.message("您点击了按钮"))
    }
    
    override var toastManager: XZToastManager {
        return self.toastControllerSwitch.isOn ? super.toastManager : navigationController!.toastManager
    }
    
}
