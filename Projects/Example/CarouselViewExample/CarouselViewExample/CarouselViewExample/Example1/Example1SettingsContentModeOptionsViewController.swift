//
//  Example1SettingsContentModeOptionsViewController.swift
//  CarouselViewExample
//
//  Created by 徐臻 on 2019/4/28.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

protocol Example1SettingsContentModeOptionsViewControllerDelegate: NSObjectProtocol {
    
    func contentModeOptionsViewController(_ viewController: Example1SettingsContentModeOptionsViewController, didSelect contentMode: UIView.ContentMode)
}

class Example1SettingsContentModeOptionsViewController: UITableViewController {

    weak var delegate: Example1SettingsContentModeOptionsViewControllerDelegate?
    
    var contentMode = UIView.ContentMode.redraw
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath.row == contentMode.rawValue {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let contentMode = UIView.ContentMode.init(rawValue: indexPath.row) {
            delegate?.contentModeOptionsViewController(self, didSelect: contentMode)
            navigationController?.popViewController(animated: true)
        }
    }

}
