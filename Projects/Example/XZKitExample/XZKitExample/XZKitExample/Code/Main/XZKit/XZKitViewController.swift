//
//  XZKitViewController.swift
//  Example
//
//  Created by mlibai on 2017/12/20.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit
import XZKit

private enum Module: String, CaseIterable {
    case APIManager
    case Theme
    case NavigationController
    case CarouselView
    case ImageCarouselView
    case DataCryptor
    case TitledImageView
    case ContentStatus
    case ImageViewPlaceholder
    case ImageColorLevels
    case CollectionViewFlowLayout
    case AlertController
}

private let kCellID = "Cell"

class XZKitViewController: UITableViewController, NavigationBarCustomizable {
    
    fileprivate let dataSource: [Module] = Module.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.backgroundImage = UIImage(named: "bg_nav")
        self.navigationBar.title = "XZKit"
        self.navigationBar.titleTextColor = UIColor.black
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellID);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath);
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = dataSource[indexPath.row].rawValue;
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nextVC: UIViewController! = nil
        switch dataSource[indexPath.row] {
        case .APIManager:
            nextVC = APIManagerViewController.init(nibName: nil, bundle: nil);
        case .Theme:
            nextVC = SampleThemeViewController.init();
        case .NavigationController:
            nextVC = Sample1ViewController.init();
        case .CarouselView: fallthrough
        case .ImageCarouselView:
            let alertVC = UIAlertController.init(title: "XZKit", message: "请查看项目 “CarouselViewExample” 获取更多示例！", preferredStyle: .alert)
            alertVC.addAction(.init(title: "确定", style: .cancel, handler: { (action) in
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            }));
            self.present(alertVC, animated: true, completion: nil)
            return
        case .DataCryptor:
            nextVC = DataCryptorSampleViewController.init()
        case .TitledImageView:
            nextVC = SampleTitleImageViewController.init(nibName: nil, bundle: nil)
        case .ContentStatus:
            nextVC = SampleContentStatusViewController.init(nibName: nil, bundle: nil)
        case .ImageViewPlaceholder:
            nextVC = SampleImageViewController.init(nibName: nil, bundle: nil)
        case .ImageColorLevels:
            nextVC = ImageColorLevelsViewController()
        case .CollectionViewFlowLayout:
            nextVC = FlowLayoutCollectionViewController.init()
        case .AlertController:
            nextVC = AlertViewController.init()
        }
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(nextVC, animated: true)
    }

}
