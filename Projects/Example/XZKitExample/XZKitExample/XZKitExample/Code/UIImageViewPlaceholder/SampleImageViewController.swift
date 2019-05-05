//
//  SampleImageViewController.swift
//  Example
//
//  Created by mlibai on 2018/4/12.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

class SampleImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationBar.title = "placeholder"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sliderValueChangedAction(_ sender: UISlider) {
        imageView.brightness = CGFloat(sender.value)
    }
    
    @IBAction func setPlaceholder(_ sender: Any) {
        if imageView.placeholder == nil {
            imageView.placeholder = #imageLiteral(resourceName: "img_empty")
        } else {
            imageView.placeholder = nil
        }
    }
    
    @IBAction func setImage(_ sender: Any) {
        if imageView.image == nil {
            imageView.image = #imageLiteral(resourceName: "img_news")
        } else {
            imageView.image = nil
        }
    }

}
