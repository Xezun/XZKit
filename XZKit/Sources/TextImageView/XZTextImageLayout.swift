//
//  TextImageLayout.swift
//  XZKit
//
//  Created by Xezun on 2018/10/8.
//

import Foundation
import UIKit

/// 实现了一个包含文本和图片的视图布局逻辑。
/// - Note: 控件实现协议需重写 layoutSubviews 方法，并执行 layoutTextImageViews 方法。
/// - Note: 如果需要支持 AutoLayout 自适应大小，需要重写 intrinsicContentSize 方法，并返回 intrinsicTextImageSize 。
public protocol TextImageLayout: UIView {
    /// 标题文本控件。
    var textLabelIfLoaded: UILabel? { get }
    /// 图片控件。
    var imageViewIfLoaded: UIImageView? { get }
    /// 视图内边距，默认 .zero 。
    var contentInsets: XZEdgeInsets { get }
    /// 文本边距，默认 .zero 。
    var textInsets: XZEdgeInsets { get }
    /// 图片边距，默认 .zero 。
    var imageInsets: XZEdgeInsets { get }
    /// 文本控件在图片控件的哪一条边上，默认 .bottom ，优先级 .bottom > .top > .trailing > .leading 。
    var textLayoutEdge: XZRectEdge { get }
}

extension TextImageLayout {
    
    public var contentInsets: XZEdgeInsets {
        return .zero
    }

    public var textInsets: XZEdgeInsets {
        return .zero
    }

    public var imageInsets: XZEdgeInsets {
        return .zero
    }

    public var textLayoutEdge: XZRectEdge {
        return .bottom
    }

    /// 为控件提供计算自然大小的能力，用于重写控件 intrinsicContentSize 属性。
    public var intrinsicTextImageSize: CGSize {
        let imageSize = imageViewIfLoaded != nil ? imageViewIfLoaded!.intrinsicContentSize : .zero
        let titleSize = textLabelIfLoaded != nil ? textLabelIfLoaded!.intrinsicContentSize : .zero
        if textLayoutEdge.contains(.bottom) || textLayoutEdge.contains(.top) {
            let width = max(imageSize.width, titleSize.width) + contentInsets.leading + contentInsets.trailing
            let height = imageSize.height + titleSize.height + contentInsets.top + contentInsets.bottom
            return CGSize.init(width: width, height: height)
        } else {
            let width = imageSize.width + titleSize.width + contentInsets.leading + contentInsets.trailing
            let height = max(imageSize.height, titleSize.height) + contentInsets.top + contentInsets.bottom
            return CGSize.init(width: width, height: height)
        }
    }
    
    /// 为控件提供计算自适应大小的能力，用于重写 sizeThatFits(_:) 方法。
    public func textImageSizeThatFits(_ size: CGSize) -> CGSize {
        let imageSize = imageViewIfLoaded != nil ? imageViewIfLoaded!.sizeThatFits(.zero) : .zero
        // 设置 sizeThatFits 的大小，可能会影响结果。
        let titleSize = textLabelIfLoaded != nil ? textLabelIfLoaded!.sizeThatFits(.zero) : .zero
        if textLayoutEdge.contains(.bottom) || textLayoutEdge.contains(.top) {
            let width = max(imageSize.width, titleSize.width) + contentInsets.leading + contentInsets.trailing
            let height = imageSize.height + titleSize.height + contentInsets.top + contentInsets.bottom
            return CGSize.init(width: width, height: height)
        } else {
            let width = imageSize.width + titleSize.width + contentInsets.leading + contentInsets.trailing
            let height = max(imageSize.height, titleSize.height) + contentInsets.top + contentInsets.bottom
            return CGSize.init(width: width, height: height)
        }
    }
    
    /// 为控件提供自动布局 textLabelIfLoaded 与 imageViewIfLoaded 的能力，用于重写 layoutSubviews() 方法。
    public func layoutTextImageViews() {
        let layoutDirection = self.userInterfaceLayoutDirection
        // 去掉边距的区域
        let layoutRect = self.bounds.inset(by: UIEdgeInsets.init(contentInsets, layoutDirection: layoutDirection));
        
        if let imageView = imageViewIfLoaded {
            // 优先布局图片。
            let imageViewSize = imageView.sizeThatFits(layoutRect.size).scalingAspect(within: layoutRect.size)
            
            if let titleLabel = textLabelIfLoaded {
                // 图片和文字都有。
                
                // 对于 UILabel 来说 sizeThatFits(_:) 方法：
                // 如果单行显示，那么此方法返回的大小是完全显示所有内容的最适大小，也就是说，宽度可能比给定的大或者小，高度是文字高度；
                // 如果多行显示，那么返回的大小，宽度与给定的大小相同，高度则根据文字有多少行（不超过限定的行数）确定。
                let titleLabelSize = titleLabel.sizeThatFits(layoutRect.size)
                
                if textLayoutEdge.contains(.bottom) {
                    // 垂直布局，标题在下。
                    let titleLabelWidth = min(titleLabelSize.width, layoutRect.width)
                    let titleLabelHeight = min(layoutRect.height - imageViewSize.height, titleLabelSize.height)
                    
                    let contentSize = CGSize(width: max(imageViewSize.width, titleLabelWidth), height: imageViewSize.height + titleLabelHeight)
                    let minY = layoutRect.minY + (layoutRect.height - contentSize.height) * 0.5
                    
                    imageView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - imageViewSize.width) * 0.5 + imageInsets.leading,
                        y: minY + imageInsets.top,
                        width: imageViewSize.width - imageInsets.leading - imageInsets.trailing,
                        height: imageViewSize.height - imageInsets.top - imageInsets.bottom
                    )
                    titleLabel.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - titleLabelWidth) * 0.5 + textInsets.leading,
                        y: minY + imageViewSize.height + textInsets.top, // 基于原有位置进行偏移
                        width: titleLabelWidth - textInsets.leading - textInsets.trailing,
                        height: titleLabelHeight - textInsets.top - textInsets.bottom
                    )
                    
                } else if textLayoutEdge.contains(.top) {
                    // 垂直布局，标题在上。
                    let titleLabelWidth = min(titleLabelSize.width, layoutRect.width)
                    let titleLabelHeight = min(layoutRect.height - imageViewSize.height, titleLabelSize.height)
                    
                    let contentSize = CGSize(width: max(imageViewSize.width, titleLabelWidth), height: imageViewSize.height + titleLabelHeight)
                    let maxY = layoutRect.maxY - (layoutRect.height - contentSize.height) * 0.5
                    
                    imageView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - imageViewSize.width) * 0.5 + imageInsets.leading,
                        y: maxY - imageViewSize.height + imageInsets.top,
                        width: imageViewSize.width - imageInsets.leading - imageInsets.trailing,
                        height: imageViewSize.height - imageInsets.top - imageInsets.bottom
                    )
                    titleLabel.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - titleLabelWidth) * 0.5 + textInsets.leading,
                        y: maxY - imageViewSize.height - titleLabelHeight + textInsets.top,
                        width: titleLabelWidth - textInsets.leading - textInsets.trailing,
                        height: titleLabelHeight - textInsets.top - textInsets.bottom
                    )
                    
                } else {
                    // 水平布局。
                    let titleLabelWidth = min(layoutRect.width - imageViewSize.width, titleLabelSize.width)
                    let titleLabelHeight = min(layoutRect.height, titleLabelSize.height)
                    
                    let contentSize = CGSize(width: imageViewSize.width + titleLabelWidth, height: max(imageViewSize.height, titleLabelHeight))
                    
                    if (textLayoutEdge.contains(.trailing) && layoutDirection == .leftToRight) || (textLayoutEdge.contains(.leading) && layoutDirection == .rightToLeft) {
                        // 标题在右
                        let minX = layoutRect.minX + (layoutRect.width - contentSize.width) * 0.5
                        imageView.frame = CGRect(
                            x: minX + imageInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - imageViewSize.height) * 0.5 + imageInsets.top,
                            width: imageViewSize.width - imageInsets.leading - imageInsets.trailing,
                            height: imageViewSize.height - imageInsets.top - imageInsets.bottom
                        )
                        titleLabel.frame = CGRect(
                            x: minX + imageViewSize.width + textInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - titleLabelHeight) * 0.5 + textInsets.top,
                            width: titleLabelWidth - textInsets.leading - textInsets.trailing,
                            height: titleLabelHeight - textInsets.top - textInsets.bottom
                        )
                    } else {
                        // 标题在左
                        let maxX = layoutRect.maxX - (layoutRect.width - contentSize.width) * 0.5
                        imageView.frame = CGRect(
                            x: maxX - imageViewSize.width + imageInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - imageViewSize.height) * 0.5 + imageInsets.top,
                            width: imageViewSize.width - imageInsets.leading - imageInsets.trailing,
                            height: imageViewSize.height - imageInsets.top - imageInsets.bottom
                        )
                        titleLabel.frame = CGRect(
                            x: maxX - imageViewSize.width - titleLabelWidth + textInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - titleLabelHeight) * 0.5 + textInsets.top,
                            width: titleLabelWidth - textInsets.leading - textInsets.trailing,
                            height: titleLabelHeight - textInsets.top - textInsets.bottom
                        )
                    }
                }
            } else {
                // 只有图片
                imageView.frame = CGRect.init(
                    x: layoutRect.minX + (layoutRect.width - imageViewSize.width) * 0.5 + imageInsets.leading,
                    y: layoutRect.minY + (layoutRect.height - imageViewSize.height) * 0.5 + imageInsets.top,
                    width: imageViewSize.width - imageInsets.trailing - imageInsets.leading,
                    height: imageViewSize.height - imageInsets.top - imageInsets.bottom
                )
            }
            
        } else if let titleLabel = textLabelIfLoaded {
            // 只有文字。
            let titleLabelSize = titleLabel.sizeThatFits(layoutRect.size)
            
            let titleLabelWidth = min(titleLabelSize.width, layoutRect.width)
            let titleLabelHeight = min(titleLabelSize.height, layoutRect.height)
            
            titleLabel.frame = CGRect(
                x: layoutRect.minX + (layoutRect.width - titleLabelWidth) * 0.5 + textInsets.leading,
                y: layoutRect.minY + (layoutRect.height - titleLabelHeight) * 0.5 + textInsets.top,
                width: titleLabelSize.width - textInsets.trailing - textInsets.leading,
                height: titleLabelSize.height - textInsets.top - textInsets.bottom
            )
        }
    }
}
