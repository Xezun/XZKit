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
    
    /// 获取将指定大小的内容按指定模式，在当前 CGRect 内的 frame 。
    ///
    /// - Parameters:
    ///   - size: 内容的大小。
    ///   - rect: 指定的区域。
    ///   - mode: 适配模式。
    public init(for contentSize: CGSize, fitting rect: CGRect, contentMode: UIView.ContentMode) {
        switch contentMode {
        case .scaleAspectFit:
            // 先尝试把当前宽度缩放到与容器同宽，判断高度是否大于容器的高度。
            let scaledHeight = rect.width * contentSize.height / contentSize.width;
            if scaledHeight > rect.height {
                // 高度比容器高，那么以容器的高为最大值，计算宽度。
                let scaledWidth = rect.height * contentSize.width / contentSize.height
                let x = (rect.width - scaledWidth) * 0.5 + rect.minX
                self = CGRect.init(x: x, y: rect.minY, width: scaledWidth, height: rect.height)
            } else {
                // 高度没有容器高，计算其在垂直方向居中的坐标。
                let y = (rect.height - scaledHeight) * 0.5 + rect.minY
                self = CGRect.init(x: rect.minX, y: y, width: rect.width, height: scaledHeight)
            }
            
        case .scaleAspectFill:
            // 高度比容器低，则以容器的高度为最大值，计算宽度，并计算其在水平方向居中的坐标。
            let scaledHeight = rect.width * contentSize.height / contentSize.width;
            if scaledHeight < rect.height {
                let scaledWidth = rect.height * contentSize.width / contentSize.height
                let x = (rect.width - scaledWidth) * 0.5 + rect.minX
                self = CGRect.init(x: x, y: rect.minY, width: scaledWidth, height: rect.height)
            } else {
                let y = (rect.height - scaledHeight) * 0.5 + rect.minY
                self = CGRect.init(x: rect.minX, y: y, width: rect.width, height: scaledHeight)
            }
            
        case .center:
            let x = (rect.width - contentSize.width) * 0.5 + rect.minX
            let y = (rect.height - contentSize.height) * 0.5 + rect.minY
            self = CGRect.init(x: x, y: y, width: contentSize.width, height: contentSize.height)
            
        case .top:
            let x = (rect.width - contentSize.width) * 0.5 + rect.minX
            self = CGRect.init(x: x, y: rect.minY, width: contentSize.width, height: contentSize.height)
            
        case .bottom:
            let x = (rect.width - contentSize.width) * 0.5 + rect.minX
            let y = rect.maxY - contentSize.height
            self = CGRect.init(x: x, y: y, width: contentSize.width, height: contentSize.height)
            
        case .left:
            let y = (rect.height - contentSize.height) * 0.5 + rect.minY
            self = CGRect.init(x: rect.minX, y: y, width: contentSize.width, height: contentSize.height)
            
        case .right:
            let x = rect.maxX - contentSize.height
            let y = (contentSize.height - contentSize.height) * 0.5 + rect.minY
            self = CGRect.init(x: x, y: y, width: contentSize.width, height: contentSize.height)
            
        case .topLeft:
            self = CGRect.init(x: rect.minX, y: rect.minY, width: contentSize.width, height: contentSize.height)
            
        case .topRight:
            let x = rect.maxX - contentSize.width
            self = CGRect.init(x: x, y: rect.minY, width: contentSize.width, height: contentSize.height)
            
        case .bottomLeft:
            let y = rect.maxY - contentSize.height
            self = CGRect.init(x: rect.minX, y: y, width: contentSize.width, height: contentSize.height)
            
        case .bottomRight:
            let x = rect.maxX - contentSize.width
            let y = rect.maxY - contentSize.height
            self = CGRect.init(x: x, y: y, width: contentSize.width, height: contentSize.height)
            
        default:
            self = rect
        }
    }
    
}

extension CGSize {
    
    /// 将当前 Size 等比缩小到指定的范围内，如果当前 Size 在范围内则不缩放。
    ///
    /// - Parameter maxSize: 宽高的最大值。
    /// - Returns: CGSize
    func scalingAspect(toFit maxSize: CGSize) -> CGSize {
        if self.width > maxSize.width {
            let width = maxSize.width
            let height = width * self.height / self.width
            if height <= maxSize.height {
                return CGSize.init(width: width, height: height)
            }
        }
        if self.height > maxSize.height {
            let height = maxSize.height
            let width = height * self.width / self.height
            if width <= maxSize.width {
                return CGSize.init(width: width, height: height)
            }
        }
        return self
    }
    
    /// 将当前 Size 等比缩小到指定的范围内，如果当前 Size 在范围内则不缩放。
    ///
    /// - Parameter maxSize: 宽高的最大值。
    /// - Returns: CGSize
    public mutating func scaleAspect(toFit maxSize: CGSize) {
        self = scalingAspect(toFit: maxSize)
    }
    
    /// 创建一个指定宽高比，以及指定大小以内的 CGSize 。
    ///
    /// - Parameters:
    ///   - aspectRatio: 宽高比。
    ///   - maxSize: 宽高最大值。
    public init(aspectRatio: CGSize, maxSize: CGSize) {
        let width = maxSize.width
        let height = width * aspectRatio.height / aspectRatio.width
        if height <= maxSize.height {
            self.init(width: width, height: height)
        } else {
            let width = maxSize.height * aspectRatio.width / aspectRatio.height
            self.init(width: width, height: maxSize.height)
        }
    }
    
}
