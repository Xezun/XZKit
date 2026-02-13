//
//  Example17OnlyViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/19.
//

import UIKit
import XZKit

/// 手势页
class Example17OnlyViewController: Example17ViewController, XZNavigationGestureDrivable {
    
    var nextPage = Example17Page.DING_ZHI
    weak var backViewController: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
            backViewController = viewControllers[viewControllers.count - 2]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        switch indexPath.section {
        case 4:
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = nextPage.name
            } else {
                cell.detailTextLabel?.text = backViewController?.navigationItem.title ?? "无"
            }
        default:
            break;
        }
        return cell
    }
    
    func navigationController(_ navigationController: UINavigationController, viewControllerForGestureNavigation operation: UINavigationController.Operation) -> UIViewController? {
        switch operation {
        case .none:
            return nil
        case .push:
            let viewController = nextPage.viewController
            viewController.currentAppearance = nextAppearance
            return viewController
        case .pop:
            return backViewController
        @unknown default:
            fatalError("异常导航分支")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let selectVC = segue.destination as? Example17SelectNextViewController {
            selectVC.selectedPage = nextPage
        } else if let selectVC = segue.destination as? Example17SelectBackViewController {
            selectVC.selectedViewController = backViewController
        }
    }
    
    @IBAction func confirmSelectNextPage(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! Example17SelectNextViewController
        nextPage = sourceViewController.selectedPage
        
        let indexPath = IndexPath.init(row: 0, section: 4)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.detailTextLabel?.text = nextPage.name
    }
    
    @IBAction func confirmSelectBackViewController(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! Example17SelectBackViewController
        backViewController = sourceViewController.selectedViewController
        
        let indexPath = IndexPath.init(row: 1, section: 4)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.detailTextLabel?.text = backViewController?.navigationItem.title ?? "无"
    }

}
