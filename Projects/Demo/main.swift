//
//  main.swift
//  Client
//
//  Created by Xezun on 2026/4/13.
//

import Foundation
import UIKit
import XZKit


@mocoa
class FooViewModel: XZMocoaViewModel {
    /// 名称
    @key var name: String?
    
}

@mocoa
class FooView: UIView, XZMocoaView {
    
    // 绑定
    @bind(.name)
    var nameLabel: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 在此方法中初始化子视图，若使用约束布局，也写在此方法中。
    private func setupUI() {
        // 初始化外不使用的
        let wrapperView = UIView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        // config the wrapper view
        self.addSubview(wrapperView)
        
        // config name label here
        wrapperView.addSubview(nameLabel)
        
        // make layout constraints here
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 纯代码布局
    }
    
}

#XZLog("This is a message");

@mocoa
class FoobarModel: NSObject, XZMocoaModel {
    
    dynamic var name = "Visitor"
    
}

@mocoa
class FoobarViewModel : XZMocoaViewModel {
    
    @key
    var name: String = "123" {
        willSet {
            print(newValue);
            if newValue == "sd" {
                print("sd is here")
            }
        }
        didSet {
            print(oldValue);
        }
    }
    
    @key
    var detail: String?
    
    @bind
    func valueChanged(min: Int, max: Int) {
        self.detail = "\(min) => \(max)"
    }
    
}


