//
//  APIConcurrencyPolicyViewController.swift
//  Example
//
//  Created by mlibai on 2018/7/9.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit

protocol APIConcurrencyPolicyViewControllerDelegate: NSObjectProtocol {
    func viewController(_ viewController: APIConcurrencyPolicyViewController, didSelect policy: APIConcurrency.Policy) -> Void
}

class APIConcurrencyPolicyViewController: UITableViewController, NavigationBarCustomizable {
    
    weak var delegate: APIConcurrencyPolicyViewControllerDelegate?
    
    let dataArray = [
        ("默认优先级", APIConcurrency.Policy.default),
        ("取消其他请求", APIConcurrency.Policy.cancelOthers),
        ("忽略当前请求", APIConcurrency.Policy.ignoreCurrent),
        ("排队等待", APIConcurrency.Policy.wait(priority: 100))
    ]
    
    var selectedPolicy: APIConcurrency.Policy
    
    init(_ selectedPolicy: APIConcurrency.Policy) {
        self.selectedPolicy = selectedPolicy
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.title = "APIConcurrencyPolicy"
        self.navigationBar.backButton?.setTitle("返回", for: .normal)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let policy = dataArray[indexPath.row]
        
        cell.textLabel!.text = String.init(describing: dataArray[indexPath.row].0)
        
        if policy.1 == selectedPolicy {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.viewController(self, didSelect: self.dataArray[indexPath.row].1)
        self.navigationController!.popViewController(animated: true)
    }
}
