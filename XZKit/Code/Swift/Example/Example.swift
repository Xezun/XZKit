//
//  main.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/9.
//

import UIKit
import XZKit
import XZMocoa

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
    }
    
}

@mocoa(.vm)
class FooViewModel: XZMocoaViewModel {
    
    @key
    var name: String?
    
    @key(value: 12)
    @bind
    var age: Int
    
    @key(.detailText)
    @bind
    var detail: String?
    
    @key("fooBar", 20)
    var foobar : Int

    override func prepare() {
        super.prepare()
    }
    
    @bind("foo", "bar")
    func foobar(foo arg1: Int, bar arg2: Int) {
        
    }
    
    @bind("some")
    func doSomething(_ any: Int) {
        
    }
    
    @bind
    func doAnything(_ bar: Int) {
        
    }
    
}

@mocoa(.v)
class View: UIView, XZMocoaView {
    
    @bind
    var imageView: UIImageView!
    
    @bind(.name)
    @IBOutlet var nameLabel: UILabel!
    
    @observe
    @bind(.detailText)
    @bind(v: "textColor")
    var detailLabel: UILabel?
    
    @bind
    @bind("max")
    @bind("min")
    func valueDidChange(_ value: Int) {
        
    }
    
    @rewrite
    override func viewModelDidChange(_ oldValue: XZMocoaViewModel?) {
        super.viewModelDidChange(oldValue)
    }
    
}
