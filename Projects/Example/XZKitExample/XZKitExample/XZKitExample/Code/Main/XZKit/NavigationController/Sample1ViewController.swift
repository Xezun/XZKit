//
//  Sample1ViewController.swift
//  Example
//
//  Created by Xu Zhen on 2018/11/16.
//  Copyright © 2018 mlibai. All rights reserved.
//

import UIKit
import XZKit

/// 自定义导航测试。
class Sample1ViewController: UIViewController, UICollectionViewDataSource, NavigationGestureDrivable, NavigationBarCustomizable {
    
    func navigationController(_ navigationController: UINavigationController, edgesInsetsForGestureNavigation operation: UINavigationController.Operation) -> UIEdgeInsets? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "XZKit"
        
        self.view.clipsToBounds = false
        
        view.backgroundColor = UIColor.white
        self.navigationBar.backgroundImage  = UIImage(named: "bg_nav")
        
        let count = self.navigationController!.viewControllers.count
        self.navigationBar.backButton?.isHidden = (count <= 1)
        self.navigationBar.backButton?.setTitle("返回", for: .normal)
        
        self.navigationBar.title = "View Controller \(count)"
        self.navigationBar.infoButton?.setTitle("菜单", for: .normal)
        self.navigationBar.infoButton?.setTitle("高亮菜单", for: .highlighted)
        self.navigationBar.infoButton?.setTitle("已选中菜单", for: .selected)
        self.navigationBar.infoButton?.addTarget(self, action: #selector(infoButtonAction(_:)), for: .touchUpInside)
        
        self.navigationBarHiddenSwitch.isOn = self.navigationBar.isHidden
        self.statusBarHiddenSwitch.isOn = self.isStatusBarHidden
        
        print("\(self) \(#function)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("\(self) \(#function)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("\(self) \(#function)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("\(self) \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("\(self) \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("\(self) \(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("\(self) \(#function)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    @IBOutlet weak var animtedSwitch: UISwitch!
    
    @IBAction func navigationBarHiddenChanged(_ sender: UISwitch) {
        navigationController!.setNavigationBarHidden(sender.isOn, animated: animtedSwitch.isOn)
    }
    
    @IBAction func statusBarHiddenChanged(_ sender: UISwitch) {
        isStatusBarHidden = sender.isOn
        setNeedsStatusBarAppearanceUpdate();
    }
    
    var isStatusBarHidden = false;
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    @IBOutlet weak var navigationBarHiddenSwitch: UISwitch!
    
    @IBOutlet weak var statusBarHiddenSwitch: UISwitch!
    
    @IBAction func pushButtonAction(_ sender: Any) {
        let nextVC = self.viewControllerForPushGestureNavigation(self.navigationController!)!
        self.navigationController!.pushViewController(nextVC, animated: true);
    }
    
    @IBAction func popButtonAction(_ sender: Any) {
        self.navigationController!.popViewController(animated: animtedSwitch.isOn)
    }
    
    @IBOutlet weak var nextNavigationBarHiddenSwitch: UISwitch!
    @IBOutlet weak var nextNavigationBarTranslucentSwitch: UISwitch!
    @IBOutlet weak var nextStatusBarHiddenSwitch: UISwitch!
    @IBOutlet weak var nextTabBarHiddenSwitch: UISwitch!
    @IBOutlet weak var nextNavigationBarLargeTitlesSwitch: UISwitch!
    
    
    @objc func infoButtonAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
    }
    
    @objc func printButtonAction(_ button: UIButton) {
        print("Status Bar: \(UIApplication.shared.statusBarFrame)");
        print("Naviga Bar: \(self.navigationController!.navigationBar.frame)")
        print("View: \(self.view.frame)")
    }
    
    func viewControllerForPushGestureNavigation(_ navigationController: UINavigationController) -> UIViewController? {
        let nextVC = Sample1ViewController();
        nextVC.navigationBar.isHidden       = nextNavigationBarHiddenSwitch.isOn
        nextVC.navigationBar.isTranslucent  = nextNavigationBarTranslucentSwitch.isOn
        nextVC.hidesBottomBarWhenPushed     = nextTabBarHiddenSwitch.isOn
        nextVC.isStatusBarHidden            = nextStatusBarHiddenSwitch.isOn
        nextVC.navigationBar.prefersLargeTitles = nextNavigationBarLargeTitlesSwitch.isOn
        return nextVC
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.init(arc4random())
        return cell
    }
}

extension Sample1ViewController: ImageCarouselViewDelegate {
    
    func numberOfItems(in carouselView: CarouselView) -> Int {
        return 10
    }
    
    func imageCarouselView(_ imageCarouselView: ImageCarouselView, loadImageFor imageView: UIImageView, forItemAt index: Int, completion: @escaping (CGSize, Bool) -> Void) {
        imageView.image = UIImage.init(named: "img_news")
        completion(imageCarouselView.bounds.size, false)
    }
    
}
