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
class FoobarView: UIView, XZMocoaView {
    
    
    @bind(.name)            // 将 viewModel.name 单向绑定给 nameLabel.text
    @bind(key: .textColor)    // 将 viewModel.textColor 单向绑定给 nameLabel.textColor
    var nameLabel: UILabel = .init()
    
    // 将 viewModel.isChecked 单向绑定到此方法
    @bind
    func checkStatusValueChanged(_ isChecked: Bool) {
        self.nameLabel.backgroundColor = isChecked ? .red : .black
    }
    
    
    @objc func deleteButtonAction(_ sender: UIButton) {
        self.viewModel?.didReceiveEvents(.delete, value: nil)
    }
    
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


