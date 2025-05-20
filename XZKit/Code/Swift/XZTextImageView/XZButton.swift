//
//  XZButton.swift
//  XZKit
//
//  Created by Xezun on 2018/9/29.
//

import Foundation
import UIKit
import XZGeometry

@objc open class XZButton: UIControl, XZTextImageView.Layout, XZTextImageView.StatedAppearance {
    
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
    
    open private(set) var backgroundViewIfLoaded: UIImageView?
    
    open var backgroundView: UIImageView {
        if backgroundViewIfLoaded != nil {
            return backgroundViewIfLoaded!
        }
        backgroundViewIfLoaded = UIImageView.init(frame: self.bounds)
        backgroundViewIfLoaded!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundViewIfLoaded!.contentMode = .scaleAspectFill
        insertSubview(backgroundViewIfLoaded!, at: 0)
        return backgroundViewIfLoaded!
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
    
    open override var isSelected: Bool {
        didSet { stateDidChange() }
    }
    
    open override var isHighlighted: Bool {
        didSet { stateDidChange() }
    }
    
    open override var isEnabled: Bool {
        didSet { stateDidChange() }
    }
    
    // MARK: - XZTextImageView.Layout
    
    open var style: XZTextImageView.Style = .trailing {
        didSet { setNeedsLayout() }
    }
    
    open private(set) var textViewIfLoaded: UILabel?
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
    
    // MARK: - XZTextImageView.StatedAppearance

    open func setText(_ text: String?, for state: UIControl.State) {
        configuration.texts[state.rawValue] = text
        textDidChange()
    }

    open func text(for state: UIControl.State) -> String? {
        return configuration.texts[state.rawValue]
    }

    open func setAttributedText(_ attributedText: NSAttributedString?, for state: UIControl.State) {
        configuration.attributedTitles[state.rawValue] = attributedText
        textDidChange()
    }

    open func attributedText(for state: UIControl.State) -> NSAttributedString? {
        return configuration.attributedTitles[state.rawValue]
    }
    
    open func setFont(_ font: UIFont?, for state: UIControl.State) {
        configuration.fonts[state.rawValue] = font
        fontDidChange()
    }

    open func font(for state: UIControl.State) -> UIFont? {
        return configuration.fonts[state.rawValue]
    }

    open func setTextColor(_ textColor: UIColor?, for state: UIControl.State) {
        configuration.textColors[state.rawValue] = textColor
        textColorDidChange()
    }

    open func textColor(for state: UIControl.State) -> UIColor? {
        return configuration.textColors[state.rawValue]
    }

    open func setTextShadowColor(_ textShadowColor: UIColor?, for state: UIControl.State) {
        configuration.textShadowColors[state.rawValue] = textShadowColor
        textShadowColorDidChange()
    }

    open func textShadowColor(for state: UIControl.State) -> UIColor? {
        return configuration.textShadowColors[state.rawValue]
    }

    open func setImage(_ image: UIImage?, for state: UIControl.State) {
        configuration.images[state.rawValue] = image
        imageDidChange()
    }

    open func image(for state: UIControl.State) -> UIImage? {
        return configuration.images[state.rawValue]
    }

    open func setBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State) {
        configuration.backgroundImages[state.rawValue] = backgroundImage
        backgroundImageDidChange()
    }

    open func backgroundImage(for state: UIControl.State) -> UIImage? {
        return configuration.backgroundImages[state.rawValue]
    }
    
    // MARK: - Methods for overrides

    open func stateDidChange() {
        textDidChange()
        fontDidChange()
        textColorDidChange()
        textShadowColorDidChange()
        imageDidChange()
        backgroundImageDidChange()
    }
    
    open func fontDidChange() {
        if let font = configuration.fonts[self.state.rawValue] {
            textLabel.font = font
        } else if state != .normal {
            textLabel.font = configuration.fonts[UIControl.State.normal.rawValue]
        } else {
            textLabel.font = .systemFont(ofSize: 17.0)
        }
        setNeedsLayout()
    }
    
    open func textDidChange() {
        if let attributedText = configuration.attributedTitles[state.rawValue] {
            textLabel.attributedText = attributedText
        } else if let text = configuration.texts[state.rawValue] {
            textLabel.text = text
        } else if state != .normal {
            if let attributedText = configuration.attributedTitles[UIControl.State.normal.rawValue] {
                textLabel.attributedText = attributedText
            } else {
                textLabel.text = configuration.texts[UIControl.State.normal.rawValue]
            }
        } else {
            textLabel.text = nil
        }
        setNeedsLayout()
    }
    
    open func textColorDidChange() {
        if let textColor = configuration.textColors[self.state.rawValue] {
            textLabel.textColor = textColor
        } else if state != .normal {
            textLabel.textColor =  configuration.textColors[UIControl.State.normal.rawValue]
        } else {
            textLabel.textColor = nil
        }
    }
    
    open func textShadowColorDidChange() {
        if let shadowColor = configuration.textShadowColors[self.state.rawValue] {
            textLabel.shadowColor = shadowColor
        } else if state != .normal {
            textLabel.shadowColor =  configuration.textShadowColors[UIControl.State.normal.rawValue]
        } else {
            textLabel.shadowColor = nil
        }
    }
    
    open func imageDidChange() {
        if let image = configuration.images[self.state.rawValue] {
            imageView.image = image
        } else if state != .normal {
            imageView.image = configuration.images[UIControl.State.normal.rawValue]
        } else {
            imageView.image = nil
        }
        setNeedsLayout()
    }
    
    open func backgroundImageDidChange() {
        if let backgroundImage = configuration.backgroundImages[self.state.rawValue] {
            backgroundView.image = backgroundImage
        } else if state != .normal {
            backgroundView.image = configuration.backgroundImages[UIControl.State.normal.rawValue]
        } else {
            backgroundView.image = nil
        }
    }
    
    /// 存储各个状态的样式。
    private lazy var configuration: Configuration = Configuration.init()
    
    private class Configuration {
        lazy var fonts            = [UInt: UIFont]()
        lazy var texts            = [UInt: String]()
        lazy var attributedTitles = [UInt: NSAttributedString]()
        lazy var textColors       = [UInt: UIColor]()
        lazy var textShadowColors = [UInt: UIColor]()
        lazy var images           = [UInt: UIImage]()
        lazy var backgroundImages = [UInt: UIImage]()
    }
}

extension XZTextImageView {
    
    public protocol StatedAppearance: XZTextImageView.Appearance {
        
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



