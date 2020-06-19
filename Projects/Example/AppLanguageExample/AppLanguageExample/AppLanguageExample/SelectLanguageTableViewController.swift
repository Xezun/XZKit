//
//  SelectLanguageTableViewController.swift
//  Example
//
//  Created by Xezun on 2019/3/13.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

class SelectLanguageTableViewController: UITableViewController {
    
    let languages: [AppLanguage] = [.Chinese, .English]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if languages[indexPath.row] == AppLanguage.preferred {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = languages[indexPath.row]
        if selectedLanguage == AppLanguage.preferred {
            navigationController!.popViewController(animated: true)
        } else {
            AppLanguage.preferred = selectedLanguage
            let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootViewController")
            navigationController!.setViewControllers([rootVC], animated: true)
        }
    }

}
