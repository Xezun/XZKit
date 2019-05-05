//
//  ImageColorLevelsViewController.swift
//  Example
//
//  Created by mlibai on 2018/6/27.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit


class ImageColorLevelsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var maxTextField: UITextField!
    @IBOutlet weak var midTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationBar.title = "ColorLevels"
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func applyColorLevels(_ sender: Any) {
        
//        let min = CGFloat(Int.init(cast: self.minTextField.text)) / 255.0
//        let max = CGFloat(Int.init(cast: self.maxTextField.text)) / 255.0
//
//        let mid = CGFloat(Double.init(unwrap(self.midTextField.text, "1.0")) ?? 1.0)
        
        
//        
//        let start = TimeInterval.since1970
//        let image = UIImage.init(named: "img_news")?.filtering(ColorLevels.init(min: min, max: max, mid: mid))
//        let ended = TimeInterval.since1970
//        self.imageView.image = image
//        
//        XZLog("Start: %@\nEnded: %@", start, ended)
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
