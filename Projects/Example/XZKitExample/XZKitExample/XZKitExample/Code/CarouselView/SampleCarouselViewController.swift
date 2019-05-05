//
//  SampleCarouselViewController.swift
//  Example
//
//  Created by mlibai on 2018/3/28.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit

class SampleCarouselViewController: UIViewController, CarouselViewDelegate, NavigationBarCustomizable, CarouselViewDataSource {
    func numberOfViews(in carouselView: CarouselView) -> Int {
        return 0;
    }
    
    
    
    @IBOutlet weak var carouselView: CarouselView!
    
    
    let images: [UIImage] = [
        UIImage(named: "20170704142101")!,
        UIImage(named: "20170704142102")!,
        UIImage(named: "20170704142103")!,
        UIImage(named: "20170704142104")!,
        UIImage(named: "20170704142105")!,
        UIImage(named: "20170704142106")!,
        UIImage(named: "20170704142107")!,
        UIImage(named: "20170704142108")!,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true;
        
        self.navigationBar.isTranslucent = false
//        self.navigationBar.title = "CarouselView"
        
        automaticallyAdjustsScrollViewInsets = false;
        view.backgroundColor = UIColor.white
        
        carouselView.isWrapped     = true;
        carouselView.timeInterval  = 0;
        carouselView.delegate      = self;
        carouselView.dataSource    = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func isWrappedDidChange(_ sender: UISwitch) {
        carouselView.isWrapped = sender.isOn
    }
    
    @IBAction func timeIntervalDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            carouselView.timeInterval -= 1;
            
        case 2:
            carouselView.timeInterval += 1;
            
        default: return
        }
        
        sender.setTitle(String.init(carouselView.timeInterval), forSegmentAt: 1)
        sender.selectedSegmentIndex = UISegmentedControl.noSegment
    }
    
    var numberOfViews: Int = 0
    
    @IBAction func numberOfViewsDidChange(_ sender: UISegmentedControl) {
        numberOfViews = sender.selectedSegmentIndex
        carouselView.reloadData()
    }
    
    @IBAction func confirmButtonAction(_ sender: UIButton) {
        carouselView.reloadData()
    }
    
    @IBAction func layoutDirectionAction(_ sender: UISwitch) {
        if sender.isOn {
            carouselView.minimumZoomScale     = 0.1
            carouselView.maximumZoomScale     = 10.0
            carouselView.isZoomingLockEnabled = false
        } else {
            carouselView.minimumZoomScale     = 1.0
            carouselView.maximumZoomScale     = 1.0
            carouselView.isZoomingLockEnabled = true
        }
    }
    
    func numberOfItems(in carouselView: CarouselView) -> Int {
        return numberOfViews
    }
    
    func carouselView(_ carouselView: CarouselView, viewFor index: Int, reusing reusingView: UIView?) -> UIView {
        if let imageView = reusingView as? CarouselViewTestView {
            imageView.image = images[index];
            imageView.frame = carouselView.bounds
            imageView.textLabel.text = String(index)
            return imageView;
        } else {
            let imageView = CarouselViewTestView.init(image: images[index])
            imageView.frame = carouselView.bounds
            imageView.textLabel.text = String(index)
            return imageView;
        }
        // 测试双击放大后，内容视图依然小于容器视图时的表现。
        // view.frame = CGRect.init(x: 0, y: 0, width: 10, height: 10)
        // 显示图片实际大小。
    }
    
    func carouselView(_ carouselView: CarouselView, didShowViewAt index: Int) {
        
    }
    
}

class CarouselViewTestView: UIImageView {
    let textLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        textLabel.textAlignment = .center
        textLabel.font = UIFont.boldSystemFont(ofSize: 72.0)
        textLabel.frame = self.bounds
        textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textLabel.textColor = .red
        textLabel.shadowColor = .white
        addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
