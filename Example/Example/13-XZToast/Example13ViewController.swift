//
//  Example13ViewController.swift
//  Example
//
//  Created by 徐臻 on 2025/1/5.
//

import UIKit
import XZToast

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
            showToast("消息文本")
        case 1:
            showToast(.loading("加载中..."))
        default:
            break
        }
    }

}
