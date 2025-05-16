//
//  XZTextIconLayout.swift
//  XZKit
//
//  Created by Xezun on 2018/10/8.
//

import Foundation
import UIKit
import XZGeometry

/// 实现了一个包含文本和图片的视图布局逻辑。
/// - Note: 控件实现协议需重写 layoutSubviews 方法，并执行 layoutTextImageViews 方法。
/// - Note: 如果需要支持 AutoLayout 自适应大小，需要重写 intrinsicContentSize 方法，并返回 intrinsicTextImageSize 。
@MainActor public protocol XZTextIconLayout: UIView {
    
    /// 呈现文本的视图控件类型
    associatedtype TextView: UIView
    
    /// 呈现图片的视图控件类型
    associatedtype IconView: UIView
    
    /// 标题文本控件。
    var textViewIfLoaded: TextView? { get }
    
    /// 图片控件。
    var iconViewIfLoaded: IconView? { get }
    
    /// 视图内边距，默认 .zero 。
    var contentInsets: NSDirectionalEdgeInsets { get }
    
    /// 文本边距，默认 .zero 。
    var textInsets: NSDirectionalEdgeInsets { get }
    
    /// 图片边距，默认 .zero 。
    var iconInsets: NSDirectionalEdgeInsets { get }
    
    /// 文本相对图片的位置。默认 .bottom 底边。仅单值有效，否则按优先级 .bottom > .top > .trailing > .leading 生效。
    var textPosition: NSDirectionalRectEdge { get }
    
}

extension XZTextIconLayout {
    
    public var contentInsets: NSDirectionalEdgeInsets {
        return .zero
    }
    
    public var textInsets: NSDirectionalEdgeInsets {
        return .zero
    }
    
    public var iconInsets: NSDirectionalEdgeInsets {
        return .zero
    }
    
    public var textPosition: NSDirectionalRectEdge {
        return .bottom
    }
    
    /// 为控件提供计算自然大小的能力，用于重写控件 intrinsicContentSize 属性。
    public var textIconIntrinsicSize: CGSize {
        let iconSize = iconViewIfLoaded != nil ? iconViewIfLoaded!.intrinsicContentSize : .zero
        let textSize = textViewIfLoaded != nil ? textViewIfLoaded!.intrinsicContentSize : .zero
        if textPosition.contains(.bottom) || textPosition.contains(.top) {
            let width = max(iconSize.width, textSize.width) + contentInsets.leading + contentInsets.trailing
            let height = iconSize.height + textSize.height + contentInsets.top + contentInsets.bottom
            return CGSize.init(width: width, height: height)
        }
        let width = iconSize.width + textSize.width + contentInsets.leading + contentInsets.trailing
        let height = max(iconSize.height, textSize.height) + contentInsets.top + contentInsets.bottom
        return CGSize.init(width: width, height: height)
    }
    
    /// 为控件提供计算自适应大小的能力，用于重写 sizeThatFits(_:) 方法。
    public func textIconSizeThatFits(_ size: CGSize) -> CGSize {
        let imageSize = iconViewIfLoaded != nil ? iconViewIfLoaded!.sizeThatFits(.zero) : .zero
        // 设置 sizeThatFits 的大小，可能会影响结果。
        let titleSize = textViewIfLoaded != nil ? textViewIfLoaded!.sizeThatFits(.zero) : .zero
        if textPosition.contains(.bottom) || textPosition.contains(.top) {
            let width = max(imageSize.width, titleSize.width) + contentInsets.leading + contentInsets.trailing
            let height = imageSize.height + titleSize.height + contentInsets.top + contentInsets.bottom
            return CGSize.init(width: width, height: height)
        }
        let width = imageSize.width + titleSize.width + contentInsets.leading + contentInsets.trailing
        let height = max(imageSize.height, titleSize.height) + contentInsets.top + contentInsets.bottom
        return CGSize.init(width: width, height: height)
    }
    
    /// 为控件提供自动布局 textLabelIfLoaded 与 imageViewIfLoaded 的能力，用于重写 layoutSubviews() 方法。
    public func layoutTextIconViews() -> Void {
        let layoutDirection = self.effectiveUserInterfaceLayoutDirection;
        // 计算去掉边距的区域
        let layoutRect = self.bounds.inset(by: UIEdgeInsets(contentInsets, layoutDirection));
        
        if let iconView = iconViewIfLoaded {
            // 优先布局图片。
            let iconSize = iconView.sizeThatFits(layoutRect.size).scalingAspectRatio(inside: layoutRect.size)
            
            if let textView = textViewIfLoaded {
                // 图片和文字都有。
                
                // 对于 UILabel 来说 sizeThatFits(_:) 方法：
                // 如果单行显示，那么此方法返回的大小是完全显示所有内容的最适大小，也就是说，宽度可能比给定的大或者小，高度是文字高度；
                // 如果多行显示，那么返回的大小，宽度与给定的大小相同，高度则根据文字有多少行（不超过限定的行数）确定。
                let textSize = textView.sizeThatFits(layoutRect.size)
                
                if textPosition.contains(.bottom) {
                    // 垂直布局，标题在下。
                    let textWidth = min(textSize.width, layoutRect.width)
                    let textHeight = min(layoutRect.height - iconSize.height, textSize.height)
                    
                    let contentSize = CGSize(width: max(iconSize.width, textWidth), height: iconSize.height + textHeight)
                    let minY = layoutRect.minY + (layoutRect.height - contentSize.height) * 0.5
                    
                    iconView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - iconSize.width) * 0.5 + iconInsets.leading,
                        y: minY + iconInsets.top,
                        width: iconSize.width - iconInsets.leading - iconInsets.trailing,
                        height: iconSize.height - iconInsets.top - iconInsets.bottom
                    )
                    textView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - textWidth) * 0.5 + textInsets.leading,
                        y: minY + iconSize.height + textInsets.top, // 基于原有位置进行偏移
                        width: textWidth - textInsets.leading - textInsets.trailing,
                        height: textHeight - textInsets.top - textInsets.bottom
                    )
                    
                } else if textPosition.contains(.top) {
                    // 垂直布局，标题在上。
                    let textWidth = min(textSize.width, layoutRect.width)
                    let textHeight = min(layoutRect.height - iconSize.height, textSize.height)
                    
                    let contentSize = CGSize(width: max(iconSize.width, textWidth), height: iconSize.height + textHeight)
                    let maxY = layoutRect.maxY - (layoutRect.height - contentSize.height) * 0.5
                    
                    iconView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - iconSize.width) * 0.5 + iconInsets.leading,
                        y: maxY - iconSize.height + iconInsets.top,
                        width: iconSize.width - iconInsets.leading - iconInsets.trailing,
                        height: iconSize.height - iconInsets.top - iconInsets.bottom
                    )
                    textView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - textWidth) * 0.5 + textInsets.leading,
                        y: maxY - iconSize.height - textHeight + textInsets.top,
                        width: textWidth - textInsets.leading - textInsets.trailing,
                        height: textHeight - textInsets.top - textInsets.bottom
                    )
                    
                } else {
                    // 水平布局。
                    let textWidth = min(layoutRect.width - iconSize.width, textSize.width)
                    let textHeight = min(layoutRect.height, textSize.height)
                    
                    let contentSize = CGSize(width: iconSize.width + textWidth, height: max(iconSize.height, textHeight))
                    
                    if (textPosition.contains(.trailing) && layoutDirection == .leftToRight) || (textPosition.contains(.leading) && layoutDirection == .rightToLeft) {
                        // 标题在右
                        let minX = layoutRect.minX + (layoutRect.width - contentSize.width) * 0.5
                        iconView.frame = CGRect(
                            x: minX + iconInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - iconSize.height) * 0.5 + iconInsets.top,
                            width: iconSize.width - iconInsets.leading - iconInsets.trailing,
                            height: iconSize.height - iconInsets.top - iconInsets.bottom
                        )
                        textView.frame = CGRect(
                            x: minX + iconSize.width + textInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - textHeight) * 0.5 + textInsets.top,
                            width: textWidth - textInsets.leading - textInsets.trailing,
                            height: textHeight - textInsets.top - textInsets.bottom
                        )
                    } else {
                        // 标题在左
                        let maxX = layoutRect.maxX - (layoutRect.width - contentSize.width) * 0.5
                        iconView.frame = CGRect(
                            x: maxX - iconSize.width + iconInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - iconSize.height) * 0.5 + iconInsets.top,
                            width: iconSize.width - iconInsets.leading - iconInsets.trailing,
                            height: iconSize.height - iconInsets.top - iconInsets.bottom
                        )
                        textView.frame = CGRect(
                            x: maxX - iconSize.width - textWidth + textInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - textHeight) * 0.5 + textInsets.top,
                            width: textWidth - textInsets.leading - textInsets.trailing,
                            height: textHeight - textInsets.top - textInsets.bottom
                        )
                    }
                }
            } else {
                // 只有图片
                iconView.frame = CGRect.init(
                    x: layoutRect.minX + (layoutRect.width - iconSize.width) * 0.5 + iconInsets.leading,
                    y: layoutRect.minY + (layoutRect.height - iconSize.height) * 0.5 + iconInsets.top,
                    width: iconSize.width - iconInsets.trailing - iconInsets.leading,
                    height: iconSize.height - iconInsets.top - iconInsets.bottom
                )
            }
            
        } else if let textView = textViewIfLoaded {
            // 只有文字。
            let textSize = textView.sizeThatFits(layoutRect.size)
            
            let textWidth = min(textSize.width, layoutRect.width)
            let textHeight = min(textSize.height, layoutRect.height)
            
            textView.frame = CGRect(
                x: layoutRect.minX + (layoutRect.width - textWidth) * 0.5 + textInsets.leading,
                y: layoutRect.minY + (layoutRect.height - textHeight) * 0.5 + textInsets.top,
                width: textSize.width - textInsets.trailing - textInsets.leading,
                height: textSize.height - textInsets.top - textInsets.bottom
            )
        }
    }
}
