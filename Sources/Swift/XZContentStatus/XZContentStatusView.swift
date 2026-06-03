//
//  XZContentStatusView.swift
//  XZKit
//
//  Created by Xezun on 2026/6/10.
//

import UIKit

/// 用于呈现内容状态的视图需遵循的协议。
///
/// 全局默认状态视图，需要实现此协议，独立的自定义状态视图不需要实现本协议。
@MainActor public protocol XZContentStatusView: UIView {
    
    /// 必须能通过此方法进行初始化。
    init()
    
    /// 状态视图需要在此方法中为指定状态配置外观。
    /// - Parameter contentStatus: 内容状态
    func updateAppearance(for contentStatus: XZContentStatus)
    
}

extension XZContentStatus {
    
    /// 呈现视图内容状态的视图。
    @MainActor @objc(XZContentStatusRepresentationView) public class RepresentationView: UIView, XZContentStatusView {
        
        let iconView = UIImageView.init()
        let textView = UILabel.init()
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            
            iconView.contentMode = .scaleAspectFit
            addSubview(iconView)
            
            textView.textAlignment = .center
            textView.numberOfLines = 0
            addSubview(textView)
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func updateAppearance(for status: XZContentStatus) {
            let configuration = status.configuration
            
            if let image = configuration.image {
                iconView.isHidden = false
                
                if image.isSymbolImage {
                    if #available(iOS 17.0, *) {
                        if #available(iOS 18.0, *) {
                            iconView.setSymbolImage(image, contentTransition: .replace.magic(fallback: .offUp))
                        } else {
                            iconView.setSymbolImage(image, contentTransition: .replace)
                        }
                        if let addSymbolEffect = configuration.addSymbolEffect {
                            addSymbolEffect(iconView);
                        } else {
                            iconView.removeAllSymbolEffects(animated: false)
                        }
                    } else {
                        iconView.image = image
                    }
                } else if let images = image.images, images.count > 1 {
                    iconView.animationImages = images;
                    iconView.startAnimating()
                    iconView.animationRepeatCount = 0
                } else {
                    iconView.image = image
                }
            } else {
                iconView.isHidden = true
                iconView.image = nil;
            }
            
            textView.textColor = configuration.textColor
            textView.font      = configuration.font
            
            if let text = status.configuration.text, text.count > 0 {
                textView.isHidden = false
                textView.text = text
            } else {
                textView.isHidden = true
                textView.text = nil
            }
        }
        
        override public func sizeThatFits(_ size: CGSize) -> CGSize {
            // 可布局的区域：去 20 的边距，在剩下的区域内布局
            let layoutSize = size.insetBy(width: +20.0, height: +20.0)
            
            let hasIcon = !iconView.isHidden
            let hasText = !textView.isHidden
            
            // 扩大热区
            let minWidth  = layoutSize.width * 0.65
            let minHeight = layoutSize.height * 0.35
            
            // 图文模式
            if hasIcon && hasText {
                let iconSize = iconView.sizeThatFits(layoutSize).scalingAspectRatio(inside: layoutSize)
                
                // 如果可布局区域总高度小于40点，就不展示文本，因为展示文本需要40点（20间距+20文本高度），
                if layoutSize.height - iconSize.height < 40.0 {
                    return CGSize(width: max(minWidth, iconSize.width + 40.0), height: max(minHeight,iconSize.height + 20.0))
                }
                
                let textSize = textView.sizeThatFits(CGSize(width: layoutSize.width, height: 0))
                
                let width = max(iconSize.width, textSize.width)
                let height = iconSize.height + 20.0 + max(20, min(textSize.height, layoutSize.height - iconSize.height - 20.0));
                return CGSize(width: max(minWidth, width + 40.0), height: max(minHeight, height + 40.0))
            }
            
            if hasIcon {
                let iconSize = iconView.sizeThatFits(layoutSize).scalingAspectRatio(inside: layoutSize)
                return CGSize(width: max(minWidth, iconSize.width + 40.0), height: max(minHeight, iconSize.height + 40.0))
            }
            
            if hasText {
                // 只有文本，高度最少 20 点
                if layoutSize.height < 20.0 {
                    return .zero
                }
                let textSize = textView.sizeThatFits(CGSize(width: layoutSize.width, height: 0))
                
                let width  = min(textSize.width, layoutSize.width);
                let height = max(20.0, min(layoutSize.height, textSize.height))
                return CGSize(width: max(minWidth, width + 40.0), height: max(minHeight, height + 40.0));
            }
            
            return .zero
        }
        
        override public func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds.insetBy(dx: +20.0, dy: +20.0)
            let hasIcon = !iconView.isHidden
            let hasText = !textView.isHidden
            
            if hasIcon && hasText {
                let iconSize = iconView.sizeThatFits(bounds.size).scalingAspectRatio(inside: bounds.size)
                
                if bounds.size.height - iconSize.height < 40.0 {
                    iconView.frame = bounds.adjusting(iconSize, with: .center)
                    textView.frame = bounds.adjusting(.zero, with: .center)
                    return
                }
                
                var textSize = textView.sizeThatFits(CGSize(width: bounds.size.width, height: 0))
                textSize.width = min(bounds.size.width, textSize.width);
                textSize.height = max(20, min(textSize.height, bounds.size.height - iconSize.height - 20.0));
                
                let minY = bounds.midY - (iconSize.height + 20.0 + textSize.height) * 0.5;
                iconView.frame = CGRect(x: bounds.midX - iconSize.width * 0.5, y: minY, width: iconSize.width, height: iconSize.height)
                textView.frame = CGRect(x: bounds.midX - textSize.width * 0.5, y: minY + iconSize.height + 20.0, width: textSize.width, height: textSize.height)
                return
            }
            
            if hasIcon {
                let iconSize = iconView.sizeThatFits(bounds.size).scalingAspectRatio(inside: bounds.size)
                iconView.frame = bounds.adjusting(iconSize, with: .center)
                return
            }
            
            iconView.frame = bounds.adjusting(.zero, with: .center)
            
            if hasText, bounds.size.height >= 20 {
                var textSize = textView.sizeThatFits(CGSize(width: bounds.size.width, height: 0))
                textSize.width = min(textSize.width, bounds.size.width);
                textSize.height = max(20.0, min(bounds.size.height, textSize.height))
                textView.frame = bounds.adjusting(textSize, with: .center)
                return
            }
            
            textView.frame = bounds.adjusting(.zero, with: .center)
        }
        
    }

    // 容器。
    @MainActor @objc(XZContentStatusWrapperView) public class WrapperView: UIView {
        
        private weak var target: XZContentStatusRepresentable?
        private weak var targetView: UIView?
        private var statusView: UIView?
        private var tapGestureRecognizer: UIGestureRecognizer?
        
        var statusValue: XZContentStatus? {
            didSet {
                if statusValue == oldValue {
                    return
                }
                
                guard let targetView = self.targetView else { return }
                guard let statusValue = self.statusValue else { return }
                
                self.backgroundColor = statusValue.configuration.backgroundColor
                targetView.addSubview(self)
                
                var statusView: UIView! = nil
                if let view = statusValue.configuration.view {
                    statusView = view
                } else if let view = self.statusView, view.isKind(of: XZContentStatus.viewClass) {
                    statusView = view
                } else {
                    statusView = XZContentStatus.viewClass.init()
                }
                
                if self.statusView != statusView {
                    self.statusView?.removeFromSuperview()
                }
                
                if let newView = statusView as? XZContentStatusView {
                    newView.updateAppearance(for: statusValue)
                }
                
                if statusValue.isInteractive {
                    if let tapGestureRecognizer = self.tapGestureRecognizer {
                        tapGestureRecognizer.isEnabled = true
                        statusView.addGestureRecognizer(tapGestureRecognizer)
                    } else {
                        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerAction(_:)))
                        statusView.addGestureRecognizer(tapGestureRecognizer)
                        self.tapGestureRecognizer = tapGestureRecognizer
                    }
                } else if let tapGestureRecognizer = self.tapGestureRecognizer {
                    tapGestureRecognizer.isEnabled = false
                }
                
                let size = statusView.sizeThatFits(bounds.size)
                statusView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
                statusView.frame = bounds.adjusting(size, with: .center)
                addSubview(statusView)
                
                self.statusView = statusView
            }
        }
        
        init(for target: XZContentStatusRepresentable, view: UIView) {
            self.target = target
            self.targetView   = view
            super.init(frame: view.bounds)
            
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            view.addObserver(self, forKeyPath: "bounds", options: .new, context: &_context);
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func tapGestureRecognizerAction(_ sender: UITapGestureRecognizer) {
            guard let target = self.target else { return }
            guard let status = self.statusValue else { return }
            target.contentStatus = target.shouldPerformUpdates(for: status)
        }
        
        override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard context == &_context else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            guard let bounds = (change?[.newKey] as? NSValue)?.cgRectValue else { return }
            MainActor.assumeIsolated {
                self.frame = bounds
            }
        }
        
    }
    
}

nonisolated(unsafe) private var _context = 0
