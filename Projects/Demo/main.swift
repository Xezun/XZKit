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

let model: Any = 1
let viewController = UIViewController.init(mocoaURL: #URL("https://habit.xezun.com/pages/main/home"), options: [.model: model])

let navigationController = UINavigationController.init()
navigationController.pushMocoaURL(#URL("https://habit.xezun.com/pages/main/home"), options: [.model: model])

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


@mocoa
class Model: NSObject, XZMocoaModel {
    // 因为 Mocoa 使用 OBJC 的 KVO 实现监听机制，
    // 所以在 Model 中，被监听的属性需添加 @objc dynamic 的标记。
    // 注：CoreData 模型的 @NSManaged 标记，与 @objc dynamic 等价。
    @objc dynamic var name: String?
}

@mocoa
class ViewModel: XZMocoaViewModel {
    // 被 @key 标记的属性，可以被 View 绑定。
    // 默认情况下，属性名就是绑定的标识符，若要使用其它标识符，使用 @key("keyName") 即可。
    @key var name: String?
    
}

@mocoa
class View: UIView, XZMocoaView {
    // 绑定 ViewModel 的带 @key 标记属性。
    @bind(key: "name", selector: #selector(setter: UILabel.text))
    let nameLabel: UILabel = .init()
}

//
//let model = Model.init()
//let viewModel = ViewModel.init(model: model)
//let view = View.init()
//
//superview.addSubview(view)
//
//let  sel = #selector(UIButton.setTitle("", for: .normal));
