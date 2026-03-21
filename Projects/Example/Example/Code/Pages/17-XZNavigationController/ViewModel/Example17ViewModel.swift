//
//  Example17ViewModel.swift
//  Example
//
//  Created by 徐臻 on 2026/3/21.
//

import UIKit
import XZKit

@mocoa(.vm)
class Example17ViewModel: XZMocoaViewModel {
    
    override var shouldObserveModelKeysActively: Bool {
        return true
    }
    
    @key(value: false)
    @bind("current.isHidden")
    var currentHidden: Bool
    
    @key(value: true)
    @bind("current.isTranslucent")
    var currentTranslucent: Bool
    
    @key(value: false)
    @bind("current.prefersLargeTitles")
    var currentLargeTitles: Bool
    
    @key(value: false)
    @bind("next.isHidden")
    var nextHidden: Bool
    
    @key(value: true)
    @bind("next.isTranslucent")
    var nextTranslucent: Bool
    
    @key(value: false)
    @bind("next.prefersLargeTitles")
    var nextLargeTitles: Bool
    
    var next: Example17ViewModel {
        let model = Example17Model.init(current: (self.model as! Example17Model).next)
        return .init(model: model)
    }
        
    func currentHiddenChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.current.isHidden = newValue
    }
    
    func currentTranslucentChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.current.isTranslucent = newValue
    }
    
    func currentLargeTitlesChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.current.prefersLargeTitles = newValue
    }
    
    func nextHiddenChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.next.isHidden = newValue
    }
    
    func nextTranslucentChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.next.isTranslucent = newValue
    }
    
    func nextLargeTitlesChangeValue(_ newValue: Bool) {
        let model = self.model as! Example17Model
        model.next.prefersLargeTitles = newValue
    }
    
}
