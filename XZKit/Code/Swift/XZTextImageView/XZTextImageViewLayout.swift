//
//  XZTextImageView.Layout.swift
//  XZKit
//
//  Created by Xezun on 2018/10/8.
//

import Foundation
import UIKit
import XZGeometry


extension XZTextImageView {
    
    public enum Style {
        /// 文字在图片的前面（通常为左边）
        case leading
        /// 文字在图片的后面（通常为右边）
        case trailing
        /// 文字在图片的顶部
        case top
        /// 文字在图片的底部，默认
        case bottom
    }
    
    /// 实现了一个包含文本和图片的视图布局逻辑。
    /// - Note: 控件实现协议需重写 layoutSubviews 方法，并执行 layoutTextImage 方法。
    /// - Note: 如果需要支持 AutoLayout 自适应大小，需要重写 intrinsicContentSize 方法，并返回 intrinsicTextImageSize 。
    @MainActor public protocol Layout: UIView {
        
        /// 呈现文本的视图控件类型
        associatedtype TextView: UIView
        
        /// 呈现图片的视图控件类型
        associatedtype ImageView: UIView
        
        /// 标题文本控件。
        var textViewIfLoaded: TextView? { get }
        
        /// 图片控件。
        var imageViewIfLoaded: ImageView? { get }
        
        /// 视图内边距，默认 .zero 。
        var contentInsets: NSDirectionalEdgeInsets { get }
        
        /// 文本边距，默认 .zero 。
        var textInsets: NSDirectionalEdgeInsets { get }
        
        /// 图片边距，默认 .zero 。
        var imageInsets: NSDirectionalEdgeInsets { get }
        
        /// 文字图片的位置关系。
        var style: XZTextImageView.Style { get }
        
    }
    
}

extension XZTextImageView.Layout {
    
    public var contentInsets: NSDirectionalEdgeInsets {
        return .zero
    }
    
    public var textInsets: NSDirectionalEdgeInsets {
        return .zero
    }
    
    public var imageInsets: NSDirectionalEdgeInsets {
        return .zero
    }
    
    public var style: XZTextImageView.Style {
        return .bottom
    }
    
    /// 为控件提供计算自然大小的能力，用于重写控件 intrinsicContentSize 属性。
    public var textImageIntrinsicSize: CGSize {
        let contentInsets = self.contentInsets
        let size = self.frame.size
        
        let imageSize: CGSize = imageViewIfLoaded?.sizeThatFits(size) ?? .zero
        let textSize: CGSize = textViewIfLoaded?.sizeThatFits(size) ?? .zero
        
        if style == .bottom || style == .top {
            let width = max(imageSize.width, textSize.width) + contentInsets.leading + contentInsets.trailing
            let height = imageSize.height + textSize.height + contentInsets.top + contentInsets.bottom
            return CGSize.init(width: width, height: height)
        }

        let width = imageSize.width + textSize.width + contentInsets.leading + contentInsets.trailing
        let height = max(imageSize.height, textSize.height) + contentInsets.top + contentInsets.bottom
        return CGSize.init(width: width, height: height)
    }
    
    /// 为控件提供计算自适应大小的能力，用于重写 sizeThatFits(_:) 方法。
    public func textImageSizeThatFits(_ size: CGSize) -> CGSize {
        let contentInsets = self.contentInsets
        
        let imageSize: CGSize = imageViewIfLoaded?.sizeThatFits(size) ?? .zero
        let textSize: CGSize = textViewIfLoaded?.sizeThatFits(size) ?? .zero
        
        if style == .bottom || style == .top {
            let width = max(imageSize.width, textSize.width) + contentInsets.leading + contentInsets.trailing
            let height = imageSize.height + textSize.height + contentInsets.top + contentInsets.bottom
            return CGSize.init(width: width, height: height)
        }
        
        let width = imageSize.width + textSize.width + contentInsets.leading + contentInsets.trailing
        let height = max(imageSize.height, textSize.height) + contentInsets.top + contentInsets.bottom
        return CGSize.init(width: width, height: height)
    }
    
    /// 为控件提供自动布局 textLabelIfLoaded 与 imageViewIfLoaded 的能力，用于重写 layoutSubviews() 方法。
    public func layoutTextImage() -> Void {
        let layoutDirection = self.effectiveUserInterfaceLayoutDirection;
        let contentInsets = self.contentInsets
        let style = self.style
        
        // 计算去掉边距的区域
        let layoutRect = self.bounds.inset(by: UIEdgeInsets(contentInsets, layoutDirection));
        
        if let imageView = imageViewIfLoaded {
            // 优先布局图片。
            let imageSize = imageView.sizeThatFits(layoutRect.size).scalingAspectRatio(inside: layoutRect.size)
            
            if let textView = textViewIfLoaded {
                // 图片和文字都有。
                
                // 对于 UILabel 来说 sizeThatFits(_:) 方法：
                // 如果单行显示，那么此方法返回的大小是完全显示所有内容的最适大小，也就是说，宽度可能比给定的大或者小，高度是文字高度；
                // 如果多行显示，那么返回的大小，宽度与给定的大小相同，高度则根据文字有多少行（不超过限定的行数）确定。
                let textSize = textView.sizeThatFits(layoutRect.size)
                
                if style == .bottom {
                    // 垂直布局，标题在下。
                    let textWidth = min(textSize.width, layoutRect.width)
                    let textHeight = max(min(layoutRect.height - imageSize.height, textSize.height), 0)
                    
                    let contentSize = CGSize(width: max(imageSize.width, textWidth), height: imageSize.height + textHeight)
                    let minY = layoutRect.minY + (layoutRect.height - contentSize.height) * 0.5
                    
                    let imageInsets = self.imageInsets
                    let textInsets = self.textInsets
                    
                    imageView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - imageSize.width) * 0.5 + imageInsets.leading,
                        y: minY + imageInsets.top,
                        width: imageSize.width - imageInsets.leading - imageInsets.trailing,
                        height: imageSize.height - imageInsets.top - imageInsets.bottom
                    )
                    textView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - textWidth) * 0.5 + textInsets.leading,
                        y: minY + imageSize.height + textInsets.top, // 基于原有位置进行偏移
                        width: textWidth - textInsets.leading - textInsets.trailing,
                        height: textHeight - textInsets.top - textInsets.bottom
                    )
                } else if style == .top {
                    // 垂直布局，标题在上。
                    let textWidth = min(textSize.width, layoutRect.width)
                    let textHeight = max(min(layoutRect.height - imageSize.height, textSize.height), 0)
                    
                    let contentSize = CGSize(width: max(imageSize.width, textWidth), height: imageSize.height + textHeight)
                    let maxY = layoutRect.maxY - (layoutRect.height - contentSize.height) * 0.5
                    
                    let imageInsets = self.imageInsets
                    let textInsets = self.textInsets
                    
                    imageView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - imageSize.width) * 0.5 + imageInsets.leading,
                        y: maxY - imageSize.height + imageInsets.top,
                        width: imageSize.width - imageInsets.leading - imageInsets.trailing,
                        height: imageSize.height - imageInsets.top - imageInsets.bottom
                    )
                    textView.frame = CGRect(
                        x: layoutRect.minX + (layoutRect.width - textWidth) * 0.5 + textInsets.leading,
                        y: maxY - imageSize.height - textHeight + textInsets.top,
                        width: textWidth - textInsets.leading - textInsets.trailing,
                        height: textHeight - textInsets.top - textInsets.bottom
                    )
                } else {
                    // 水平布局。
                    let textWidth = max(min(layoutRect.width - imageSize.width, textSize.width), 0)
                    let textHeight = min(layoutRect.height, textSize.height)
                    
                    let contentSize = CGSize(width: imageSize.width + textWidth, height: max(imageSize.height, textHeight))
                    
                    let imageInsets = self.imageInsets
                    let textInsets = self.textInsets
                    
                    if (style == .trailing && layoutDirection == .leftToRight) || (style == .leading && layoutDirection == .rightToLeft) {
                        // 标题在右
                        let minX = layoutRect.minX + (layoutRect.width - contentSize.width) * 0.5
                        imageView.frame = CGRect(
                            x: minX + imageInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - imageSize.height) * 0.5 + imageInsets.top,
                            width: imageSize.width - imageInsets.leading - imageInsets.trailing,
                            height: imageSize.height - imageInsets.top - imageInsets.bottom
                        )
                        textView.frame = CGRect(
                            x: minX + imageSize.width + textInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - textHeight) * 0.5 + textInsets.top,
                            width: textWidth - textInsets.leading - textInsets.trailing,
                            height: textHeight - textInsets.top - textInsets.bottom
                        )
                    } else {
                        // 标题在左
                        let maxX = layoutRect.maxX - (layoutRect.width - contentSize.width) * 0.5
                        imageView.frame = CGRect(
                            x: maxX - imageSize.width + imageInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - imageSize.height) * 0.5 + imageInsets.top,
                            width: imageSize.width - imageInsets.leading - imageInsets.trailing,
                            height: imageSize.height - imageInsets.top - imageInsets.bottom
                        )
                        textView.frame = CGRect(
                            x: maxX - imageSize.width - textWidth + textInsets.leading,
                            y: layoutRect.minY + (layoutRect.height - textHeight) * 0.5 + textInsets.top,
                            width: textWidth - textInsets.leading - textInsets.trailing,
                            height: textHeight - textInsets.top - textInsets.bottom
                        )
                    }
                }
            } else {
                let imageInsets = self.imageInsets
                // 只有图片
                imageView.frame = CGRect.init(
                    x: layoutRect.minX + (layoutRect.width - imageSize.width) * 0.5 + imageInsets.leading,
                    y: layoutRect.minY + (layoutRect.height - imageSize.height) * 0.5 + imageInsets.top,
                    width: imageSize.width - imageInsets.trailing - imageInsets.leading,
                    height: imageSize.height - imageInsets.top - imageInsets.bottom
                )
            }
        } else if let textView = textViewIfLoaded {
            // 只有文字。
            let textSize = textView.sizeThatFits(layoutRect.size)
            
            let textWidth = min(textSize.width, layoutRect.width)
            let textHeight = min(textSize.height, layoutRect.height)
            
            let textInsets = self.textInsets
            
            textView.frame = CGRect(
                x: layoutRect.minX + (layoutRect.width - textWidth) * 0.5 + textInsets.leading,
                y: layoutRect.minY + (layoutRect.height - textHeight) * 0.5 + textInsets.top,
                width: textSize.width - textInsets.trailing - textInsets.leading,
                height: textSize.height - textInsets.top - textInsets.bottom
            )
        }
    }
}
