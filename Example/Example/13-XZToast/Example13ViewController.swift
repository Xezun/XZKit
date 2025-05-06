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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let duration = TimeInterval(arc4random_uniform(5)) + 0.5;
            let message = String(format: "这是一个 %.2f 秒的消息", duration);
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
            self.showToast(.message("这是消息2"), duration: 3.0, position: .bottom, offset: 0, exclusive: false)
            self.showToast(.message("这是消息3"), duration: 2.0, position: .bottom, offset: 0, exclusive: false)
//            showToast(.loading("加载中..."))
            break
        default:
            break
        }
    }
    
    func showMessage(_ message: String, duration: TimeInterval) {
        let start = timestamp()
        let index = self.index
        self.showToast(.message("\(index). \(message)"), duration: duration, position: .bottom, offset: 0, exclusive: false) { finished in
            let end = timestamp()
            let delta = String.init(format: "%.2f", end - start);
            NSLog("消息：\(index). \(message) \n状态：\(finished) \n定时：\(duration) \n耗时：\(delta)")
        }
        self.index += 1;
    }

}
