//
//  UIAlertController.swift
//  XZKit
//
//  Created by mlibai on 2018/7/24.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    /// 富文本标题。
    public var attributedTitle: NSAttributedString? {
        get { return value(forKey: "attributedTitle") as? NSAttributedString }
        set { setValue(newValue, forKey: "attributedTitle") }
    }
    
    /// 富文本消息内容。
    public var attributedMessage: NSAttributedString? {
        get { return value(forKey: "attributedMessage") as? NSAttributedString }
        set { setValue(newValue, forKey: "attributedMessage") }
    }
    
}

extension UIAlertAction {
    
    /// 文本颜色。
    public var textColor: UIColor? {
        get { return value(forKey: "_titleTextColor") as? UIColor }
        set { setValue(newValue, forKey: "_titleTextColor") }
    }

    @available(iOS 9.0, *)
    public var isPreferred: Bool {
        get { return (value(forKey: "_isPreferred") as? Bool) ?? false }
        set { setValue(newValue, forKey: "_isPreferred") }
    }
    
    /// 文本对齐方式。
    public var textAlignment: NSTextAlignment {
        get { return (value(forKey: "_titleTextAlignment") as? NSTextAlignment) ?? .center }
        set { setValue(newValue, forKey: "_titleTextAlignment") }
    }

    /// 图片。
    public var image: UIImage? {
        get { return value(forKey: "_image") as? UIImage }
        set { setValue(newValue, forKey: "_image") }
    }

    /// 图片渲染色。
    public var imageTintColor: UIColor? {
        get { return value(forKey: "_imageTintColor") as? UIColor }
        set { setValue(newValue, forKey: "_imageTintColor") }
    }
    
}




