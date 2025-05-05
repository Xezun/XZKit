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
            self.showToast(.message("这是消息1"), duration: 4.0, position: .bottom, offset: 0, isExclusive: false)
            self.showToast(.message("这是消息2"), duration: 3.0, position: .bottom, offset: 0, isExclusive: false)
            self.showToast(.message("这是消息3"), duration: 2.0, position: .bottom, offset: 0, isExclusive: false)
        case 1:
//            showToast(.loading("加载中..."))
            break
        default:
            break
        }
    }

}
