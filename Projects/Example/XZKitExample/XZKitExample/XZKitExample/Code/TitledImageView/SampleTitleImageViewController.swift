//
//  SampleTitleImageViewController.swift
//  Example
//
//  Created by mlibai on 2018/4/2.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit

class SampleTitleImageViewController: UIViewController {
    
    @IBOutlet weak var titledImageView: TextImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationBar.title = "TitledImageView"
        
        titledImageView.textLayoutEdge = .leading
        titledImageView.image = UIImage(named: "icon_player_loading", blending: .blue)
        titledImageView.text = "用户中心"
        titledImageView.textInsets = EdgeInsets.init(top: 0, leading: 5, bottom: 0, trailing: -5)
        titledImageView.textLabel.backgroundColor = UIColor.orange
        titledImageView.imageView.backgroundColor = UIColor.lightGray
        
        let menuBarItemView3 = TextImageControl.init(frame: CGRect.init(x: 20, y: 100, width: 93, height: 42))
        menuBarItemView3.backgroundColor = UIColor.lightText
        menuBarItemView3.setText("Expired", for: .normal)
        menuBarItemView3.setTextColor(UIColor.black, for: .normal)
        menuBarItemView3.setTextColor(UIColor.green, for: .highlighted)
        menuBarItemView3.setTextColor(UIColor.red, for: .selected)
        menuBarItemView3.setTextColor(UIColor.orange, for: [.selected, .highlighted])
        menuBarItemView3.textLabel.font = UIFont.systemFont(ofSize: 17.0)
        view.addSubview(menuBarItemView3)
        
        menuBarItemView3.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }
    
    @objc func buttonAction(_ button: TextImageControl) {
        button.isSelected = !button.isSelected
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
