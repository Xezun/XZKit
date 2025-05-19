//
//  XZContentStatusView.swift
//  AFNetworking
//
//  Created by Xezun on 2017/12/2.
//

import UIKit
import XZTextImageView

/// 呈现视图内容状态的视图。
@MainActor @objc open class XZContentStatusView: UIControl, XZTextImageView.Layout, XZContentStatusConfigurable {
    
    /// 当前呈现的内容状态。
    public var contentStatus: XZContentStatus = .default {
        didSet {
            if contentStatus == .default {
                isHidden = true
            } else {
                isHidden = false
                updateAppearance()
                setNeedsLayout()
            }
        }
    }
    
    private func updateAppearance() {
        let status = self.contentStatus
        
        if let attributedTitle = attributedTitle(for: status) {
            textLabel.font = titleFont(for: status)
            textLabel.textColor = titleColor(for: status)
            textLabel.shadowColor = titleShadowColor(for: status)
            
            textLabel.attributedText = attributedTitle
        } else if let title = title(for: status) {
            textLabel.text = title
            
            textLabel.font = titleFont(for: status)
            textLabel.textColor = titleColor(for: status)
            textLabel.shadowColor = titleShadowColor(for: status)
        }
        
        if let imageView = imageView(for: status) {
            imageViewIfLoaded = imageView
        } else if let image = image(for: status) {
            if let imageView = imageViewIfLoaded as? UIImageView {
                imageView.image = image
            } else {
                imageViewIfLoaded = UIImageView.init(image: image)
            }
        } else {
            imageViewIfLoaded = nil
        }
        
        if let backgroundImage = backgroundImage(for: status) {
            backgroundView.image = backgroundImage
        }
        self.backgroundColor = backgroundColor(for: status)
        
        setNeedsLayout()
    }
    
    public private(set) var textViewIfLoaded: UILabel? {
        didSet {
            oldValue?.removeFromSuperview()
            if let textLabel = textViewIfLoaded {
                addSubview(textLabel)
            }
//            updateAppearance()
        }
    }
    
    public private(set) var imageViewIfLoaded: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let imageView = imageViewIfLoaded {
                addSubview(imageView)
            }
//            updateAppearance()
        }
    }
    
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
    
    public var imageView: UIView {
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
    
    public var backgroundView: UIImageView {
        get {
            if let imageView = backgroundViewIfLoaded {
                return imageView
            }
            let imageView = UIImageView.init()
            backgroundViewIfLoaded = imageView
            return imageView
        }
        set {
            backgroundViewIfLoaded = newValue
        }
    }
    
    public private(set) var backgroundViewIfLoaded: UIImageView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let imageView = backgroundViewIfLoaded {
                imageView.frame = bounds
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                imageView.image = backgroundImage(for: contentStatus)
                insertSubview(imageView, at: 0)
            }
        }
    }
    
    public var imageInsets: NSDirectionalEdgeInsets {
        return configurations[contentStatus]?.imageInsets ?? .zero
    }
    
    public var contentInsets: NSDirectionalEdgeInsets {
        return configurations[contentStatus]?.contentInsets ?? .zero
    }
    
    public var textInsets: NSDirectionalEdgeInsets {
        return configurations[contentStatus]?.titleInsets ?? .zero
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
        self.layoutTextImage()
    }
    
    public func setTitle(_ title: String?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.title = title
        configuration.attributedTitle = nil
        updateAppearance()
    }
    
    public func title(for contentStatus: XZContentStatus) -> String? {
        return configurations[contentStatus]?.title
    }
    
    public func setTitleInsets(_ titleInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.titleInsets = titleInsets
        updateAppearance()
    }
    
    public func titleInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        if contentStatus == .default {
            return configurations[contentStatus]?.titleInsets ?? .zero
        }
        return configurations[contentStatus]?.titleInsets ?? titleInsets(for: .default)
    }
    
    public func setTitleColor(_ titleColor: UIColor?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.titleColor = titleColor;
        updateAppearance()
    }
    
    public func titleColor(for contentStatus: XZContentStatus) -> UIColor? {
        if contentStatus == .default {
            return configurations[contentStatus]?.titleColor
        }
        return configurations[contentStatus]?.titleColor ?? titleColor(for: .default)
    }
    
    public func setTitleFont(_ titleFont: UIFont?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.titleFont = titleFont
        updateAppearance()
    }
    
    public func titleFont(for contentStatus: XZContentStatus) -> UIFont? {
        if contentStatus == .default {
            return configurations[contentStatus]?.titleFont
        }
        return configurations[contentStatus]?.titleFont ?? titleFont(for: .default)
    }
    
    public func setTitleShadowColor(_ titleShadowColor: UIColor?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.titleShadowColor = titleShadowColor
        updateAppearance()
    }
    
    public func titleShadowColor(for contentStatus: XZContentStatus) -> UIColor? {
        if contentStatus == .default {
            return configurations[contentStatus]?.titleShadowColor
        }
        return configurations[contentStatus]?.titleShadowColor ?? titleShadowColor(for: .default)
    }
    
    public func setAttributedTitle(_ attributedTitle: NSAttributedString?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.attributedTitle = attributedTitle
        configuration.title = nil
        updateAppearance()
    }
    
    public func attributedTitle(for contentStatus: XZContentStatus) -> NSAttributedString? {
        return configurations[contentStatus]?.attributedTitle
    }
    
    public func setImage(_ image: UIImage?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.image = image
        updateAppearance()
    }
    
    public func image(for contentStatus: XZContentStatus) -> UIImage? {
        return configurations[contentStatus]?.image
    }
    
    public func setImageInsets(_ imageInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.imageInsets = imageInsets
        updateAppearance()
    }
    
    public func imageInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        if contentStatus == .default {
            return configurations[contentStatus]?.imageInsets ?? .zero
        }
        return configurations[contentStatus]?.imageInsets ?? imageInsets(for: .default)
    }
    
    public func setBackgroundImage(_ backgroundImage: UIImage?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.backgroundImage = backgroundImage
        updateAppearance()
    }
    
    public func backgroundImage(for contentStatus: XZContentStatus) -> UIImage? {
        if contentStatus == .default {
            return configurations[contentStatus]?.backgroundImage
        }
        return configurations[contentStatus]?.backgroundImage ?? backgroundImage(for: .default)
    }
    
    public func setBackgroundColor(_ backgroundColor: UIColor?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.backgroundColor = backgroundColor
        updateAppearance()
    }
    
    public func backgroundColor(for contentStatus: XZContentStatus) -> UIColor? {
        if contentStatus == .default {
            return configurations[contentStatus]?.backgroundColor
        }
        return configurations[contentStatus]?.backgroundColor ?? backgroundColor(for: .default)
    }
    
    public func setContentInsets(_ contentInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.contentInsets = contentInsets
        setNeedsLayout()
    }
    
    public func contentInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        if contentStatus == .default {
            return configurations[contentStatus]?.contentInsets ?? .zero
        }
        return configurations[contentStatus]?.contentInsets ?? contentInsets(for: .default)
    }
    
    public func setImageView(_ view: UIView?, for contentStatus: XZContentStatus) {
        let configuration = self.configuration(for: contentStatus)
        configuration.view = view
        setNeedsLayout()
    }
    
    public func imageView(for contentStatus: XZContentStatus) -> UIView? {
        if contentStatus == .default {
            return configurations[contentStatus]?.view
        }
        return configurations[contentStatus]?.view ?? configurations[.default]?.view
    }
    
    private class StateConfiguration {
        var title: String?
        var attributedTitle: NSAttributedString?
        var image: UIImage?

        var titleFont: UIFont?
        var titleColor: UIColor?
        var titleShadowColor: UIColor?
        var backgroundImage: UIImage?
        var backgroundColor: UIColor?
        
        var view: UIView?
        
        var titleInsets = NSDirectionalEdgeInsets.zero
        var imageInsets = NSDirectionalEdgeInsets.zero
        var contentInsets = NSDirectionalEdgeInsets.zero
    }
    
    private var configurations = [XZContentStatus: StateConfiguration]()
    
    private func configuration(for contentStatus: XZContentStatus) -> StateConfiguration {
        if let configuration = configurations[contentStatus] {
            return configuration
        }
        let configuration = StateConfiguration.init()
        configurations[contentStatus] = configuration
        return configuration
    }
    
}

