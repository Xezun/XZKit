//
//  main.swift
//  Client
//
//  Created by 徐臻 on 2026/4/13.
//

import Foundation
import XZKit

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
    
    
    
}
