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
    
    @key(value: 12)
    @bind
    var age: Int
    
    @key(.detailText)
    @bind
    var detail: String?
    
    @key("fooBar", 20)
    var foobar : Int

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
    
    @key(value: 0)
    @bind(.foo.bar.bar)
    var keyPathValue2: Int
    
    
    
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
