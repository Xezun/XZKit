//
//  Example09SettingsSizeViewController.swift
//  Example
//
//  Created by 徐臻 on 2024/6/28.
//

import UIKit

class Example09SettingsSizeViewController: UITableViewController {
    
    var value = CGSize.zero
    
    @IBOutlet weak var widthControl: UISegmentedControl!
    
    @IBOutlet weak var heightControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        widthControl.setTitle("\(Int(value.width))", forSegmentAt: 1)
        heightControl.setTitle("\(Int(value.height))", forSegmentAt: 1)
    }

    @IBAction func widthControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if value.width > 0 {
                value.width -= 1
            }
        case 1:
            break;
        case 2:
            value.width += 1
        default:
            break
        }
        sender.setTitle("\(Int(value.width))", forSegmentAt: 1)
        sender.selectedSegmentIndex = UISegmentedControl.noSegment
    }
    
    @IBAction func heightControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if value.height > 0 {
                value.height -= 1
            }
        case 1:
            break;
        case 2:
            value.height += 1
        default:
            break
        }
        sender.setTitle("\(Int(value.height))", forSegmentAt: 1)
        sender.selectedSegmentIndex = UISegmentedControl.noSegment
    }
}
