 //
//  AdvertisementViewController.swift
//  XZKit
//
//  Created by mlibai on 2017/8/8.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit
import XZKit


open class LaunchViewController: UIViewController {
    
    unowned let rootViewController: UIViewController
    
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
        addChild(rootViewController)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var advertisementView: AdvertisementView = AdvertisementView()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        advertisementView.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 127, right: 0)
        advertisementView.frame = view.bounds
        advertisementView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(advertisementView)
        
        advertisementView.timerButton.addTarget(self, action: #selector(timerButtonWasTimeout(_:)), for: [.touchUpInside, .timeout])
        advertisementView.advertisementImageView.image = #imageLiteral(resourceName: "20170704142100")
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        advertisementView.timerButton.timekeeper.duration = 10
        advertisementView.timerButton.timekeeper.resume()
    }
    
    @objc private func timerButtonWasTimeout(_ timerButton: TimerButton) {
        advertisementWasTimeout()
    }
    
    open func advertisementWasTimeout() {
        let bounds = view.bounds
        
        rootViewController.view.frame = bounds
        rootViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(rootViewController.view, at: 0)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.advertisementView.frame = bounds.offsetBy(dx: 0, dy: -bounds.height)
        }) { (finished) in
            self.advertisementView.isHidden = true
        }
    }
    
    
    
}

extension LaunchViewController {
    
    open override func didRecevieRedirection(_ redirection: Any) -> UIViewController? {
        print(redirection)
        return nil
    }
    
}
