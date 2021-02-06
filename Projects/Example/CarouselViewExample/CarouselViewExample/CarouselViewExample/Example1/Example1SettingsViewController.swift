//
//  Example1SettingsViewController.swift
//  CarouselViewExample
//
//  Created by 徐臻 on 2019/4/28.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

extension UIView.ContentMode: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .scaleToFill:      return "scaleToFill"
        case .scaleAspectFit:   return "scaleAspectFit"
        case .scaleAspectFill:  return "scaleAspectFill"
        case .redraw:           return "redraw"
        case .center:           return "center"
        case .top:              return "top"
        case .bottom:           return "bottom"
        case .left:             return "left"
        case .right:            return "right"
        case .topLeft:          return "topLeft"
        case .topRight:         return "topRight"
        case .bottomLeft:       return "bottomLeft"
        case .bottomRight:      return "bottomRight"
        default:                return "unknown"
        }
    }
    
}

protocol Example1SettingsViewControllerDelegate: AnyObject {
    func example1SettingsViewController(_ viewController: Example1SettingsViewController, didChangeTransitionEffectOption isOn: Bool)
}

class Example1SettingsViewController: UITableViewController, Example1SettingsContentModeOptionsViewControllerDelegate {
    
    weak var delegate: Example1SettingsViewControllerDelegate?
    weak var carouselView: CarouselView!
    
    @IBOutlet weak var contentModeLabel: UILabel!
    @IBOutlet weak var autoScrollSwitch: UISwitch!
    @IBOutlet weak var wrappedSwitch: UISwitch!
    @IBOutlet weak var zoomingStateSwitch: UISwitch!
    @IBOutlet weak var zoomingLockSwitch: UISwitch!
    @IBOutlet weak var zoomableSwitch: UISwitch!
    @IBOutlet weak var orientationSwitch: UISwitch!
    @IBOutlet weak var transitionSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentModeLabel.text   = carouselView.contentMode.description
        self.autoScrollSwitch.isOn   = carouselView.timeInterval > 0
        self.wrappedSwitch.isOn      = carouselView.isWrapped
        self.zoomingStateSwitch.isOn = carouselView.remembersZoomingState
        self.zoomingLockSwitch.isOn  = carouselView.isZoomingLockEnabled
        self.zoomableSwitch.isOn     = carouselView.minimumZoomScale < carouselView.maximumZoomScale
        self.orientationSwitch.isOn  = carouselView.orientation == .horizontal
        self.transitionSwitch.isOn   = carouselView.transitioningDelegate != nil
    }
    
    func contentModeOptionsViewController(_ viewController: Example1SettingsContentModeOptionsViewController, didSelect contentMode: UIView.ContentMode) {
        carouselView.contentMode = contentMode
        contentModeLabel.text = contentMode.description
    }
    
    @IBAction func autoScrollSwitchAction(_ sender: UISwitch) {
        carouselView.timeInterval = sender.isOn ? 2.0 : 0
    }
    
    @IBAction func wrappedSwitchAction(_ sender: UISwitch) {
        carouselView.isWrapped = sender.isOn
    }
    
    @IBAction func zoomingStateSwitchAction(_ sender: UISwitch) {
        carouselView.remembersZoomingState = sender.isOn
    }
    
    @IBAction func zoomingLockSwitchAction(_ sender: UISwitch) {
        carouselView.isZoomingLockEnabled = sender.isOn
    }
    
    @IBAction func zoomableSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            carouselView.setMinimumZoomScale(0.2, maximumZoomScale: 5.0);
        } else {
            carouselView.setMinimumZoomScale(1.0, maximumZoomScale: 1.0);
        }
    }
    
    @IBAction func orientationSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            carouselView.orientation = .horizontal
        } else {
            carouselView.orientation = .vertical
        }
    }
    
    @IBAction func transitionSwitchAction(_ sender: UISwitch) {
        delegate?.example1SettingsViewController(self, didChangeTransitionEffectOption: sender.isOn)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? Example1SettingsContentModeOptionsViewController else { return }
        nextVC.contentMode = carouselView.contentMode
        nextVC.delegate = self
    }
    
}
