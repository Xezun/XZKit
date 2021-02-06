//
//  Example1Style3ViewController.swift
//  CarouselViewExample
//
//  Created by 徐臻 on 2019/4/28.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

class Example1Style3ViewController: UIViewController, CarouselViewDelegate, CarouselViewDataSource, CarouselViewTransitioningDelegate {
    
    @IBOutlet weak var carouselView: XZKit.CarouselView!
    
    private let ads = [
        " 《春江花月夜》 ",
        " 春江潮水连海平，海上明月共潮生。 ",
        " 滟滟随波千万里，何处春江无月明！ ",
        " 江流宛转绕芳甸，月照花林皆似霰； ",
        " 空里流霜不觉飞，汀上白沙看不见。 ",
        " 江天一色无纤尘，皎皎空中孤月轮。 ",
        " 江畔何人初见月？江月何年初照人？ ",
        " 人生代代无穷已，江月年年望相似。 ",
        " 不知江月待何人，但见长江送流水。 ",
        " 白云一片去悠悠，青枫浦上不胜愁。 ",
        " 谁家今夜扁舟子？何处相思明月楼？ ",
        " 可怜楼上月徘徊，应照离人妆镜台。 ",
        " 玉户帘中卷不去，捣衣砧上拂还来。 ",
        " 此时相望不相闻，愿逐月华流照君。 ",
        " 鸿雁长飞光不度，鱼龙潜跃水成文。 ",
        " 昨夜闲潭梦落花，可怜春半不还家。 ",
        " 江水流春去欲尽，江潭落月复西斜。 ",
        " 斜月沉沉藏海雾，碣石潇湘无限路。 ",
        " 不知乘月几人归，落月摇情满江树。 "
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carouselView.backgroundColor = .white
        carouselView.orientation = .vertical
        carouselView.timeInterval = 3.0
        carouselView.contentMode = .scaleToFill
        
        ///////////////
        carouselView.backgroundColor = .red
        
        carouselView.delegate = self
        carouselView.dataSource = self
        carouselView.transitioningDelegate = self
        
        carouselView.reloadData()
    }
    
    func numberOfViews(in carouselView: CarouselView) -> Int {
        return ads.count
    }
    
    func carouselView(_ carouselView: CarouselView, viewFor index: Int, reusing reusingView: UIView?) -> UIView {
        if let label = reusingView as? UILabel {
            label.text = ads[index]
            return label
        }
        let label = UILabel.init()
        label.textColor = .darkText
        label.font = .systemFont(ofSize: 18.0)
        label.text = ads[index]
        label.backgroundColor = .init(white: 0.95, alpha: 1.0)
        return label
    }
    
    func carouselView(_ carouselView: CarouselView, didTransition transition: CGFloat, animated: Bool) {
        print("didTransition: \(carouselView.currentIndex) -> \(transition)")
    }
    
    func carouselView(_ carouselView: CarouselView, animateTransition isInteractive: Bool) {
        let height = carouselView.frame.height * 0.5
        
        let transformAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform))
        let anchorPointAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.anchorPoint))
        
        var perspectiveTransform3D = CATransform3DIdentity
        perspectiveTransform3D.m34 = 1.0 / 500
        
        transformAnimation.values = [
            CATransform3DRotate(CATransform3DTranslate(perspectiveTransform3D, 0, +height, 0), -CGFloat.pi * 0.5, 1, 0, 0),
            CATransform3DMakeTranslation(0, +height, 0)
        ]
        transformAnimation.duration = 1.0
        transformAnimation.beginTime = 6.0
        carouselView.backwardTransitioningView.layer.add(transformAnimation, forKey: "transform")
        
        anchorPointAnimation.values = [CGPoint(x: 0.5, y: 1.0), CGPoint(x: 0.5, y: 1.0)]
        anchorPointAnimation.duration = 1.0
        anchorPointAnimation.beginTime = 6.0
        carouselView.backwardTransitioningView.layer.add(anchorPointAnimation, forKey: "anchorPoint")
        
        transformAnimation.values = [
            CATransform3DMakeTranslation(0, +height, 0), CATransform3DRotate(CATransform3DTranslate(perspectiveTransform3D, 0, +height, 0), CGFloat.pi * -0.5, 1, 0, 0),
            CATransform3DMakeTranslation(0, -height, 0), CATransform3DRotate(CATransform3DTranslate(perspectiveTransform3D, 0, -height, 0), CGFloat.pi * +0.5, 1, 0, 0)
        ]
        transformAnimation.duration = 3.0
        transformAnimation.beginTime = 0.0
        carouselView.transitioningView.layer.add(transformAnimation, forKey: "transform")
        
        anchorPointAnimation.values = [
            CGPoint(x: 0.5, y: 1.0), CGPoint(x: 0.5, y: 1.0),
            CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.5, y: 0.0)
        ]
        anchorPointAnimation.duration = 3.0
        anchorPointAnimation.beginTime = 0.0
        carouselView.transitioningView.layer.add(anchorPointAnimation, forKey: "anchorPoint")
        
        transformAnimation.values = [
            CATransform3DRotate(CATransform3DTranslate(perspectiveTransform3D, 0, -height, 0), +CGFloat.pi * 0.5, 1, 0, 0),
            CATransform3DMakeTranslation(0, -height, 0)
        ]
        transformAnimation.duration = 1.0
        transformAnimation.beginTime = 4.0
        carouselView.forwardTransitioningView.layer.add(transformAnimation, forKey: "transform")
        
        anchorPointAnimation.values = [CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.5, y: 0.0)]
        anchorPointAnimation.beginTime = 4.0
        anchorPointAnimation.duration = 1.0
        carouselView.forwardTransitioningView.layer.add(anchorPointAnimation, forKey: "anchorPoint")
    }
    
    func carouselView(_ carouselView: CarouselView, animationEnded transitionCompleted: Bool) {
        carouselView.backwardTransitioningView.layer.removeAllAnimations()
        carouselView.transitioningView.layer.removeAllAnimations()
        carouselView.forwardTransitioningView.layer.removeAllAnimations()
    }
    
}
