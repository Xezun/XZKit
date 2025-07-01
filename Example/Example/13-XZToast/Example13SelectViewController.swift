//
//  Example13SelectViewController.swift
//  Example
//
//  Created by 徐臻 on 2025/5/10.
//

import UIKit

class Example13SelectViewController: UITableViewController {
    
    var value = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = value == indexPath.row ? .checkmark : .disclosureIndicator;
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        value = indexPath.row
        tableView.reloadData()
    }

}
