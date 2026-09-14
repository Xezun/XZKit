//
//  Example13ColorViewController.swift
//  Example
//
//  Created by Xezun on 2026/1/18.
//

import UIKit

class Example13ColorViewController: UIViewController {
    
    var identifier: String?
    var color = UIColor.white
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var alphaSlider: UISlider!
    @IBOutlet weak var alphaLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var red: CGFloat = 0;
        var green: CGFloat = 0;
        var blue: CGFloat = 0;
        var alpha: CGFloat = 0;
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha);
        red = (red * 255.0).rounded();
        green = (green * 255.0).rounded();
        blue = (blue * 255.0).rounded();
        alpha = (alpha * 255.0).rounded();
        
        self.previewView.backgroundColor = color;
        
        self.redSlider.value = Float(red);
        self.redLabel.text = String(format: "%.0f", red);
        
        self.greenSlider.value = Float(green);
        self.greenLabel.text = String(format: "%.0f", green);
        
        self.blueSlider.value = Float(blue)
        self.blueLabel.text = String(format: "%.0f", blue);
        
        self.alphaSlider.value = Float(alpha)
        self.alphaLabel.text = String(format: "%.0f", alpha);
    }
    
    @IBAction func colorValueChanged(_ sender: UISlider) {
        let red = CGFloat(redSlider.value) / 255.0;
        let green = CGFloat(greenSlider.value) / 255.0;
        let blue = CGFloat(blueSlider.value) / 255.0;
        let alpha = CGFloat(alphaSlider.value) / 255.0
        
        color = UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
        previewView.backgroundColor = color;
        
        redLabel.text = String(format: "%.0f", redSlider.value);
        greenLabel.text = String(format: "%.0f", greenSlider.value);
        blueLabel.text = String(format: "%.0f", blueSlider.value);
        alphaLabel.text = String(format: "%.0f", alphaSlider.value);
    }

}
