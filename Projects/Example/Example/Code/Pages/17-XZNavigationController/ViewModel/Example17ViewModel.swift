//
//  Example17ViewModel.swift
//  Example
//
//  Created by 徐臻 on 2026/3/21.
//

import UIKit
import XZKit

@mocoa
class Example17ViewModel: XZMocoaViewModel {
    
    override var shouldObserveModelKeysActively: Bool {
        return true
    }
    
    @key
    @bind("current.isHidden")
    var currentHidden: Bool = false {
        didSet {
            let model = self.model as! Example17Model
            if model.current.isHidden != currentHidden {
                model.current.isHidden = currentHidden
            }
        }
    }
    
    @key
    @bind("current.isTranslucent")
    var currentTranslucent: Bool = true {
        didSet {
            let model = self.model as! Example17Model
            if model.current.isTranslucent != currentTranslucent {
                model.current.isTranslucent = currentTranslucent
            }
        }
    }
    
    @key
    @bind("current.prefersLargeTitles")
    var currentLargeTitles: Bool = false {
        didSet {
            let model = self.model as! Example17Model
            if model.current.prefersLargeTitles != currentLargeTitles {
                model.current.prefersLargeTitles = currentLargeTitles
            }
        }
    }
    
    @key
    @bind("next.isHidden")
    var nextHidden: Bool = false {
        didSet {
            let model = self.model as! Example17Model
            if model.next.isHidden != nextHidden {
                model.next.isHidden = nextHidden
            }
        }
    }
    
    @key
    @bind("next.isTranslucent")
    var nextTranslucent: Bool = true {
        didSet {
            let model = self.model as! Example17Model
            if model.next.isTranslucent != nextTranslucent {
                model.next.isTranslucent = nextTranslucent
            }
        }
    }
    
    @key
    @bind("next.prefersLargeTitles")
    var nextLargeTitles: Bool = false {
        didSet {
            let model = self.model as! Example17Model
            if model.next.prefersLargeTitles != nextLargeTitles {
                model.next.prefersLargeTitles = nextLargeTitles
            }
                
        }
    }
    
    var next: Example17ViewModel {
        let model = Example17Model.init(current: (self.model as! Example17Model).next)
        return .init(model: model)
    }
    
}
