//
//  ViewController.swift
//  ProgressViewExample
//
//  Created by 徐臻 on 2019/3/30.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

class ViewController: UIViewController, DisplayTimerDelegate {

    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var textLabel: UILabel!
    
    let displayTimer = XZKit.DisplayTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.trackWidth = 15.0

        progressView.tintColor = UIColor.orange
        progressView.minimumTrackTintColor = .lightGray
        progressView.maximumTrackTintColor = .red
        
        displayTimer.timeInterval = 0.1
        displayTimer.duration = 5.0
        displayTimer.delegate = self
    }

    @IBAction func sliderValueChangedAction(_ sender: UISlider) {
        progressView.progress = CGFloat(sender.value)
        textLabel.text = String(format: "%.2f", sender.value)
    }
    
    @IBAction func lineAngleSliderAction(_ sender: UISlider) {
        let angle = CGFloat.pi * CGFloat(sender.value / 180.0)
        progressView.style = .line(angle: angle)
        textLabel.text = String(format: "%.2f°", sender.value)
    }
    
    @IBAction func circleClockwiseSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            progressView.style = .clockwiseCircle
        } else {
            progressView.style = .anticlockwiseCircle
        }
    }
    
    @IBAction func lineCapSegmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:  progressView.lineCap = .butt
        case 1:  progressView.lineCap = .round
        default: progressView.lineCap = .square
        }
    }
    
    @IBAction func startTimerButtonAction(_ sender: UIButton) {
        displayTimer.isPaused = !displayTimer.isPaused
        
        if displayTimer.currentTime == 0 {
            progressView.progress = 1.0
        }
    }
    
    func displayTimer(_ displayTimer: DisplayTimer, didTime timeInterval: TimeInterval) {
        textLabel.text = String.init(format: "%.2f", displayTimer.duration - displayTimer.currentTime)
        progressView.setProgress(CGFloat(1.0 - displayTimer.currentTime / displayTimer.duration), animated: true)
    }
    
}

