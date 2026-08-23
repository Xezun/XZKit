//
//  XZMocoaKey.swift
//  XZKit
//
//  Created by Xezun on 2026/8/23.
//

import Foundation
import XZKitObjC

extension XZMocoaKey {
    
    public static var `default`: XZMocoaKey {
        return XZMocoaKey.__default
    }
    public static var contentStatus: XZMocoaKey {
        return XZMocoaKey.__contentStatus
    }
    public static var status: XZMocoaKey {
        return XZMocoaKey.__status
    }
    public static var isChecked: XZMocoaKey {
        return XZMocoaKey.__isChecked
    }
    public static var isEnabled: XZMocoaKey {
        return XZMocoaKey.__isEnabled
    }
    public static var isEmpty: XZMocoaKey {
        return XZMocoaKey.__isEmpty
    }
    public static var value: XZMocoaKey {
        return XZMocoaKey.__value
    }
    public static var name: XZMocoaKey {
        return XZMocoaKey.__name
    }
    public static var type: XZMocoaKey {
        return XZMocoaKey.__type
    }
    public static var list: XZMocoaKey {
        return XZMocoaKey.__list
    }
    public static var icon: XZMocoaKey {
        return XZMocoaKey.__icon
    }
    public static var color: XZMocoaKey {
        return XZMocoaKey.__color
    }

    public static var isHidden: XZMocoaKey {
        return XZMocoaKey.__isHidden
    }
    public static var alpha: XZMocoaKey {
        return XZMocoaKey.__alpha
    }
    public static var frame: XZMocoaKey {
        return XZMocoaKey.__frame
    }
    public static var bounds: XZMocoaKey {
        return XZMocoaKey.__bounds
    }
    public static var center: XZMocoaKey {
        return XZMocoaKey.__center
    }
    public static var transform: XZMocoaKey {
        return XZMocoaKey.__transform
    }
    public static var tintColor: XZMocoaKey {
        return XZMocoaKey.__tintColor
    }
    public static var backgroundColor: XZMocoaKey {
        return XZMocoaKey.__backgroundColor
    }

    public static var text: XZMocoaKey {
        return XZMocoaKey.__text
    }
    public static var font: XZMocoaKey {
        return XZMocoaKey.__font
    }
    public static var textColor: XZMocoaKey {
        return XZMocoaKey.__textColor
    }
    public static var shadowColor: XZMocoaKey {
        return XZMocoaKey.__shadowColor
    }
    public static var attributedText: XZMocoaKey {
        return XZMocoaKey.__attributedText
    }
    public static var highlightedTextColor: XZMocoaKey {
        return XZMocoaKey.__highlightedTextColor
    }

    public static var placeholder: XZMocoaKey {
        return XZMocoaKey.__placeholder
    }

    public static var image: XZMocoaKey {
        return XZMocoaKey.__image
    }
    public static var highlightedImage: XZMocoaKey {
        return XZMocoaKey.__highlightedImage
    }
    public static var isAnimating: XZMocoaKey {
        return XZMocoaKey.__isAnimating
    }
    public static var imageURL: XZMocoaKey {
        return XZMocoaKey.__imageURL
    }

    public static var title: XZMocoaKey {
        return XZMocoaKey.__title
    }
    public static var attributedTitle: XZMocoaKey {
        return XZMocoaKey.__attributedTitle
    }

    public static var subtitle: XZMocoaKey {
        return XZMocoaKey.__subtitle
    }
    public static var detailText: XZMocoaKey {
        return XZMocoaKey.__detailText
    }

    public static var startAnimating: XZMocoaKey {
        return XZMocoaKey.__startAnimating
    }
    public static var stopAnimating: XZMocoaKey {
        return XZMocoaKey.__stopAnimating
    }
    public static var isRefreshing: XZMocoaKey {
        return XZMocoaKey.__isRefreshing
    }
    public static var isRequesting: XZMocoaKey {
        return XZMocoaKey.__isRequesting
    }
    public static var isLoading: XZMocoaKey {
        return XZMocoaKey.__isLoading
    }
    public static var date: XZMocoaKey {
        return XZMocoaKey.__date
    }
    public static var time: XZMocoaKey {
        return XZMocoaKey.__time
    }

    public static var isOn: XZMocoaKey {
        return XZMocoaKey.__isOn
    }

    public static var isTranslucent: XZMocoaKey {
        return XZMocoaKey.__isTranslucent
    }
    public static var prefersLargeTitles: XZMocoaKey {
        return XZMocoaKey.__prefersLargeTitles
    }

    // for Key Events Channel

    public static var reload: XZMocoaKey {
        return XZMocoaKey.__reload
    }
    public static var modify: XZMocoaKey {
        return XZMocoaKey.__modify
    }
    public static var insert: XZMocoaKey {
        return XZMocoaKey.__insert
    }
    public static var delete: XZMocoaKey {
        return XZMocoaKey.__delete
    }
    public static var select: XZMocoaKey {
        return XZMocoaKey.__select
    }
    public static var deselect: XZMocoaKey {
        return XZMocoaKey.__deselect
    }
    public static var confirm: XZMocoaKey {
        return XZMocoaKey.__confirm
    }
    public static var submit: XZMocoaKey {
        return XZMocoaKey.__submit
    }
    public static var cancel: XZMocoaKey {
        return XZMocoaKey.__cancel
    }
    public static var click: XZMocoaKey {
        return XZMocoaKey.__click
    }
    public static var from: XZMocoaKey {
        return XZMocoaKey.__from
    }
    public static var to: XZMocoaKey {
        return XZMocoaKey.__to
    }
    public static var valueDidChange: XZMocoaKey {
        return XZMocoaKey.__valueDidChange
    }
    public static var contentDidChange: XZMocoaKey {
        return XZMocoaKey.__contentDidChange
    }
    public static var navigationBackAction: XZMocoaKey {
        return XZMocoaKey.__navigationBackAction
    }
    public static var navigationMoreAction: XZMocoaKey {
        return XZMocoaKey.__navigationMoreAction
    }
    public static var viewWillAppear: XZMocoaKey {
        return XZMocoaKey.__viewWillAppear
    }
    public static var viewDidAppear: XZMocoaKey {
        return XZMocoaKey.__viewDidAppear
    }
    public static var viewWillDisappear: XZMocoaKey {
        return XZMocoaKey.__viewWillDisappear
    }
    public static var viewDidDisappear: XZMocoaKey {
        return XZMocoaKey.__viewDidDisappear
    }

    // for XZMocoaView

    public static var model: XZMocoaKey {
        return XZMocoaKey.__model
    }
    public static var identifier: XZMocoaKey {
        return XZMocoaKey.__identifier
    }
    public static var viewModel: XZMocoaKey {
        return XZMocoaKey.__viewModel
    }

    // for XZMocoaGroupView

    public static var headerDidBeginRefreshing: XZMocoaKey {
        return XZMocoaKey.__headerDidBeginRefreshing
    }
    public static var footerDidBeginRefreshing: XZMocoaKey {
        return XZMocoaKey.__footerDidBeginRefreshing
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
    public var isEmpty: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isEmpty.rawValue)
    }
    public var value: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__value.rawValue)
    }
    public var name: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__name.rawValue)
    }
    public var type: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__type.rawValue)
    }
    public var list: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__list.rawValue)
    }
    public var icon: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__icon.rawValue)
    }
    public var color: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__color.rawValue)
    }
    
    public var isHidden: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__isHidden.rawValue)
    }
    public var alpha: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__alpha.rawValue)
    }
    public var frame: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__frame.rawValue)
    }
    public var bounds: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__bounds.rawValue)
    }
    public var center: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__center.rawValue)
    }
    public var transform: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__transform.rawValue)
    }
    public var tintColor: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__tintColor.rawValue)
    }
    public var backgroundColor: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__backgroundColor.rawValue)
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
    public var date: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__date.rawValue)
    }
    public var time: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__time.rawValue)
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
    public var click: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__click.rawValue)
    }
    public var from: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__from.rawValue)
    }
    public var to: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__to.rawValue)
    }
    public var valueDidChange: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__valueDidChange.rawValue)
    }
    public var contentDidChange: XZMocoaKey {
        return XZMocoaKey(self.rawValue + "." + XZMocoaKey.__contentDidChange.rawValue)
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