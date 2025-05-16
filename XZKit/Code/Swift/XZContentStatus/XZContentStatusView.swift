//
//  XZContentStatusView.swift
//  AFNetworking
//
//  Created by Xezun on 2017/12/2.
//

import UIKit
import XZTextIconView

/// 呈现视图内容状态的视图。
@MainActor @objc open class XZContentStatusView: UIControl, XZTextIconLayout, XZContentStatusConfigurable {
    
    private class Style {
        var title: String?
        var attributedTitle: NSAttributedString?
        var image: UIImage?

        var titleFont: UIFont?
        var titleColor: UIColor?
        var titleShadowColor: UIColor?
        var backgroundImage: UIImage?
        var backgroundColor: UIColor?
        
        var titleInsets = NSDirectionalEdgeInsets.zero
        var imageInsets = NSDirectionalEdgeInsets.zero
        var contentInsets = NSDirectionalEdgeInsets.zero
    }
    
    private var statedStyles = [XZContentStatus: Style]()
    
    public var textLabel: UILabel {
        get {
            if let textLabel = textViewIfLoaded {
                return textLabel
            }
            let textLabel = UILabel.init()
            textViewIfLoaded = textLabel
            return textLabel
        }
        set {
            textViewIfLoaded = newValue
        }
    }
    
    public var imageView: UIImageView {
        get {
            if let imageView = iconViewIfLoaded {
                return imageView
            }
            let imageView = UIImageView.init()
            iconViewIfLoaded = imageView
            return imageView
        }
        set {
            iconViewIfLoaded = newValue
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
    
    public private(set) var textViewIfLoaded: UILabel? {
        didSet {
            oldValue?.removeFromSuperview()
            if let textLabel = textViewIfLoaded {
                let status = contentStatus
                textLabel.font = titleFont(for: status)
                textLabel.textColor = titleColor(for: status)
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
    
    public private(set) var iconViewIfLoaded: UIImageView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let imageView = iconViewIfLoaded {
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
    
    /// 当前呈现的内容状态。
    public var contentStatus: XZContentStatus = .default {
        didSet {
            if contentStatus == .default {
                self.isHidden = true
            } else {
                self.isHidden = false
                
                let contentStatus = self.contentStatus
                
                // 如果 textLabel 没有内容，就不需要加载
                if let attributedTitle = attributedTitle(for: contentStatus) {
                    textLabel.attributedText = attributedTitle
                } else if let title = title(for: contentStatus) {
                    textLabel.text = title
                }
                if let textLabel = textViewIfLoaded {
                    textLabel.font = titleFont(for: contentStatus)
                    textLabel.textColor = titleColor(for: contentStatus)
                    textLabel.shadowColor = titleShadowColor(for: contentStatus)
                }
                
                if let image = image(for: contentStatus) {
                    imageView.image = image
                }
                
                if let backgroundImage = backgroundImage(for: contentStatus) {
                    backgroundImageView.image = backgroundImage
                }
                self.backgroundColor = backgroundColor(for: contentStatus)
                
                setNeedsLayout()
            }
        }
    }
    
    public var iconInsets: NSDirectionalEdgeInsets {
        return statedStyles[contentStatus]?.imageInsets ?? .zero
    }
    
    public var contentInsets: NSDirectionalEdgeInsets {
        return statedStyles[contentStatus]?.contentInsets ?? .zero
    }
    
    public var textInsets: NSDirectionalEdgeInsets {
        return statedStyles[contentStatus]?.titleInsets ?? .zero
    }
    
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
        self.layoutTextIconViews()
    }
    
    private func style(for contentStatus: XZContentStatus) -> Style {
        if let style = statedStyles[contentStatus] {
            return style
        }
        let style = Style.init()
        statedStyles[contentStatus] = style
        return style
    }
    
    public func setTitle(_ title: String?, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.title = title
        style.attributedTitle = nil
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            textLabel.text = title
            break
        default:
            break
        }
    }
    public func title(for contentStatus: XZContentStatus) -> String? {
        return statedStyles[contentStatus]?.title
    }
    
    public func setTitleInsets(_ titleInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.titleInsets = titleInsets
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            setNeedsLayout()
            break
        default:
            break
        }
    }
    public func titleInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        if contentStatus == .default {
            return statedStyles[contentStatus]?.titleInsets ?? .zero
        }
        return statedStyles[contentStatus]?.titleInsets ?? titleInsets(for: .default)
    }
    
    public func setTitleColor(_ titleColor: UIColor?, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.titleColor = titleColor;
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            textLabel.textColor = self.titleColor(for: contentStatus)
            break
        default:
            break
        }
    }
    public func titleColor(for contentStatus: XZContentStatus) -> UIColor? {
        if contentStatus == .default {
            return statedStyles[contentStatus]?.titleColor
        }
        return statedStyles[contentStatus]?.titleColor ?? titleColor(for: .default)
    }
    
    public func setTitleFont(_ titleFont: UIFont?, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.titleFont = titleFont
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            textLabel.font = self.titleFont(for: contentStatus)
            break
        default:
            break
        }
    }
    public func titleFont(for contentStatus: XZContentStatus) -> UIFont? {
        if contentStatus == .default {
            return statedStyles[contentStatus]?.titleFont
        }
        return statedStyles[contentStatus]?.titleFont ?? titleFont(for: .default)
    }
    
    public func setTitleShadowColor(_ titleShadowColor: UIColor?, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.titleShadowColor = titleShadowColor
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            textLabel.shadowColor = self.titleShadowColor(for: contentStatus)
            break
        default:
            break
        }
    }
    public func titleShadowColor(for contentStatus: XZContentStatus) -> UIColor? {
        if contentStatus == .default {
            return statedStyles[contentStatus]?.titleShadowColor
        }
        return statedStyles[contentStatus]?.titleShadowColor ?? titleShadowColor(for: .default)
    }
    
    public func setAttributedTitle(_ attributedTitle: NSAttributedString?, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.attributedTitle = attributedTitle
        style.title = nil
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            textLabel.attributedText = attributedTitle
            break
        default:
            break
        }
    }
    public func attributedTitle(for contentStatus: XZContentStatus) -> NSAttributedString? {
        return statedStyles[contentStatus]?.attributedTitle
    }
    
    public func setImage(_ image: UIImage?, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.image = image
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            imageView.image = image
            break
        default:
            break
        }
    }
    public func image(for contentStatus: XZContentStatus) -> UIImage? {
        return statedStyles[contentStatus]?.image
    }
    
    public func setImageInsets(_ imageInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.imageInsets = imageInsets
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            self.setNeedsLayout()
            break
        default:
            break
        }
    }
    public func imageInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        if contentStatus == .default {
            return statedStyles[contentStatus]?.imageInsets ?? .zero
        }
        return statedStyles[contentStatus]?.imageInsets ?? imageInsets(for: .default)
    }
    
    public func setBackgroundImage(_ backgroundImage: UIImage?, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.backgroundImage = backgroundImage
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            backgroundImageView.image = self.backgroundImage(for: contentStatus)
            break
        default:
            break
        }
    }
    public func backgroundImage(for contentStatus: XZContentStatus) -> UIImage? {
        if contentStatus == .default {
            return statedStyles[contentStatus]?.backgroundImage
        }
        return statedStyles[contentStatus]?.backgroundImage ?? backgroundImage(for: .default)
    }
    
    public func setBackgroundColor(_ backgroundColor: UIColor?, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.backgroundColor = backgroundColor
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            self.backgroundColor = self.backgroundColor(for: contentStatus)
            break
        default:
            break
        }
    }
    public func backgroundColor(for contentStatus: XZContentStatus) -> UIColor? {
        if contentStatus == .default {
            return statedStyles[contentStatus]?.backgroundColor
        }
        return statedStyles[contentStatus]?.backgroundColor ?? backgroundColor(for: .default)
    }
    
    public func setContentInsets(_ contentInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let style = self.style(for: contentStatus)
        style.contentInsets = contentInsets
        switch self.contentStatus {
        case .default:
            break
        case contentStatus:
            setNeedsLayout()
            break
        default:
            break
        }
    }
    public func contentInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        if contentStatus == .default {
            return statedStyles[contentStatus]?.contentInsets ?? .zero
        }
        return statedStyles[contentStatus]?.contentInsets ?? contentInsets(for: .default)
    }
}

@MainActor public protocol XZContentStatusConfigurable: AnyObject {
    func setTitle(_ title: String?, for contentStatus: XZContentStatus)
    func title(for contentStatus: XZContentStatus) -> String?
    
    func setTitleInsets(_ titleInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus)
    func titleInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets
    
    func setTitleColor(_ titleColor: UIColor?, for contentStatus: XZContentStatus)
    func titleColor(for contentStatus: XZContentStatus) -> UIColor?
    
    func setTitleFont(_ titleFont: UIFont?, for contentStatus: XZContentStatus)
    func titleFont(for contentStatus: XZContentStatus) -> UIFont?
    
    func setTitleShadowColor(_ titleShadowColor: UIColor?, for contentStatus: XZContentStatus)
    func titleShadowColor(for contentStatus: XZContentStatus) -> UIColor?
    
    func setAttributedTitle(_ attributedTitle: NSAttributedString?, for contentStatus: XZContentStatus)
    func attributedTitle(for contentStatus: XZContentStatus) -> NSAttributedString?
    
    func setImage(_ image: UIImage?, for contentStatus: XZContentStatus)
    func image(for contentStatus: XZContentStatus) -> UIImage?
    
    func setImageInsets(_ imageInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus)
    func imageInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets
    
    func setBackgroundImage(_ backgroundImage: UIImage?, for contentStatus: XZContentStatus)
    func backgroundImage(for contentStatus: XZContentStatus) -> UIImage?
    
    func setBackgroundColor(_ backgroundColor: UIColor?, for contentStatus: XZContentStatus)
    func backgroundColor(for contentStatus: XZContentStatus) -> UIColor?
    
    func setContentInsets(_ contentInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus)
    func contentInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets
}
