//
//  Example02ViewController.swift
//  Example
//
//  Created by 徐臻 on 2025/10/11.
//

import UIKit
import XZKit

class Example02ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #XZLog("")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let dateString = "2025-09-09 09:10:20"
            
            let date = Date.init(from: dateString, using: .dateTime)!            
            
            #XZLog("\(XZDateFormat.dateTime) => \(date.string(using: .dateTime))");
            #XZLog("\(XZDateFormat.shortDateTime) => \(date.string(using: .shortDateTime))");
            
            #XZLog("\(XZDateFormat.date) => \(date.string(using: .date))");
            #XZLog("\(XZDateFormat.shortDate) => \(date.string(using: .shortDate))");
            
            #XZLog("\(XZDateFormat.monthDay) => \(date.string(using: .monthDay))");
            #XZLog("\(XZDateFormat.shortMonthDay) => \(date.string(using: .shortMonthDay))");
            
            #XZLog("\(XZDateFormat.time) => \(date.string(using: .time))");
            #XZLog("\(XZDateFormat.shortTime) => \(date.string(using: .shortTime))");
            
            #XZLog("\(XZDateFormat.hourMinute) => \(date.string(using: .hourMinute))");
            #XZLog("\(XZDateFormat.shortHourMinute) => \(date.string(using: .shortHourMinute))");
            
        default:
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }

}
