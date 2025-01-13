//
//  Example19SelectViewController.swift
//  Example
//
//  Created by 徐臻 on 2024/6/14.
//

import UIKit

class Example19SelectViewController: UITableViewController {
    
    public var value: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if cell.textLabel?.text == value {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else { return }
        self.value = cell.textLabel?.text
    }

}
