//
//  ThemeView.swift
//  XZKit_Example
//
//  Created by mlibai on 2017/12/5.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit
import XZKit


extension UIView {
    

    
}

class ThemeView: UIView {
    
    let textLabel = UILabel.init(frame: .init(x: 0, y: 0, width: 30, height: 30))
    
    let submitButton = UIButton.init(frame: .init(x: 30, y: 30, width: 40, height: 40))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textLabel)
        
        submitButton.setTitle("提交", for: .normal)
        addSubview(submitButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
}

extension ThemeView {

}
