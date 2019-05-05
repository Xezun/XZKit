//
//  SampleThemeViewController.swift
//  Example
//
//  Created by mlibai on 2018/4/10.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit

class SampleThemeViewController: UIViewController, NavigationBarCustomizable {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let themeSegmentControl = UISegmentedControl.init(items: ["Day", "Night"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationBar.isTranslucent = false
        navigationBar.titleView = themeSegmentControl
        navigationBar.tintColor = .white
        navigationBar.barTintColor = UIColor.darkGray
        navigationBar.backButton!.setTitle("返回", for: .normal)
        
        themeSegmentControl.frame = CGRect.init(x: 0, y: 0, width: 160, height: 30)
        
        themeSegmentControl.addTarget(self, action: #selector(themeSegmentControlValueChanged(_:)), for: .valueChanged)

//        switch Theme.current {
//        case .day:   themeSegmentControl.selectedSegmentIndex = 0
//        case .night: themeSegmentControl.selectedSegmentIndex = 1
//        default:     themeSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func themeSegmentControlValueChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0: Theme.day.apply()
//        case 1: Theme.night.apply()
//        default: break
//        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
