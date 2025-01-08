//
//  XZContentStatusView.swift
//  AFNetworking
//
//  Created by Xezun on 2017/12/2.
//

import UIKit
import XZTextImageView

/// 呈现视图内容状态的视图。
@MainActor @objc open class XZContentStatusView: UIControl, XZTextImageLayout, XZContentStatusRepresentable {
    
    private class StyleCollection {
        var title: String?
        var attributedTitle: NSAttributedString?

        var titleFont: UIFont?
        var titleColor: UIColor?
        var titleShadowColor: UIColor?
        
        var image: UIImage?
        
        var backgroundImage: UIImage?
        var backgroundColor: UIColor?
        
        var titleInsets = NSDirectionalEdgeInsets.zero
        var imageInsets = NSDirectionalEdgeInsets.zero
        var contentInsets = NSDirectionalEdgeInsets.zero
    }
    
    private var styles = [XZContentStatus: StyleCollection]()
    
    public var textLabel: UILabel {
        get {
            if let textLabel = textLabelIfLoaded {
                return textLabel
            }
            let textLabel = UILabel.init()
            textLabelIfLoaded = textLabel
            return textLabel
        }
        set {
            textLabelIfLoaded = newValue
        }
    }
    
    public var imageView: UIImageView {
        get {
            if let imageView = imageViewIfLoaded {
                return imageView
            }
            let imageView = UIImageView.init()
            imageViewIfLoaded = imageView
            return imageView
        }
        set {
            imageViewIfLoaded = newValue
        }
    }
    
    public var backgroundImageView: UIImageView {
        get {
            if let imageView = backgroundImageViewIfLoaded {
                return imageView
            }
            let imageView = UIImageView.init()
            backgroundImageViewIfLoaded = imageView
            return imageView
        }
        set {
            backgroundImageViewIfLoaded = newValue
        }
    }
    
    public private(set) var textLabelIfLoaded: UILabel? {
        didSet {
            oldValue?.removeFromSuperview()
            if let textLabel = textLabelIfLoaded {
                let status = contentStatus
                textLabel.textColor = titleColor(for: status)
                textLabel.font = titleFont(for: status)
                textLabel.shadowColor = titleShadowColor(for: status)
                if let attributedTitle = attributedTitle(for: status) {
                    textLabel.attributedText = attributedTitle
                } else {
                    textLabel.text = title(for: status)
                }
                addSubview(textLabel)
            }
        }
    }
    
    public private(set) var imageViewIfLoaded: UIImageView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let imageView = imageViewIfLoaded {
                let status = contentStatus
                imageView.image = image(for: status)
                addSubview(imageView)
            }
        }
    }
    
    public private(set) var backgroundImageViewIfLoaded: UIImageView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let imageView = backgroundImageViewIfLoaded {
                imageView.frame = bounds
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                imageView.image = backgroundImage(for: contentStatus)
                insertSubview(imageView, at: 0)
            }
        }
    }
    
    public var contentStatus: XZContentStatus = .default {
        didSet {
            if contentStatus == .default {
                self.isHidden = true
            } else {
                self.isHidden = false
                if let style = styles[contentStatus] {
                    if let attributedTitle = style.attributedTitle {
                        textLabel.attributedText = attributedTitle
                    } else if let title = style.title {
                        textLabel.text = title
                    }
                    if let textLabel = textLabelIfLoaded {
                        textLabel.font = style.titleFont
                        textLabel.textColor = style.titleColor
                        textLabel.shadowColor = style.titleShadowColor
                    }
                    
                    if let image = style.image {
                        imageView.image = image
                    }
                    
                    if let backgroundImage = style.backgroundImage {
                        backgroundImageView.image = backgroundImage
                    }
                    self.backgroundColor = style.backgroundColor
                    
                    setNeedsLayout()
                }
            }
        }
    }
    
    public var imageInsets: NSDirectionalEdgeInsets {
        return styles[contentStatus]?.imageInsets ?? .zero
    }
    
    public var contentInsets: NSDirectionalEdgeInsets {
        return styles[contentStatus]?.contentInsets ?? .zero
    }
    
    public var textInsets: NSDirectionalEdgeInsets {
        return styles[contentStatus]?.titleInsets ?? .zero
    }
    
    /// 新创建的视图与 view 相同大小且背景色一致。
    ///
    /// - Parameter view: 新构造的视图所属的视图。
    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutTextImageViews()
    }
    
    private func styleCollection(for contentStatus: XZContentStatus) -> StyleCollection {
        if let styleCollection = styles[contentStatus] {
            return styleCollection
        }
        let styleCollection = StyleCollection.init()
        styles[contentStatus] = styleCollection
        return styleCollection
    }
    
    public func setTitle(_ title: String?, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.title = title
        styleCollection.attributedTitle = nil
        if self.contentStatus == contentStatus {
            textLabel.text = title
        }
    }
    public func title(for contentStatus: XZContentStatus) -> String? {
        return styles[contentStatus]?.title
    }
    
    public func setTitleInsets(_ titleEdgeInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.titleInsets = titleEdgeInsets
        if self.contentStatus == contentStatus {
            
        }
    }
    public func titleInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        return styles[contentStatus]?.titleInsets ?? .zero
    }
    
    public func setTitleColor(_ titleColor: UIColor?, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.titleColor = titleColor;
        if self.contentStatus == contentStatus {
            textLabel.textColor = titleColor
        }
    }
    public func titleColor(for contentStatus: XZContentStatus) -> UIColor? {
        return styles[contentStatus]?.titleColor
    }
    
    public func setTitleFont(_ titleFont: UIFont?, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.titleFont = titleFont
        if self.contentStatus == contentStatus {
            textLabel.font = titleFont
        }
    }
    public func titleFont(for contentStatus: XZContentStatus) -> UIFont? {
        return styles[contentStatus]?.titleFont
    }
    
    public func setTitleShadowColor(_ titleShadowColor: UIColor?, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.titleShadowColor = titleShadowColor
        if self.contentStatus == contentStatus {
            textLabel.shadowColor = titleShadowColor
        }
    }
    public func titleShadowColor(for contentStatus: XZContentStatus) -> UIColor? {
        return styles[contentStatus]?.titleShadowColor
    }
    
    public func setAttributedTitle(_ attributedTitle: NSAttributedString?, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.attributedTitle = attributedTitle
        styleCollection.title = nil
        if self.contentStatus == contentStatus {
            textLabel.attributedText = attributedTitle
        }
    }
    public func attributedTitle(for contentStatus: XZContentStatus) -> NSAttributedString? {
        return styles[contentStatus]?.attributedTitle
    }
    
    public func setImage(_ image: UIImage?, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.image = image
        if self.contentStatus == contentStatus {
            imageView.image = image
        }
    }
    public func image(for contentStatus: XZContentStatus) -> UIImage? {
        return styles[contentStatus]?.image
    }
    
    public func setImageInsets(_ imageEdgeInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.imageInsets = imageEdgeInsets
        if self.contentStatus == contentStatus {
            self.setNeedsLayout()
        }
    }
    public func imageInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        return styles[contentStatus]?.imageInsets ?? .zero
    }
    
    public func setBackgroundImage(_ backgroundImage: UIImage?, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.backgroundImage = backgroundImage
        if self.contentStatus == contentStatus {
            backgroundImageView.image = backgroundImage
        }
    }
    public func backgroundImage(for contentStatus: XZContentStatus) -> UIImage? {
        return styles[contentStatus]?.backgroundImage
    }
    
    public func setBackgroundColor(_ backgroundColor: UIColor?, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.backgroundColor = backgroundColor
        if self.contentStatus == contentStatus {
            self.backgroundColor = backgroundColor
        }
    }
    public func backgroundColor(for contentStatus: XZContentStatus) -> UIColor? {
        return styles[contentStatus]?.backgroundColor
    }
    
    public func setContentInsets(_ contentInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let styleCollection = styleCollection(for: contentStatus)
        styleCollection.contentInsets = contentInsets
        if self.contentStatus == contentStatus {
            setNeedsLayout()
        }
    }
    public func contentInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        return styles[contentStatus]?.contentInsets ?? .zero
    }
}

