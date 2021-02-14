//
//  XZKitGeometry.swift
//  XZKit
//
//  Created by 徐臻 on 2019/3/27.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

import Foundation

// MARK: CGGeometry
// AVFoundation.AVMakeRectWithAspectRatioInsideRect
//

extension XZKit.EdgeInsets {
    
    public init(_ edgeInsets: UIEdgeInsets, layoutDirection: UIUserInterfaceLayoutDirection) {
        switch (layoutDirection) {
        case .rightToLeft:
            self.init(top: edgeInsets.top, leading: edgeInsets.right, bottom: edgeInsets.bottom, trailing: edgeInsets.left)
        default:
            self.init(top: edgeInsets.top, leading: edgeInsets.left, bottom: edgeInsets.bottom, trailing: edgeInsets.right)
        }
    }
    
}

extension UIEdgeInsets {
    
    public init(_ edgeInsets: XZKit.EdgeInsets, layoutDirection: UIUserInterfaceLayoutDirection) {
        switch layoutDirection {
        case .rightToLeft:
            self.init(top: edgeInsets.top, left: edgeInsets.trailing, bottom: edgeInsets.bottom, right: edgeInsets.leading)
        default:
            self.init(top: edgeInsets.top, left: edgeInsets.leading, bottom: edgeInsets.bottom, right: edgeInsets.trailing)
        }
    }
    
}

extension CGRect {
    
    /// 判断某点是否在 CGRect 指定边距内。
    ///
    /// - Parameters:
    ///   - point: 待判定的点。
    ///   - edgeInsets: 边距。
    /// - Returns: 是否包含。
    public func contains(_ point: CGPoint, in edgeInsets: UIEdgeInsets) -> Bool {
        return (point.x < minX + edgeInsets.left) || (point.x > maxX - edgeInsets.right) || (point.y < minY + edgeInsets.top) || (point.y > maxY - edgeInsets.bottom);
    }
    
}

extension CGSize {
    
    /// 等比缩小到指定范围以内，如果已经在范围内则不缩小。
    /// - Parameter size: 范围
    /// - Returns: CGSize
    func scalingAspect(within size: CGSize) -> CGSize {
        if width <= size.width && height <= size.height {
            return self;
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return fitting(in: rect, contentMode: .scaleAspectFit).size
    }
    
    /// 等比缩小到指定范围以内，如果已经在范围内则不缩小。
    /// - Parameter size: 范围
    /// - Returns: CGSize
    public mutating func scaleAspect(within size: CGSize) {
        self = scalingAspect(within: size)
    }
    
    /// 创建一个指定宽高比，以及指定大小以内的 CGSize 。
    /// - Parameters:
    ///   - aspectRatio: 宽高比。
    ///   - maxSize: 宽高最大值。
    public init(ratio: CGSize, fits size: CGSize) {
        if ratio.width == 0 || ratio.height == 0 {
            self = size;
        } else if size.width == 0 || size.height == 0 {
            self = .zero;
        } else {
            let width = size.width
            let height = width * ratio.height / ratio.width
            if height <= size.height {
                self.init(width: width, height: height)
            } else {
                let width = size.height * ratio.width / ratio.height
                self.init(width: width, height: size.height)
            }
        }
    }
    
    /// 计算以指定适配模式进行适配时，当前大小的内容在 rect 区域中的 frame 。
    /// - Parameters:
    ///   - size: 内容的大小。
    ///   - rect: 指定的区域。
    ///   - contentMode: 适配模式。
    public func fitting(in rect: CGRect, contentMode: UIView.ContentMode) -> CGRect {
        switch contentMode {
        case .scaleAspectFit:
            if width == 0 {
                return CGRect(x: rect.midX, y: 0, width: 0, height: rect.height)
            }
            if height == 0 {
                return CGRect(x: 0, y: rect.midY, width: rect.width, height: 0)
            }
            // 先尝试把当前宽度缩放到与容器同宽，判断高度是否大于容器的高度。
            let scaledHeight = rect.width * (height / width);
            if scaledHeight > rect.height {
                // 高度比容器高，那么以容器的高为最大值，计算宽度。
                let scaledWidth = rect.height * width / height
                let x = (rect.width - scaledWidth) * 0.5 + rect.minX
                return CGRect.init(x: x, y: rect.minY, width: scaledWidth, height: rect.height)
            }
            // 高度没有容器高，计算其在垂直方向居中的坐标。
            let y = (rect.height - scaledHeight) * 0.5 + rect.minY
            return CGRect.init(x: rect.minX, y: y, width: rect.width, height: scaledHeight)
            
        case .scaleAspectFill:
            if width == 0 || height == 0 {
                return rect;
            }
            // 高度比容器低，则以容器的高度为最大值，计算宽度，并计算其在水平方向居中的坐标。
            let scaledHeight = rect.width * (height / width);
            if scaledHeight < rect.height {
                let scaledWidth = rect.height * width / height
                let x = (rect.width - scaledWidth) * 0.5 + rect.minX
                return CGRect.init(x: x, y: rect.minY, width: scaledWidth, height: rect.height)
            }
            let y = (rect.height - scaledHeight) * 0.5 + rect.minY
            return CGRect.init(x: rect.minX, y: y, width: rect.width, height: scaledHeight)
            
        case .center:
            let x = (rect.width - width) * 0.5 + rect.minX
            let y = (rect.height - height) * 0.5 + rect.minY
            return CGRect.init(x: x, y: y, width: width, height: height)
            
        case .top:
            let x = (rect.width - width) * 0.5 + rect.minX
            return CGRect.init(x: x, y: rect.minY, width: width, height: height)
            
        case .bottom:
            let x = (rect.width - width) * 0.5 + rect.minX
            let y = rect.maxY - height
            return CGRect.init(x: x, y: y, width: width, height: height)
            
        case .left:
            let y = (rect.height - height) * 0.5 + rect.minY
            return CGRect.init(x: rect.minX, y: y, width: width, height: height)
            
        case .right:
            let x = rect.maxX - height
            let y = (rect.height - height) * 0.5 + rect.minY
            return CGRect.init(x: x, y: y, width: width, height: height)
            
        case .topLeft:
            return CGRect.init(x: rect.minX, y: rect.minY, width: width, height: height)
            
        case .topRight:
            let x = rect.maxX - width
            return CGRect.init(x: x, y: rect.minY, width: width, height: height)
            
        case .bottomLeft:
            let y = rect.maxY - height
            return CGRect.init(x: rect.minX, y: y, width: width, height: height)
            
        case .bottomRight:
            let x = rect.maxX - width
            let y = rect.maxY - height
            return CGRect.init(x: x, y: y, width: width, height: height)
            
        default:
            return rect
        }
    }
}
