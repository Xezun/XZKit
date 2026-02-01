//
//  Example10SelectViewController.swift
//  Example
//
//  Created by 徐臻 on 2025/5/13.
//

import UIKit

enum Foobar {
case foo
    case bar
}

class Example10SelectViewController: UITableViewController {
    
    var value: UIView.ContentMode = .scaleToFill
    
    var contentModes: [(name: String, value: UIView.ContentMode)] = [
        ("scaleToFill", .scaleToFill),
        ("scaleAspectFit", .scaleAspectFit),
        ("scaleAspectFill", .scaleAspectFill),
        ("redraw", .redraw),
        ("center", .center),
        ("left", .left),
        ("right", .right),
        ("top", .top),
        ("bottom", .bottom),
        ("topLeft", .topLeft),
        ("topRight", .topRight),
        ("bottomLeft", .bottomLeft),
        ("bottomRight", .bottomRight),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentModes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let item = contentModes[indexPath.row];
        cell.textLabel?.text = item.name
        cell.accessoryType = value == item.value ? .checkmark : .disclosureIndicator;

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = contentModes[indexPath.row];
        self.value = item.value
        tableView.reloadData()
    }

}
