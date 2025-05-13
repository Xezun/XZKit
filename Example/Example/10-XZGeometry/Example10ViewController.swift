//
//  Example10ViewController.swift
//  Example
//
//  Created by Xezun on 2025/1/5.
//

import UIKit
import XZJSON

class Example10ViewController: UIViewController {
    
    var mode: UIView.ContentMode = .scaleToFill

    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var insideView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
    
    @IBOutlet weak var containerWidthSlider: UISlider!
    @IBOutlet weak var containerHeightSlider: UISlider!
    @IBOutlet weak var containerSizeLabel: UILabel!
    
    @IBOutlet weak var insiderWidthSlider: UISlider!
    @IBOutlet weak var insiderHeightSlider: UISlider!
    
    @IBOutlet weak var insiderSizeLabel: UILabel!
    @IBOutlet weak var insiderScaleSizeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sliderValueChanged()
    }
    
    @IBAction func sliderValueChanged() {
        self.modeButton.setTitle("\(self.mode)", for: .normal)
        
        let containerWidth  = 150.0 * CGFloat(containerWidthSlider.value);
        let containerHeight = 150.0 * CGFloat(containerHeightSlider.value);
        let containerBounds = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        self.containerSizeLabel.text = String(format: "(%.2f, %.2f)", containerWidth, containerHeight)
        
        self.width.constant  = containerWidth
        self.height.constant = containerHeight
        
        let insiderWidth  = 150.0 * CGFloat(insiderWidthSlider.value);
        let insiderHeight = 150.0 * CGFloat(insiderHeightSlider.value)
        
        let insiderSize = CGSize(width: insiderWidth, height: insiderHeight);
        self.insiderSizeLabel.text = String(format: "(%.2f, %.2f)", insiderWidth, insiderHeight)
        let insideFrame = insiderSize.scalingAspectRatio(inside: containerBounds, contentMode: self.mode);
        self.insiderScaleSizeLabel.text = String(format: "(%.2f, %.2f)", insideFrame.width, insideFrame.height)
        
        if insideFrame.isNull || insideFrame.isInfinite || insideFrame.minX.isNaN || insideFrame.minY.isNaN || insideFrame.width.isNaN || insideFrame.height.isNaN {
            NSLog("\(insideFrame)")
        }
        self.insideView.frame = insideFrame
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        if let selectVC = unwindSegue.source as? Example10SelectViewController {
            self.mode = selectVC.value
            self.sliderValueChanged()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectVC = segue.destination as? Example10SelectViewController {
            selectVC.value = self.mode
        }
    }

}


