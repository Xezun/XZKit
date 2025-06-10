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
        let viewModel = TestFoo.init(model: nil)
        
        let label = UILabel.init()
    }
}

@mocoa(.vm)
class TestFoo: XZMocoaViewModel {
    
    @bind("foo", "bar")
    func foobar(foo arg1: Int, bar arg2: Int) {
        
    }
    
    @bind("some")
    func dosom(_ any: Int) {
        
    }
    
    @bind
    func dosomething(_ bar: Int) {
        
    }
    
    
}

@mocoa(.vm)
class FooViewModel: XZMocoaViewModel {
    
    
    
    @key
    var name: String?
    
    @key(value: 12)
    var age: Int
    
    @key(.detailText)
    var detail: String?
    
    @key("fooBar", 20)
    var foobar : Int
    
    
    var foo = 1
    
//    @model("age", "foobar") func setAge(_ age: Int, fooBar: Int) {
//        
//    }
//    @key("maxAge", value: 20) var age: Int
    
//    @key(value: 20.0) var length: Double
    
    @objc(dosomthing) func som() {
        
    }
    
    override func prepare() {
        super.prepare()
        
    }
    
}


@mocoa(.vm)
class BarViewModel : FooViewModel {
    
}


@mocoa(.v)
class View: UIView, XZMocoaView {
    
    @bind
    @IBOutlet var nameLabel: UILabel!
    
    @bind(.imageURL)
    var imageView: UIImageView!
    
}
