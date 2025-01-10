//
//  Example17AppleViewController.swift
//  Example
//
//  Created by 徐臻 on 2024/6/21.
//

import UIKit
import XZNavigationController

class Example17AppleViewController: UITableViewController {
    
    @IBOutlet weak var hiddenSwitch: UISwitch!
    @IBOutlet weak var translucentSwitch: UISwitch!
    @IBOutlet weak var prefersLargeTitlesSwitch: UISwitch!
    @IBOutlet weak var customavigationTranstionSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navigationController = navigationController {
            hiddenSwitch.isOn = navigationController.isNavigationBarHidden
            translucentSwitch.isOn = navigationController.navigationBar.isTranslucent
            prefersLargeTitlesSwitch.isOn = navigationController.navigationBar.prefersLargeTitles
        }
        customavigationTranstionSwitch.isOn = navigationController?.delegate?.isEqual(self) == true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.delegate = nil;
    }
    
    @IBAction func unwindToBack(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func navigationBarHiddenChanged(_ sender: UISwitch) {
        navigationController?.setNavigationBarHidden(sender.isOn, animated: true)
    }

    @IBAction func navigationBarTranslucentChanged(_ sender: UISwitch) {
        navigationController?.navigationBar.isTranslucent = sender.isOn
    }

    @IBAction func navigationBarPrefersLargeTitlesChanged(_ sender: UISwitch) {
        navigationController?.navigationBar.prefersLargeTitles = sender.isOn
    }

    @IBAction func customNavigationTranstionChanged(_ sender: UISwitch) {
        navigationController?.delegate = sender.isOn ? self : nil
    }
}

extension Example17AppleViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navigationController = navigationController as? XZNavigationController else { return nil }
        return ExampleNativeCustomAnimationController.init(for: navigationController, operation: operation, isInteractive: false)
    }
}

class ExampleNativeCustomAnimationController : XZNavigationControllerAnimationController {
    
    override func commitAnimation(using context: XZNavigationControllerAnimationContext, completion: @escaping () -> Void) {
        switch self.operation {
        case .push:
            // 新页面入场动画：从底部向上运动
            context.to.view.frame = context.to.frame.offsetBy(dx: 0, dy: context.to.frame.height);
            if let toNavigationBar = context.toNavigationBar {
                toNavigationBar.view.frame = toNavigationBar.frame.offsetBy(dx: 0, dy: context.to.frame.height)
            }
            // 阴影跟随新页面
            context.shadow.view.frame = context.shadow.frame.offsetBy(dx: 0, dy: context.to.frame.height)
            // 旧页面保持不动
            context.from.frame = context.from.view.frame;
            // 旧自定义导航条保持不动
            if let fromNavigationBar = context.fromNavigationBar {
                fromNavigationBar.frame = fromNavigationBar.view.frame
            }
            // 原生导航条保持不动
            if let navigationBar = context.navigationBar {
                navigationBar.frame = navigationBar.view.frame
            }
            super.commitAnimation(using: context, completion: completion)
        case .pop:
            super.commitAnimation(using: context, completion: completion)
        default:
            fatalError()
        }
    }
    
}
