//
//  XZTextImageView.swift
//  XZKit
//
//  Created by Xezun on 2017/7/24.
//  Copyright © 2017年 Xezun Individual. All rights reserved.
//

import UIKit

/// 一个图片、文字上下布局的视图，可以自定义图片文字边距。
@objc open class XZTextImageView: UIView, XZTextImageView.Layout {

    open var style: XZTextImageView.Style = .bottomText {
        didSet { setNeedsLayout() }
    }
    
    /// 视图内边距，文字将不会显示在边距内。默认 .zero 。
    /// - Note: 内容大小 + contentInsets = 视图大小。
    /// - Note: 该属性会影响图片大小和文字排版。
    open var contentInsets: NSDirectionalEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    /// 标题文本视图的外边距，根据其默认位置和大小来计算。默认 .zero 。
    /// - 影响文字区域的大小和位置。
    open var textInsets: NSDirectionalEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    /// 图片视图的外边距，根据其默认位置和大小来计算。默认 .zero 。
    /// - 影响图片的大小和位置。
    open var imageInsets: NSDirectionalEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    /// 标题文字。
    open var text: String? {
        get { return textViewIfLoaded?.text  }
        set { textLabel.text = newValue; setNeedsLayout(); }
    }
    
    /// 富文本标题。
    open var attributedText: NSAttributedString? {
        get { return textViewIfLoaded?.attributedText; }
        set { textLabel.attributedText = newValue; setNeedsLayout(); }
    }
    
    /// 图片。
    open var image: UIImage? {
        get { return imageViewIfLoaded?.image }
        set { imageView.image = newValue; setNeedsLayout(); }
    }

    /// 如果 textLabel 已加载，将返回它，否则 nil 。
    open private(set) var textViewIfLoaded: UILabel?
    
    /// 文字控件，懒加载属性。
    /// - Note: 在限定的宽度下，文字可能会多行显示。
    /// - Note: 请不要通过此属性来设置标题。
    /// - Note: 默认情况下，文本视图在图片视图上方，也就是说，文字不会被图片遮挡。
    open var textLabel: UILabel {
        if let textLabel = textViewIfLoaded {
            return textLabel
        }
        textViewIfLoaded = UILabel.init(frame: self.bounds)
        textViewIfLoaded!.numberOfLines = 0
        textViewIfLoaded!.textAlignment = .center
        self.addSubview(textViewIfLoaded!)
        return textViewIfLoaded!
    }
    
    /// 如果 imageView 已加载，将返回它，否则 nil 。
    open private(set) var imageViewIfLoaded: UIImageView?
    
    /// 图片控件，懒加载属性，可使用 isImageViewLoaded 属性来判断是否已初始化。
    /// - Note: 请不要通过此属性来设置图片。
    open var imageView: UIImageView {
        if let imageView = imageViewIfLoaded {
            return imageView
        }
        imageViewIfLoaded = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        insertSubview(imageViewIfLoaded!, at: 0)
        return imageViewIfLoaded!
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layoutTextImage()
    }
    
    open override var intrinsicContentSize: CGSize {
        return self.textImageIntrinsicSize
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.textImageSizeThatFits(size)
    }
    
}


extension XZTextImageView {
    
    @MainActor public protocol StatedAppearance: XZTextImageView.Appearance {
        
        func text(for state: UIControl.State) -> String?
        func setText(_ text: String?, for state: UIControl.State)
        
        func attributedText(for state: UIControl.State) -> NSAttributedString?
        func setAttributedText(_ attributedText: NSAttributedString?, for state: UIControl.State)
        
        func font(for state: UIControl.State) -> UIFont?
        func setFont(_ font: UIFont?, for state: UIControl.State)

        func textColor(for state: UIControl.State) -> UIColor?
        func setTextColor(_ textColor: UIColor?, for state: UIControl.State)

        func textShadowColor(for state: UIControl.State) -> UIColor?
        func setTextShadowColor(_ textShadowColor: UIColor?, for state: UIControl.State)

        func image(for state: UIControl.State) -> UIImage?
        func setImage(_ image: UIImage?, for state: UIControl.State)

        func backgroundImage(for state: UIControl.State) -> UIImage?
        func setBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State)

    }
    
}
