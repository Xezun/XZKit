//
//  Example17SelectNextViewController.swift
//  Example
//
//  Created by 徐臻 on 2026/2/12.
//

import UIKit

class Example17SelectNextViewController: UITableViewController {
    
    var selectedPage = Example17PageType.DingZhi
    
    private let pages = Example17PageType.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let page = pages[indexPath.row]
        cell.textLabel?.text = page.name
        
        if page == selectedPage {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPage = pages[indexPath.row]
        performSegue(withIdentifier: "confirm", sender: nil)
    }

}
