//
//  Example02ViewController.swift
//  Example
//
//  Created by 徐臻 on 2025/10/11.
//

import UIKit
import XZKit
import MapKit

class Example02ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let dateString = "2025-09-09 09:10:20"
            #XZLog("日期字符串：\(dateString)")
            
            let date = Date.init(from: dateString, using: .dateTime)!
            
            #XZLog("\(XZDateFormat.dateTime) => \(date.formatted(using: .dateTime))");
            #XZLog("\(XZDateFormat.shortDateTime) => \(date.formatted(using: .shortDateTime))");
            
            #XZLog("\(XZDateFormat.date) => \(date.formatted(using: .date))");
            #XZLog("\(XZDateFormat.shortDate) => \(date.formatted(using: .shortDate))");
            
            #XZLog("\(XZDateFormat.monthDay) => \(date.formatted(using: .monthDay))");
            #XZLog("\(XZDateFormat.shortMonthDay) => \(date.formatted(using: .shortMonthDay))");
            
            #XZLog("\(XZDateFormat.time) => \(date.formatted(using: .time))");
            #XZLog("\(XZDateFormat.shortTime) => \(date.formatted(using: .shortTime))");
            
            #XZLog("\(XZDateFormat.hourMinute) => \(date.formatted(using: .hourMinute))");
            #XZLog("\(XZDateFormat.shortHourMinute) => \(date.formatted(using: .shortHourMinute))");
            
            showToast("请查看控制台");
        default:
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }

}
