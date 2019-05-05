//
//  BubbleViewController.swift
//  XZKit
//
//  Created by mlibai on 2017/7/31.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit


class BubbleViewController: UIViewController {
    
    @IBOutlet weak var bubbleTop: BubbleView!
    @IBOutlet weak var bubbleRight: BubbleView!
    @IBOutlet weak var bubbleBottom: BubbleView!
    @IBOutlet weak var bubbleLeft: BubbleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        bubbleTop.pointerPosition       = .top(50)
//        bubbleRight.pointerPosition     = .right(30)
//        bubbleBottom.pointerPosition    = .bottom(30)
//        bubbleLeft.pointerPosition      = .left(30)
        
        bubbleTop.textLabel.text        = "箭头在顶部"
        bubbleRight.textLabel.text      = "箭头在右面"
        bubbleBottom.textLabel.text     = "箭头在底部"
        bubbleLeft.textLabel.text       = "箭头在左面"

    }
    
    @IBAction func sliderValueChangedAction(_ sender: UISlider) {
//        let i = CGFloat(sender.value)
//        if i < 1 {
//            self.bubbleBottom.pointerPosition = .top(200 * i)
//        } else if i < 2 {
//            self.bubbleBottom.pointerPosition = .right(200 * (i - 1))
//        } else if i < 3 {
//            self.bubbleBottom.pointerPosition = .bottom(200 * (1 - i + 2))
//        } else {
//            self.bubbleBottom.pointerPosition = .left(200 * (1 - i + 3))
//        }
        print(sender.value)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        
        bubbleTop.tintColor = .red
//        view.becomeFirstResponder()
//        let menu = UIMenuController.shared
//        let item = UIMenuItem(title: "关注喜欢的内容", action: #selector(menuAction(_:)))
//        menu.menuItems = [item]
//        menu.setTargetRect(sender.frame.offsetBy(dx: 0, dy: -100), in: view)
//        menu.setMenuVisible(true, animated: true)
        
//        let view = BubbleView(frame: CGRect(x: 0, y: 0, width: 180, height: 100))
//        
//        view.textLabel.text = "请关注你喜爱的球队"
//        let rect = sender.bounds.insetBy(dx: 100, dy: 0).offsetBy(dx: 0, dy: -49)
//        view.display(in: rect, for: sender, at: nil)
    }
    

}
