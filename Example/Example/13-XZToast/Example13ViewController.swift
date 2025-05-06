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
            let start = timestamp()
            let duration = TimeInterval(arc4random_uniform(4000) + 1000) / 1000.0 + 1.0;
            let message = String(format: "这是一个 %.2f 秒的消息", duration);
            self.showToast(.message(message), duration: duration, position: .bottom, offset: 0, exclusive: false) { finished in
                let end = timestamp()
                print("消息 “\(message)” 回调：\(finished) 展示时间 \(start) => \(end) 共 \(end - start)")
            }
        case 1:
            self.showToast(.message("这是消息1"), duration: 0.1, position: .bottom, offset: 0, exclusive: false)
        
        case 2:
            self.showToast(.message("这是消息2"), duration: 3.0, position: .bottom, offset: 0, exclusive: false)
            self.showToast(.message("这是消息3"), duration: 2.0, position: .bottom, offset: 0, exclusive: false)
//            showToast(.loading("加载中..."))
            break
        default:
            break
        }
    }

}
