//
//  TextImageControl.swift
//  XZKit
//
//  Created by Xezun on 2018/9/29.
//

import Foundation

@objc(XZTextImageControl)
open class TextImageControl: UIControl, TextImageLayout {
    
    open var textLabel: UILabel {
        if let textLabel = textLabelIfLoaded {
            return textLabel
        }
        textLabelIfLoaded = UILabel.init(frame: self.bounds)
        textLabelIfLoaded!.textColor = UIColor.black
        textLabelIfLoaded!.numberOfLines = 0
        textLabelIfLoaded!.textAlignment = .center
        if let attributedTitle = attributedText(for: state) ?? attributedText(for: .normal) {
            textLabelIfLoaded!.attributedText = attributedTitle
        } else {
            textLabelIfLoaded!.text = text(for: state) ?? text(for: .normal)
        }
        textLabelIfLoaded!.textColor = textColor(for: state) ?? textColor(for: .normal)
        textLabelIfLoaded!.shadowColor = textShadowColor(for: state) ?? textShadowColor(for: .normal)
        self.addSubview(textLabelIfLoaded!)
        return textLabelIfLoaded!
    }
    
    open private(set) var textLabelIfLoaded: UILabel?
    
    open var imageView: UIImageView {
        if let imageView = imageViewIfLoaded {
            return imageView
        }
        imageViewIfLoaded = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        imageViewIfLoaded!.image = image(for: state) ?? image(for: .normal)
        if let titleLabel = textLabelIfLoaded, titleLabel.superview == self {
            insertSubview(imageViewIfLoaded!, belowSubview: titleLabel)
        } else {
            addSubview(imageViewIfLoaded!)
        }
        return imageViewIfLoaded!
    }
    
    open private(set) var imageViewIfLoaded: UIImageView?
    
    open var contentInsets: XZEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    open var textInsets: XZEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    open var imageInsets: XZEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    open var textLayoutEdge: XZRectEdge = .bottom {
        didSet { setNeedsLayout() }
    }
    
    open var backgroundImageViewIfLoaded: UIImageView?
    
    open var backgroundImageView: UIImageView {
        if backgroundImageViewIfLoaded != nil {
            return backgroundImageViewIfLoaded!
        }
        backgroundImageViewIfLoaded = UIImageView.init(frame: self.bounds)
        backgroundImageViewIfLoaded!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageViewIfLoaded!.contentMode = .scaleAspectFill
        insertSubview(backgroundImageViewIfLoaded!, at: 0)
        return backgroundImageViewIfLoaded!
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layoutTextImageViews()
    }
    
    open override var intrinsicContentSize: CGSize {
        return self.intrinsicTextImageSize
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.textImageSizeThatFits(size)
    }
    
    open override var isSelected: Bool {
        didSet { stateDidChange() }
    }
    
    open override var isHighlighted: Bool {
        didSet { stateDidChange() }
    }
    
    open override var isEnabled: Bool {
        didSet { stateDidChange() }
    }

    open func setText(_ text: String?, for state: UIControl.State) {
        storage.statedTexts[state.rawValue] = text
        textDidChange()
    }

    open func text(for state: UIControl.State) -> String? {
        return storage.statedTexts[state.rawValue]
    }

    open func setAttributedText(_ attributedText: NSAttributedString?, for state: UIControl.State) {
        storage.statedAttributedTitles[state.rawValue] = attributedText
        textDidChange()
    }

    open func attributedText(for state: UIControl.State) -> NSAttributedString? {
        return storage.statedAttributedTitles[state.rawValue]
    }

    open func setTextColor(_ textColor: UIColor?, for state: UIControl.State) {
        storage.statedTextColors[state.rawValue] = textColor
        textColorDidChange()
    }

    open func textColor(for state: UIControl.State) -> UIColor? {
        return storage.statedTextColors[state.rawValue]
    }

    open func setTextShadowColor(_ textShadowColor: UIColor?, for state: UIControl.State) {
        storage.statedTextShadowColors[state.rawValue] = textShadowColor
        textShadowColorDidChange()
    }

    open func textShadowColor(for state: UIControl.State) -> UIColor? {
        return storage.statedTextShadowColors[state.rawValue]
    }

    open func setImage(_ image: UIImage?, for state: UIControl.State) {
        storage.statedImages[state.rawValue] = image
        imageDidChange()
    }

    open func image(for state: UIControl.State) -> UIImage? {
        return storage.statedImages[state.rawValue]
    }

    open func setBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State) {
        storage.statedBackgroundImages[state.rawValue] = backgroundImage
        backgroundImageDidChange()
    }

    open func backgroundImage(for state: UIControl.State) -> UIImage? {
        return storage.statedBackgroundImages[state.rawValue]
    }

    open func stateDidChange() {
        textDidChange()
        textColorDidChange()
        textShadowColorDidChange()
        imageDidChange()
        backgroundImageDidChange()
    }
    
    open func textDidChange() {
        if let attributedText = storage.statedAttributedTitles[state.rawValue] {
            textLabel.attributedText = attributedText
        } else if let text = storage.statedTexts[state.rawValue] {
            textLabel.text = text
        } else if state != .normal {
            if let attributedText = storage.statedAttributedTitles[UIControl.State.normal.rawValue] {
                textLabel.attributedText = attributedText
            } else {
                textLabel.text = storage.statedTexts[UIControl.State.normal.rawValue]
            }
        } else {
            textLabel.text = nil
        }
        setNeedsLayout()
    }
    
    open func textColorDidChange() {
        if let textColor = storage.statedTextColors[self.state.rawValue] {
            textLabel.textColor = textColor
        } else if state != .normal {
            textLabel.textColor =  storage.statedTextColors[UIControl.State.normal.rawValue]
        } else {
            textLabel.textColor = nil
        }
    }
    
    open func textShadowColorDidChange() {
        if let shadowColor = storage.statedTextShadowColors[self.state.rawValue] {
            textLabel.shadowColor = shadowColor
        } else if state != .normal {
            textLabel.shadowColor =  storage.statedTextShadowColors[UIControl.State.normal.rawValue]
        } else {
            textLabel.shadowColor = nil
        }
    }
    
    open func imageDidChange() {
        if let image = storage.statedImages[self.state.rawValue] {
            imageView.image = image
        } else if state != .normal {
            imageView.image = storage.statedImages[UIControl.State.normal.rawValue]
        } else {
            imageView.image = nil
        }
        setNeedsLayout()
    }
    
    open func backgroundImageDidChange() {
        if let backgroundImage = storage.statedBackgroundImages[self.state.rawValue] {
            backgroundImageView.image = backgroundImage
        } else if state != .normal {
            backgroundImageView.image = storage.statedBackgroundImages[UIControl.State.normal.rawValue]
        } else {
            backgroundImageView.image = nil
        }
    }
    
    /// 存储各个状态的样式。
    private lazy var storage: Storage = Storage.init()
    
    private class Storage {
        lazy var statedTexts            = [UInt: String]()
        lazy var statedAttributedTitles = [UInt: NSAttributedString]()
        lazy var statedTextColors       = [UInt: UIColor]()
        lazy var statedTextShadowColors = [UInt: UIColor]()
        lazy var statedImages           = [UInt: UIImage]()
        lazy var statedBackgroundImages = [UInt: UIImage]()
    }
}
