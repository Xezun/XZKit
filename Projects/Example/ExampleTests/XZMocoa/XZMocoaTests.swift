//
//  XZMocoaTests.swift
//  Example
//
//  Created by Xezun on 2025/7/4.
//

import UIKit
import XZKit

struct Foobar {
   
    static let foo = Foobar.init()
    
    var bar: XZMocoaKey {
        return "foo.bar"
    }
}

@mocoa
class FooViewModel: XZMocoaViewModel {
    
    @key
    var name: String?
    
    @key
    @bind
    var age: Int = 12
    
    @key(.detailText)
    @bind
    var detail: String?
    
    @key("foobar")
    var fooBar : Int = 20

    @prepare
    private func prepare1() {
        
    }
    
    @prepare
    private func prepare2() {
        
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
    
    @bind(Foobar.foo.bar.bar)
    func setKeyPathValue1(_ value: Int) {
        
    }
    
    @key
    @bind(.foo.bar.bar)
    var keyPathValue2: Int = 0
    
}

extension XZMocoaKey {
    
    static let foo = XZMocoaKey("foo")
    
    var bar: XZMocoaKey {
        return "bar"
    }
}

@mocoa(.v)
class View: UIView, XZMocoaView {
    
    @bind
    var imageView: UIImageView!
    
    @bind(.name)
    @IBOutlet var nameLabel: UILabel!
    
    @bind(.detailText)
    @bind(v: "textColor")
    var detailLabel: UILabel?
    
    @bind
    @bind("max")
    @bind("min")
    func valueDidChange(_ value: Int) {
        
    }
    
    @prepare
    private func setup() {
        
    }
    
    @bind
    let label: UILabel = UILabel.init()
    
}
