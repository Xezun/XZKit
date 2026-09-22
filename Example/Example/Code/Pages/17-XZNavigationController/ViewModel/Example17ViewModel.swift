//
//  Example17ViewModel.swift
//  Example
//
//  Created by Xezun on 2026/3/21.
//

import UIKit
import XZKit

@mocoa
class Example17ViewModel: XZMocoaViewModel {
    
    @key
    @bind("current.isHidden")
    var currentHidden: Bool = false
    
    @key
    @bind("current.isTranslucent")
    var currentTranslucent: Bool = true
    
    @key
    @bind("current.prefersLargeTitles")
    var currentLargeTitles: Bool = false
    
    @key
    @bind("next.isHidden")
    var nextHidden: Bool = false
    
    @key
    @bind("next.isTranslucent")
    var nextTranslucent: Bool = true
    
    @key
    @bind("next.prefersLargeTitles")
    var nextLargeTitles: Bool = false
    
    var next: Example17ViewModel {
        let model = Example17Model.init(current: (self.model as! Example17Model).next)
        return Example17ViewModel.init(model: model)
    }
    
    override func didReceive(_ events: XZMocoaEvents) {
        guard let model = self.model as? Example17Model else {
            return super.didReceive(events)
        }
        guard let isOn = events.value as? Bool else {
            return super.didReceive(events)
        }
        switch events.key {
        case "currentHidden":
            model.current.isHidden = isOn
        case "currentTranslucent":
            model.current.isTranslucent = isOn
        case "currentLargeTitles":
            model.current.prefersLargeTitles = isOn
        case "nextHidden":
            model.next.isHidden = isOn;
        case "nextTranslucent":
            model.next.isTranslucent = isOn;
        case "nextLargeTitles":
            model.next.prefersLargeTitles = isOn;
        default:
            super.didReceive(events)
        }
    }
    
}
