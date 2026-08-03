//
//  XZMocoa.swift
//  XZKit
//
//  Created by Xezun on 2025/1/25.
//

import Foundation

extension XZMocoaKind: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaName: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaKey: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaKey {
    
    public var `default`: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__default.rawValue)
    }
    public var contentStatus: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__contentStatus.rawValue)
    }
    public var status: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__status.rawValue)
    }
    public var isChecked: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isChecked.rawValue)
    }
    public var isEnabled: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isEnabled.rawValue)
    }
    public var value: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__value.rawValue)
    }
    public var name: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__name.rawValue)
    }
    public var icon: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__icon.rawValue)
    }
    
    public var isHidden: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isHidden.rawValue)
    }
    
    public var text: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__text.rawValue)
    }
    public var font: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__font.rawValue)
    }
    public var textColor: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__textColor.rawValue)
    }
    public var shadowColor: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__shadowColor.rawValue)
    }
    public var attributedText: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__attributedText.rawValue)
    }
    public var highlightedTextColor: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__highlightedTextColor.rawValue)
    }
    
    public var placeholder: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__placeholder.rawValue)
    }
    
    public var image: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__image.rawValue)
    }
    public var highlightedImage: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__highlightedImage.rawValue)
    }
    public var isAnimating: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isAnimating.rawValue)
    }
    public var imageURL: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__imageURL.rawValue)
    }
    
    public var title: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__title.rawValue)
    }
    public var attributedTitle: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__attributedTitle.rawValue)
    }
    
    public var subtitle: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__subtitle.rawValue)
    }
    public var detailText: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__detailText.rawValue)
    }
    
    public var startAnimating: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__startAnimating.rawValue)
    }
    public var stopAnimating: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__stopAnimating.rawValue)
    }
    public var isRefreshing: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isRefreshing.rawValue)
    }
    public var isRequesting: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isRequesting.rawValue)
    }
    public var isLoading: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isLoading.rawValue)
    }
    
    public var isOn: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isOn.rawValue)
    }
    
    public var isTranslucent: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isTranslucent.rawValue)
    }
    public var prefersLargeTitles: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__prefersLargeTitles.rawValue)
    }
    
    // for Key Events Channel
    
    public var reload: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__reload.rawValue)
    }
    public var modify: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__modify.rawValue)
    }
    public var insert: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__insert.rawValue)
    }
    public var delete: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__delete.rawValue)
    }
    public var select: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__select.rawValue)
    }
    public var deselect: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__deselect.rawValue)
    }
    public var confirm: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__confirm.rawValue)
    }
    public var submit: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__submit.rawValue)
    }
    public var cancel: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__cancel.rawValue)
    }
    public var valueChanged: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__valueChanged.rawValue)
    }
    public var navigationBackAction: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__navigationBackAction.rawValue)
    }
    public var navigationMoreAction: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__navigationMoreAction.rawValue)
    }
    public var viewWillAppear: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__viewWillAppear.rawValue)
    }
    public var viewDidAppear: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__viewDidAppear.rawValue)
    }
    public var viewWillDisappear: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__viewWillDisappear.rawValue)
    }
    public var viewDidDisappear: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__viewDidDisappear.rawValue)
    }
    
    // for XZMocoaView
    
    public var model: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__model.rawValue)
    }
    public var identifier: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__identifier.rawValue)
    }
    public var viewModel: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__viewModel.rawValue)
    }
    
    // for XZMocoaGroupView
    
    public var headerDidBeginRefreshing: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__headerDidBeginRefreshing.rawValue)
    }
    public var footerDidBeginRefreshing: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__footerDidBeginRefreshing.rawValue)
    }
}
