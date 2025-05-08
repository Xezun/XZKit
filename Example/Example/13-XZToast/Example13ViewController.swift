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
    
    var position = XZToastPosition.middle;
    let toastCountNumbers: [UInt] = [0, 1, 2, 3, 5]
    
    var isExclusive = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath);
        switch indexPath.section {
        case 0:
            break
        case 1:
            cell.accessoryType = indexPath.row == position.rawValue ? .checkmark : .disclosureIndicator;
            break
        case 2:
            let number = String(self.maximumNumberOfToasts);
            if cell.textLabel?.text == number {
                cell.accessoryType = .checkmark;
            } else {
                cell.accessoryType = .disclosureIndicator;
            }
            break
            
        case 3:
            switch indexPath.row {
            case 0:
                cell.accessoryType = isExclusive ? .checkmark : .disclosureIndicator;
                break
            default:
                break
            }
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
                let sample = "这是一个字数特别多所以长度很长的消息";
                
                let index = sample.index(sample.startIndex, offsetBy: Int(arc4random_uniform(UInt32(sample.count))))
                let message = String(format: "[%.2f] %@", duration, String(sample[..<index]));
                showMessage(message, duration: duration)
            case 1:
                showMessage("这个消息时长很短", duration: 0.1)
            
            case 2: // 1、2 同时消失
                showMessage("消息1", duration: 3.0);
                showMessage("消息2", duration: 3.0 - XZToast.animationDuration);
                showMessage("消息3", duration: 3.0 - XZToast.animationDuration * 2.5);
                
            case 3: // 2、3 同时消失
                showMessage("消息1", duration: 3.0);
                showMessage("消息2", duration: 3.0 - XZToast.animationDuration * 0.5);
                showMessage("消息3", duration: 3.0 - XZToast.animationDuration * 1.5);
                
            case 4: // 1、3 同时消失
                showMessage("消息1", duration: 3.0);
                showMessage("消息2", duration: 3.0 - XZToast.animationDuration * 1.5);
                showMessage("消息3", duration: 3.0 - XZToast.animationDuration * 2.0);
                
            case 10:
                self.showToast(.message("这是消息2"), duration: 3.0, position: .bottom, exclusive: false)
                self.showToast(.message("这是消息3"), duration: 2.0, position: .bottom, exclusive: false)
    //            showToast(.loading("加载中..."))
                break
            default:
                break
            }
        case 1:
            self.position = .init(rawValue: UInt(indexPath.row))!
            tableView.reloadSections([indexPath.section], with: .none)
        case 2:
            guard let text = tableView.cellForRow(at: indexPath)?.textLabel?.text else { return }
            guard let number = UInt(text) else { return }
            self.maximumNumberOfToasts = number
            tableView.reloadSections([indexPath.section], with: .none);
        case 3:
            switch indexPath.row {
            case 0:
                isExclusive = !isExclusive;
                tableView.reloadRows(at: [indexPath], with: .none);
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
        self.showToast(.message("\(index). \(message)"), duration: duration, position: self.position, exclusive: self.isExclusive) { finished in
            let end = timestamp()
            let delta = String.init(format: "%.2f", end - start);
            NSLog("消息：\(index). \(message) \n状态：\(finished) \n定时：\(duration) \n耗时：\(delta)")
        }
        self.index += 1;
    }

}
