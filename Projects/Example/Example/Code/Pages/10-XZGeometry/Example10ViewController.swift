//
//  Example10ViewController.swift
//  Example
//
//  Created by Xezun on 2025/1/5.
//

import UIKit
import XZKit

class Example10ViewController: UITableViewController {
    
    var mode: UIView.ContentMode = .scaleToFill

    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var methodSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerSizeLabel: UILabel!
    @IBOutlet weak var containerWidthSlider: UISlider!
    @IBOutlet weak var containerWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentSize1Label: UILabel!
    @IBOutlet weak var contentSize2Label: UILabel!
    @IBOutlet weak var contentWidthSlider: UISlider!
    @IBOutlet weak var contentHeightSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.backgroundColor = nil;
        containerView.layer.borderColor = UIColor.red.cgColor;
        containerView.layer.borderWidth = 2.0;
        containerSizeLabel.font = UIFont.monospacedSystemFont(ofSize: 15.0, weight: .regular)
        
        contentView.backgroundColor = nil;
        contentView.layer.borderColor = UIColor.green.cgColor;
        contentView.layer.borderWidth = 4.0;
        contentSize1Label.font = UIFont.monospacedSystemFont(ofSize: 15.0, weight: .regular)
        contentSize2Label.font = UIFont.monospacedSystemFont(ofSize: 15.0, weight: .regular)
        
        self.sliderValueChanged()
    }
    
    @IBAction func sliderValueChanged() {
        self.modeLabel.text = ".\(self.mode)"
        
        let containerWidth  = CGFloat(300.0 * containerWidthSlider.value)
        let containerHeight = containerView.frame.size.height;
        let containerBounds = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        self.containerSizeLabel.text = String(format: "(%.2f, %.2f)", containerWidth, containerHeight)
        
        self.containerWidthConstraint.constant  = containerWidth
        
        let contentWidth  = 150.0 * CGFloat(contentWidthSlider.value);
        let contentHeight = 150.0 * CGFloat(contentHeightSlider.value)
        
        let contentSize = CGSize(width: contentWidth, height: contentHeight);
        self.contentSize1Label.text = String(format: "(%.2f, %.2f)", contentWidth, contentHeight)
        let contentFrame = self.contentFrame(bounds: containerBounds, size: contentSize)
        self.contentSize2Label.text = String(format: "(%.2f, %.2f)", contentFrame.width, contentFrame.height)
        
        self.contentView.frame = contentFrame
    }
    
    private func contentFrame(bounds: CGRect, size: CGSize) -> CGRect {
        switch methodSegmentedControl.selectedSegmentIndex {
        case 0:
            return bounds.adjusting(size, with: self.mode);
        case 1:
            return CGRect.init(aspect: size, inside: bounds, with: self.mode)
        default:
            return CGRect.init(ratio: size, inside: bounds, with: self.mode)
        }
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


