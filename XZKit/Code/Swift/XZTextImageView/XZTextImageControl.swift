//
//  XZTextImageControl.swift
//  XZKit
//
//  Created by Xezun on 2018/9/29.
//

import Foundation
import UIKit
import XZGeometry

@objc open class XZTextImageControl: UIControl, XZTextImageLayout {
    
    open var textLabel: UILabel {
        if let textLabel = textViewIfLoaded {
            return textLabel
        }
        textViewIfLoaded = UILabel.init(frame: self.bounds)
        textViewIfLoaded!.textColor = UIColor.black
        textViewIfLoaded!.numberOfLines = 0
        textViewIfLoaded!.textAlignment = .center
        if let attributedTitle = attributedText(for: state) ?? attributedText(for: .normal) {
            textViewIfLoaded!.attributedText = attributedTitle
        } else {
            textViewIfLoaded!.text = text(for: state) ?? text(for: .normal)
        }
        textViewIfLoaded!.textColor = textColor(for: state) ?? textColor(for: .normal)
        textViewIfLoaded!.shadowColor = textShadowColor(for: state) ?? textShadowColor(for: .normal)
        self.addSubview(textViewIfLoaded!)
        return textViewIfLoaded!
    }
    
    open private(set) var textViewIfLoaded: UILabel?
    
    open var imageView: UIImageView {
        if let imageView = imageViewIfLoaded {
            return imageView
        }
        imageViewIfLoaded = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        imageViewIfLoaded!.image = image(for: state) ?? image(for: .normal)
        if let titleLabel = textViewIfLoaded, titleLabel.superview == self {
            insertSubview(imageViewIfLoaded!, belowSubview: titleLabel)
        } else {
            addSubview(imageViewIfLoaded!)
        }
        return imageViewIfLoaded!
    }
    
    open private(set) var imageViewIfLoaded: UIImageView?
    
    open var contentInsets: NSDirectionalEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    open var textInsets: NSDirectionalEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    open var imageInsets: NSDirectionalEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    open var textLayoutDirection: NSDirectionalRectEdge = .bottom {
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
        return self.textImageIntrinsicSize
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
        styles.texts[state.rawValue] = text
        textDidChange()
    }

    open func text(for state: UIControl.State) -> String? {
        return styles.texts[state.rawValue]
    }

    open func setAttributedText(_ attributedText: NSAttributedString?, for state: UIControl.State) {
        styles.attributedTitles[state.rawValue] = attributedText
        textDidChange()
    }

    open func attributedText(for state: UIControl.State) -> NSAttributedString? {
        return styles.attributedTitles[state.rawValue]
    }
    
    open func setFont(_ font: UIFont?, for state: UIControl.State) {
        styles.fonts[state.rawValue] = font
        fontDidChange()
    }

    open func font(for state: UIControl.State) -> UIFont? {
        return styles.fonts[state.rawValue]
    }

    open func setTextColor(_ textColor: UIColor?, for state: UIControl.State) {
        styles.textColors[state.rawValue] = textColor
        textColorDidChange()
    }

    open func textColor(for state: UIControl.State) -> UIColor? {
        return styles.textColors[state.rawValue]
    }

    open func setTextShadowColor(_ textShadowColor: UIColor?, for state: UIControl.State) {
        styles.textShadowColors[state.rawValue] = textShadowColor
        textShadowColorDidChange()
    }

    open func textShadowColor(for state: UIControl.State) -> UIColor? {
        return styles.textShadowColors[state.rawValue]
    }

    open func setImage(_ image: UIImage?, for state: UIControl.State) {
        styles.images[state.rawValue] = image
        imageDidChange()
    }

    open func image(for state: UIControl.State) -> UIImage? {
        return styles.images[state.rawValue]
    }

    open func setBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State) {
        styles.backgroundImages[state.rawValue] = backgroundImage
        backgroundImageDidChange()
    }

    open func backgroundImage(for state: UIControl.State) -> UIImage? {
        return styles.backgroundImages[state.rawValue]
    }

    open func stateDidChange() {
        textDidChange()
        fontDidChange()
        textColorDidChange()
        textShadowColorDidChange()
        imageDidChange()
        backgroundImageDidChange()
    }
    
    open func fontDidChange() {
        if let font = styles.fonts[self.state.rawValue] {
            textLabel.font = font
        } else if state != .normal {
            textLabel.font = styles.fonts[UIControl.State.normal.rawValue]
        } else {
            textLabel.font = .systemFont(ofSize: 17.0)
        }
        setNeedsLayout()
    }
    
    open func textDidChange() {
        if let attributedText = styles.attributedTitles[state.rawValue] {
            textLabel.attributedText = attributedText
        } else if let text = styles.texts[state.rawValue] {
            textLabel.text = text
        } else if state != .normal {
            if let attributedText = styles.attributedTitles[UIControl.State.normal.rawValue] {
                textLabel.attributedText = attributedText
            } else {
                textLabel.text = styles.texts[UIControl.State.normal.rawValue]
            }
        } else {
            textLabel.text = nil
        }
        setNeedsLayout()
    }
    
    open func textColorDidChange() {
        if let textColor = styles.textColors[self.state.rawValue] {
            textLabel.textColor = textColor
        } else if state != .normal {
            textLabel.textColor =  styles.textColors[UIControl.State.normal.rawValue]
        } else {
            textLabel.textColor = nil
        }
    }
    
    open func textShadowColorDidChange() {
        if let shadowColor = styles.textShadowColors[self.state.rawValue] {
            textLabel.shadowColor = shadowColor
        } else if state != .normal {
            textLabel.shadowColor =  styles.textShadowColors[UIControl.State.normal.rawValue]
        } else {
            textLabel.shadowColor = nil
        }
    }
    
    open func imageDidChange() {
        if let image = styles.images[self.state.rawValue] {
            imageView.image = image
        } else if state != .normal {
            imageView.image = styles.images[UIControl.State.normal.rawValue]
        } else {
            imageView.image = nil
        }
        setNeedsLayout()
    }
    
    open func backgroundImageDidChange() {
        if let backgroundImage = styles.backgroundImages[self.state.rawValue] {
            backgroundImageView.image = backgroundImage
        } else if state != .normal {
            backgroundImageView.image = styles.backgroundImages[UIControl.State.normal.rawValue]
        } else {
            backgroundImageView.image = nil
        }
    }
    
    /// 存储各个状态的样式。
    private lazy var styles: StatedStyles = StatedStyles.init()
    
    private class StatedStyles {
        lazy var fonts            = [UInt: UIFont]()
        lazy var texts            = [UInt: String]()
        lazy var attributedTitles = [UInt: NSAttributedString]()
        lazy var textColors       = [UInt: UIColor]()
        lazy var textShadowColors = [UInt: UIColor]()
        lazy var images           = [UInt: UIImage]()
        lazy var backgroundImages = [UInt: UIImage]()
    }
}
