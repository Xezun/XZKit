//
//  TableViewController.swift
//  CarouselViewExample
//
//  Created by Xezun on 2019/4/7.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import SDWebImage
import XZKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cleanImageCachesAction(_ sender: UIBarButtonItem) {
        SDWebImageManager.shared.imageCache.clear(with: .all, completion: {
            let alertVC = UIAlertController(title: "缓存清理成功", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction.init(title: "确定", style: .cancel, handler: { (_) in
                
            }))
            self.present(alertVC, animated: true, completion: nil)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TableViewController: \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("TableViewController: \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("TableViewController: \(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("TableViewController: \(#function)")
    }

}
