//
//  Example1Style1ViewController.swift
//  Example1Style1ViewController
//
//  Created by 徐臻 on 2019/1/17.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import SDWebImage
import XZKit

class Example1Style1ViewController: UIViewController, Example1SettingsViewControllerDelegate {

    @IBOutlet fileprivate weak var imageCarouselView: ImageCarouselView!
    
    private let pageControl = UIPageControl.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageURLs = [
            URL(string: "http://fengxinju.bj01.bdysite.com/upfiles/201803/30/1962_n2.jpg")!,
            URL(string: "https://img.ithome.com/newsuploadfiles/2019/4/20190410_143544_927.jpg@wm_1,k_aW1nL3FkLnBuZw==,y_20,o_100,x_20,g_7")!,
            URL(string: "http://img0.imgtn.bdimg.com/it/u=1026786338,3550838642&fm=26&gp=0.jpg")!,
            URL(string: "http://img3.imgtn.bdimg.com/it/u=3204637472,3606476471&fm=26&gp=0.jpg")!,
            URL(string: "http://img1.imgtn.bdimg.com/it/u=843829727,2884188284&fm=26&gp=0.jpg")!,
            URL(string: "http://img2.imgtn.bdimg.com/it/u=1696566855,1684736675&fm=26&gp=0.jpg")!,
            URL(string: "http://img4.imgtn.bdimg.com/it/u=260532076,3589298916&fm=26&gp=0.jpg")!,
            URL(string: "http://img5.imgtn.bdimg.com/it/u=2149013970,2898954339&fm=26&gp=0.jpg")!,
            URL(string: "http://img2.imgtn.bdimg.com/it/u=2978796586,3163974224&fm=26&gp=0.jpg")!,
            URL(string: "http://img5.imgtn.bdimg.com/it/u=1649871572,1090852527&fm=26&gp=0.jpg")!,
            URL(string: "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1706227310,1982342322&fm=26&gp=0.jpg")!
        ]
        
        let bounds = imageCarouselView.bounds
        pageControl.frame = CGRect.init(x: bounds.minX, y: bounds.maxY - 50, width: bounds.width, height: 50)
        pageControl.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        pageControl.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        imageCarouselView.addSubview(pageControl)
        
        // 图片地址
        imageCarouselView.imageURLs = imageURLs

        pageControl.addTarget(self, action: #selector(pageControlAction(_:)), for: .valueChanged)
        
        // 事件代理
        imageCarouselView.delegate = self
        imageCarouselView.transitionViewHierarchy = .pageCurl
        
        imageCarouselView.reloadData()
        pageControl.numberOfPages = imageCarouselView.numberOfViews
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func pageControlAction(_ pageControl: UIPageControl) {
        imageCarouselView.setCurrentIndex(pageControl.currentPage, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settingsVC = segue.destination as? Example1SettingsViewController else { return }
        settingsVC.carouselView = self.imageCarouselView
        settingsVC.delegate = self
    }
    
    func example1SettingsViewController(_ viewController: Example1SettingsViewController, didChangeTransitionEffectOption isOn: Bool) {
        imageCarouselView.transitioningDelegate = isOn ? self : nil
    }
    
}


extension Example1Style1ViewController: ImageCarouselViewDelegate {
    
    func imageCarouselView(_ imageCarouselView: ImageCarouselView, imageView: UIImageView, loadImageFrom imageURL: URL, completion: @escaping (CGSize, Bool) -> Void) {
        // 设置占位图的大小。
        imageView.contentMode = .center
        imageView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        // 使用 SDWebImage 加载图片。
        imageView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "avatar"), completed: { (image, _, cacheType, _) in
            if let image = image {
                imageView.contentMode = .scaleToFill
                completion(image.size, false) // 图片加载后，调用回调更新图片的实际大小。
            } else {
                imageView.image = UIImage(named: "error") // 加载错误图片。
                completion(CGSize(width: 120.0, height: 120.0), false)
            }
        })
    }
    
    func carouselView(_ carouselView: CarouselView, didShow currentView: UIView, at currentIndex: Int) {
        let index = carouselView.currentIndex;
        self.pageControl.currentPage = index
    }
    
    public func carouselView(_ carouselView: CarouselView, didEndZooming view: UIView, at index: Int, atScale scale: CGFloat) {
        pageControl.isHidden = scale > 1.0
    }
    
    func carouselView(_ carouselView: CarouselView, didTransition transition: CGFloat, animated: Bool) {
        let index = carouselView.currentIndex;
        self.navigationItem.title = String(format: "%.2f", CGFloat(index) + transition)
        print("didTransition: \(index) -> \(transition)")
    }
    
}

extension Example1Style1ViewController: CarouselViewTransitioningDelegate {
    
    func carouselView(_ carouselView: CarouselView, beginTransitioning isInteractive: Bool) {
        let width = carouselView.frame.width * 0.5
        
        let transformAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform))
        let anchorPointAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.anchorPoint))
        
        var perspectiveTransform3D = CATransform3DIdentity
        perspectiveTransform3D.m34 = -1.0 / 2000;
        
        transformAnimation.values = [
            CATransform3DRotate(CATransform3DTranslate(perspectiveTransform3D, width, 0, 0), -CGFloat.pi * 0.5, 0, 1, 0),
            CATransform3DMakeTranslation(+width, 0, 0)
        ]
        transformAnimation.duration = 1.0
        transformAnimation.beginTime = 6.0
        carouselView.backwardTransitioningView.layer.add(transformAnimation, forKey: "transform")
        
        anchorPointAnimation.values = [CGPoint(x: 1.0, y: 0.5), CGPoint(x: 1.0, y: 0.5)]
        anchorPointAnimation.duration = 1.0
        anchorPointAnimation.beginTime = 6.0
        carouselView.backwardTransitioningView.layer.add(anchorPointAnimation, forKey: "anchorPoint")
        
        transformAnimation.values = [
            CATransform3DMakeTranslation(+width, 0, 0), CATransform3DRotate(CATransform3DTranslate(perspectiveTransform3D, width, 0, 0), CGFloat.pi * -0.5, 0, 1, 0),
            CATransform3DMakeTranslation(-width, 0, 0), CATransform3DRotate(CATransform3DTranslate(perspectiveTransform3D, -width, 0, 0), CGFloat.pi * +0.5, 0, 1, 0)
        ]
        transformAnimation.duration = 3.0
        transformAnimation.beginTime = 0.0
        carouselView.transitioningView.layer.add(transformAnimation, forKey: "transform")
        
        anchorPointAnimation.values = [
            CGPoint(x: 1.0, y: 0.5), CGPoint(x: 1.0, y: 0.5),
            CGPoint(x: 0.0, y: 0.5), CGPoint(x: 0.0, y: 0.5)
        ]
        anchorPointAnimation.duration = 3.0
        anchorPointAnimation.beginTime = 0.0
        carouselView.transitioningView.layer.add(anchorPointAnimation, forKey: "anchorPoint")
        
        transformAnimation.values = [
            CATransform3DRotate(CATransform3DTranslate(perspectiveTransform3D, -width, 0, 0), +CGFloat.pi * 0.5, 0, 1, 0),
            CATransform3DMakeTranslation(-width, 0, 0)
        ]
        transformAnimation.duration = 1.0
        transformAnimation.beginTime = 4.0
        carouselView.forwardTransitioningView.layer.add(transformAnimation, forKey: "transform")
        
        anchorPointAnimation.values = [CGPoint(x: 0.0, y: 0.5), CGPoint(x: 0.0, y: 0.5)]
        anchorPointAnimation.beginTime = 4.0
        anchorPointAnimation.duration = 1.0
        carouselView.forwardTransitioningView.layer.add(anchorPointAnimation, forKey: "anchorPoint")
    }
    
    func carouselView(_ carouselView: CarouselView, endTransitioning transitionCompleted: Bool) {
        carouselView.backwardTransitioningView.layer.removeAllAnimations()
        carouselView.transitioningView.layer.removeAllAnimations()
        carouselView.forwardTransitioningView.layer.removeAllAnimations()
    }
    
}
