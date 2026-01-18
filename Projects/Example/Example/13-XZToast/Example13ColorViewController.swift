//
//  Example13ColorViewController.swift
//  Example
//
//  Created by 徐臻 on 2026/1/18.
//

import UIKit

class Example13ColorViewController: UIViewController {
    
    var identifier: String?
    var color = UIColor.white
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var red: CGFloat = 0;
        var green: CGFloat = 0;
        var blue: CGFloat = 0;
        color.getRed(&red, green: &green, blue: &blue, alpha: nil);
        self.redSlider.value = Float(red * 255);
        self.greenSlider.value = Float(green * 255);
        self.blueSlider.value = Float(blue * 255);
    }
    
    @IBAction func colorValueChanged(_ sender: UISlider) {
        let red = CGFloat(redSlider.value) / 255.0;
        let green = CGFloat(greenSlider.value) / 255.0;
        let blue = CGFloat(blueSlider.value) / 255.0;
        color = UIColor.init(red: red, green: green, blue: blue, alpha: 1.0)
        previewView.backgroundColor = color;
    }

}
