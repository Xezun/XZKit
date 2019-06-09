//
//  Example3ViewController.swift
//  XZCarouselViewExample
//
//  Created by 徐臻 on 2019/3/12.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit


class Example3ViewController: UIViewController {
    
    deinit {
        print("Example3ViewController: \(#function)")
    }
    
    fileprivate class Model {
        let index: Int
        let title: String
        let url: URL
        lazy private(set) var titleWidth: CGFloat = {
            return (title as NSString).boundingRect(with: CGSize.init(width: 1000, height: 40), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], context: nil).width + 10
        }()
        
        init(_ index: Int, _ title: String, _ imageURL: URL) {
            self.index = index
            self.title = title
            self.url = imageURL
        }
    }
    
    fileprivate let pages: [Model] = [
        Model(0, "最新", URL(string: "https://m.ithome.com/")!),
        Model(1, "排行榜", URL(string: "https://m.ithome.com/rankm/")!),
        Model(2, "精读", URL(string: "https://m.ithome.com/jingdum/")!),
        Model(3, "原创", URL(string: "https://m.ithome.com/originalm/")!),
        Model(4, "上热评", URL(string: "https://m.ithome.com/hotcommentm/")!),
        Model(5, "评测室", URL(string: "https://m.ithome.com/labsm/")!),
        Model(6, "发布会", URL(string: "https://m.ithome.com/livem/")!),
        Model(7, "专题", URL(string: "https://m.ithome.com/specialm/")!),
        Model(8, "阳台", URL(string: "https://m.ithome.com/balconym/")!),
        Model(9, "手机", URL(string: "https://m.ithome.com/phonem/")!),
        Model(10, "数码", URL(string: "https://m.ithome.com/digim/")!),
        Model(11, "极客学院", URL(string: "https://m.ithome.com/geekm/")!),
        Model(12, "VR", URL(string: "https://m.ithome.com/vrm/")!),
        Model(13, "智能汽车", URL(string: "https://m.ithome.com/autom/")!),
        Model(14, "电脑", URL(string: "https://m.ithome.com/pcm/")!),
        Model(15, "京东精选", URL(string: "https://m.ithome.com/jdm/")!),
        Model(16, "安卓", URL(string: "https://m.ithome.com/androidm/")!),
        Model(17, "苹果", URL(string: "https://m.ithome.com/iosm/")!),
        Model(18, "网络焦点", URL(string: "https://m.ithome.com/internetm/")!),
        Model(19, "行业前沿", URL(string: "https://m.ithome.com/itm/")!),
        Model(20, "游戏电竞", URL(string: "https://m.ithome.com/gamem/")!),
        Model(21, "Windows", URL(string: "https://m.ithome.com/windowsm/")!),
        Model(22, "科普", URL(string: "https://m.ithome.com/discoverym/")!)
    ]

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    let indicatorView = UIView.init(frame: .zero)
    
    let carouselViewController = CarouselViewController.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "返回", style: .plain, target: nil, action: nil)
        
        indicatorView.backgroundColor = UIColor(red: 0xC1 / 255.0, green: 0x06 / 255.0, blue: 0x19 / 255.0, alpha: 1.0)
        indicatorView.layer.cornerRadius  = 1.5
        indicatorView.layer.masksToBounds = true
        collectionView.addSubview(indicatorView)
        
        carouselViewController.carouselView.transitionViewHierarchy = .navigation
        
        addChild(carouselViewController)
        carouselViewController.view.backgroundColor = .white
        carouselViewController.view.frame = containerView.bounds
        carouselViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(carouselViewController.view)
        carouselViewController.didMove(toParent: self)
        
        carouselViewController.delegate = self
        carouselViewController.dataSource = self
        
        // 因为 UICollectionView 刷新页面是异步的，所以要在菜单显示后才能设置菜单的指示器位置。
        collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        }, completion: { (_) in
            self.carouselViewController.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Example3ViewController: \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Example3ViewController: \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Example3ViewController: \(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Example3ViewController: \(#function)")
    }

    @IBAction func transitionAnimationSwitchAction(_ sender: UISwitch) {
        if sender.isOn && carouselViewController.carouselView.transitioningDelegate == nil {
            carouselViewController.carouselView.transitioningDelegate = self
            let alertVC = UIAlertController(title: "XZKit", message: "转场 Push/Pop 特效已开启！", preferredStyle: .alert)
            alertVC.addAction(.init(title: "知道了", style: .cancel, handler: nil))
            present(alertVC, animated: true, completion: nil)
        } else if carouselViewController.carouselView.transitioningDelegate != nil {
            carouselViewController.carouselView.transitioningDelegate = nil
        }
    }
    
    private var menuIndex: Int = CarouselView.notFound
    
    // 不能重用的控制器
    private var indexedViewControllers = [Int: Example3WebViewController]()
    // 自定义的重用机制：重用池。
    private var reusableViewControllers = [Example3WebViewController]()
    
}

extension Example3ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Example3MenuCell
        cell.textLabel.text = pages[indexPath.item].title
        cell.transition = (menuIndex == indexPath.item ? 1.0 : 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: pages[indexPath.item].titleWidth, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        carouselViewController.setCurrentIndex(indexPath.item, animated: true)
    }
    
}

extension Example3ViewController: CarouselViewControllerDataSource {
    
    func numberOfViewControllers(in carouselViewController: CarouselViewController) -> Int {
        return pages.count
    }
    
    func carouselViewController(_ carouselViewController: CarouselViewController, viewControllerFor index: Int, reusing reusingViewController: UIViewController?) -> UIViewController {
        // 自定义重用机制。假定前 5 个栏目是专栏，使用独立的控制器，其它栏目使用相同控制器。
        if index < 5 {
            if let viewController = indexedViewControllers[index] {
                return viewController
            }
            print("创建不可重用控制器：\(index)")
            let webViewController = Example3WebViewController.init(index: index)
            webViewController.title = pages[index].title
            webViewController.load(url: pages[index].url)
            indexedViewControllers[index] = webViewController
            return webViewController
        }
        if reusableViewControllers.isEmpty {
            print("创建可重用控制器：\(index)")
            let webViewController = Example3WebViewController.init(index: index)
            webViewController.title = pages[index].title
            webViewController.load(url: pages[index].url)
            return webViewController
        }
        let webViewController = reusableViewControllers.removeLast()
        print("使用可重用控制器：\(webViewController.index) -> \(index)")
        webViewController.title = pages[index].title
        webViewController.load(url: pages[index].url)
        return webViewController
    }
    
    func carouselViewController(_ carouselViewController: CarouselViewController, shouldEnqueue viewController: UIViewController, at index: Int) -> Bool {
        guard index >= 5 else {
            return false
        }
        let viewController = viewController as! Example3WebViewController
        print("回收可重用控制器：\(viewController.index)")
        viewController.prepareForReusing()
        reusableViewControllers.append(viewController)
        return false
    }
    
}

extension Example3ViewController: CarouselViewControllerDelegate {
    
    func carouselViewController(_ carouselViewController: CarouselViewController, didShow viewController: UIViewController, at index: Int) {
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        print("didShowItemAt: \(index)")
    }
    
    func carouselViewController(_ carouselViewController: CarouselViewController, didTransition transition: CGFloat, animated: Bool) {
        let newIndex = carouselViewController.currentIndex
        if menuIndex == newIndex { //
            if transition > 0 { // 滚往下一个。
                menuTranstion(to: menuIndex + 1, transition: transition)
            } else if transition < 0 {
                menuTranstion(to: menuIndex - 1, transition: -transition)
            } else { // 滚动取消
                menuTranstion(to: menuIndex, transition: 0)
                collectionView.reloadData() // 重置上面目标菜单的转场进度。
            }
        } else { // 页面已跳转到新的 index 。
            if (transition == 0) { // 完成跳转
                menuIndex = newIndex
                menuTranstion(to: menuIndex, transition: 0)
                collectionView.reloadData()
            } else { // 跳转中。
                menuTranstion(to: newIndex, transition: 1.0 - abs(transition))
            }
        }
        
        // print("Transition: \(newIndex) \(transition)")
    }
    
    private func menuTranstion(to newIndex: Int, transition: CGFloat) {
        if menuIndex != newIndex, let targetMenuCell = collectionView.cellForItem(at: IndexPath(item: newIndex, section: 0)) as? Example3MenuCell {
            targetMenuCell.transition = transition
            if let currentMenuCell = collectionView.cellForItem(at: IndexPath(item: menuIndex, section: 0)) as? Example3MenuCell {
                currentMenuCell.transition = 1.0 - transition
                
                let p1 = currentMenuCell.center
                let p2 = targetMenuCell.center
                
                if transition < 0.5 {
                    if p1.x < p2.x {
                        let width = (p2.x - p1.x) * transition * 2.0 + 10
                        indicatorView.frame = CGRect(x: p1.x - 5, y: 37, width: width, height: 3.0)
                    } else {
                        let width = (p1.x - p2.x) * transition * 2.0 + 10.0
                        indicatorView.frame = CGRect(x: p1.x + 5.0 - width, y: 37, width: width, height: 3.0)
                    }
                } else {
                    if p1.x < p2.x {
                        let width = (p2.x - p1.x) * (1.0 - transition) * 2.0 + 10.0
                        indicatorView.frame = CGRect(x: p2.x + 5.0 - width, y: 37, width: width, height: 3.0)
                    } else {
                        let width = (p1.x - p2.x) * (1.0 - transition) * 2.0 + 10.0
                        indicatorView.frame = CGRect(x: p2.x - 5.0, y: 37, width: width, height: 3.0)
                    }
                }
            } else {
                let p2 = targetMenuCell.center
                indicatorView.frame = CGRect.init(x: p2.x - 5.0, y: 37, width: 10, height: 3.0)
            }
        } else if let currentMenuCell = collectionView.cellForItem(at: IndexPath(item: menuIndex, section: 0)) as? Example3MenuCell {
            currentMenuCell.transition = 1.0 - transition
            
            let p1 = currentMenuCell.center
            indicatorView.frame = CGRect.init(x: p1.x - 5.0, y: 37, width: 10, height: 3.0)
        } else {
            collectionView.performBatchUpdates({
                self.collectionView.reloadData()
            }, completion: { (_) in
                self.menuTranstion(to: newIndex, transition: 0)
            })
        }
    }
    
}

extension Example3ViewController: CarouselViewTransitioningDelegate {
    
    func carouselView(_ carouselView: CarouselView, beginTransitioning isInteractive: Bool) {
        let width: CGFloat = floor(UIScreen.main.bounds.width / 3.0)
        
        let timingFunction = isInteractive ? nil : CAMediaTimingFunction(name: .easeInEaseOut)
        
        let navigationAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform));
        navigationAnimation.timingFunction = timingFunction
        
        let shadowRadiusAnimation = CAKeyframeAnimation.init(keyPath: #keyPath(CALayer.shadowRadius))
        shadowRadiusAnimation.timingFunction = timingFunction
        
        let shadowOpacityAnimation = CAKeyframeAnimation.init(keyPath: #keyPath(CALayer.shadowOpacity))
        shadowOpacityAnimation.timingFunction = timingFunction
        
        let shadowColorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowColor))
        shadowColorAnimation.timingFunction = timingFunction
        shadowColorAnimation.fromValue = UIColor.black.cgColor
        shadowColorAnimation.toValue   = UIColor.black.cgColor
        
        let shadowOffsetAnimation = CABasicAnimation.init(keyPath: #keyPath(CALayer.shadowOffset))
        shadowOffsetAnimation.timingFunction = timingFunction
        shadowOffsetAnimation.fromValue = NSValue(cgSize: .zero);
        shadowOffsetAnimation.toValue   = NSValue(cgSize: .zero);
        
        // backwardTransitioningView
        navigationAnimation.values = [
            CATransform3DMakeTranslation(+width, 0, 0), CATransform3DIdentity
        ]
        
        navigationAnimation.beginTime = 6.0
        navigationAnimation.duration = 1.0
        carouselView.backwardTransitioningView.layer.add(navigationAnimation, forKey: "transform")
    
        // transitioningView
        navigationAnimation.values = [
            CATransform3DIdentity, CATransform3DMakeTranslation(+width, 0, 0)
        ]
        navigationAnimation.beginTime = 0.0
        navigationAnimation.duration = 1.0
        carouselView.transitioningView.layer.add(navigationAnimation, forKey: "transform1")
        
        navigationAnimation.values = [
            CATransform3DIdentity, CATransform3DIdentity
        ]
        navigationAnimation.beginTime = 2.0
        navigationAnimation.duration = 1.0
        carouselView.transitioningView.layer.add(navigationAnimation, forKey: "transform2")
        
        shadowRadiusAnimation.values = [5.0, 10.0]
        shadowOpacityAnimation.values = [0.5, 0.0]

        shadowRadiusAnimation.beginTime = 2.0
        shadowRadiusAnimation.duration = 1.0
        carouselView.transitioningView.layer.add(shadowRadiusAnimation, forKey: "shadowRadius")
        
        shadowOpacityAnimation.beginTime = 2.0
        shadowOpacityAnimation.duration = 1.0
        carouselView.transitioningView.layer.add(shadowOpacityAnimation, forKey: "shadowOpacity")
        
        shadowColorAnimation.beginTime = 2.0
        shadowColorAnimation.duration = 1.0
        carouselView.transitioningView.layer.add(shadowColorAnimation, forKey: "shadowColor")
        
        shadowOffsetAnimation.beginTime = 2.0
        shadowOffsetAnimation.duration = 1.0
        carouselView.transitioningView.layer.add(shadowOffsetAnimation, forKey: "shadowOffset")
        
        // forwardTransitioningView
        navigationAnimation.values = [
            CATransform3DIdentity, CATransform3DIdentity
        ]
        shadowRadiusAnimation.values = [0.0, 5.0]
        shadowOpacityAnimation.values = [0.0, 0.5]
        
        navigationAnimation.beginTime = 4.0
        navigationAnimation.duration = 1.0
        carouselView.forwardTransitioningView.layer.add(navigationAnimation, forKey: "transform")
        
        shadowRadiusAnimation.beginTime = 4.0
        shadowRadiusAnimation.duration = 1.0
        carouselView.forwardTransitioningView.layer.add(shadowRadiusAnimation, forKey: "shadowRadius")
        
        shadowOpacityAnimation.beginTime = 4.0
        shadowOpacityAnimation.duration = 1.0
        carouselView.forwardTransitioningView.layer.add(shadowOpacityAnimation, forKey: "shadowOpacity")
        
        shadowColorAnimation.beginTime = 4.0
        shadowColorAnimation.duration = 1.0
        carouselView.forwardTransitioningView.layer.add(shadowColorAnimation, forKey: "shadowColor")
        
        shadowOffsetAnimation.beginTime = 4.0
        shadowOffsetAnimation.duration = 1.0
        carouselView.forwardTransitioningView.layer.add(shadowOffsetAnimation, forKey: "shadowOffset")
    }
    
    func carouselView(_ carouselView: CarouselView, endTransitioning transitionCompleted: Bool) {
        carouselView.backwardTransitioningView.layer.removeAllAnimations()
        carouselView.transitioningView.layer.removeAllAnimations()
        carouselView.forwardTransitioningView.layer.removeAllAnimations()
    }
    
}

class Example3MenuCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    
    var transition: CGFloat = 0 {
        didSet {
            textLabel.textColor = UIColor(red: transition * 0xC1 / 255.0, green: transition * 0x06 / 255.0, blue: transition * 0x19 / 255.0, alpha: 1.0)
            let scale = 1.0 + transition * 0.1
            textLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}
