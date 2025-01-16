//
//  Geometry.swift
//  XZKit
//
//  Created by Xezun on 2019/3/27.
//  Copyright © 2019 Xezun Individual. All rights reserved.
//

import Foundation
import UIKit

// MARK: CGGeometry
// AVFoundation.AVMakeRectWithAspectRatioInsideRect

extension NSDirectionalEdgeInsets {
    
    /// 通过 UIEdgeInsets 构造。
    /// - Parameters:
    ///   - edgeInsets: 边距
    ///   - layoutDirection: 布局方向
    public init(_ edgeInsets: UIEdgeInsets, _ layoutDirection: UIUserInterfaceLayoutDirection) {
        switch (layoutDirection) {
        case .rightToLeft:
            self.init(top: edgeInsets.top, leading: edgeInsets.right, bottom: edgeInsets.bottom, trailing: edgeInsets.left)
        default:
            self.init(top: edgeInsets.top, leading: edgeInsets.left, bottom: edgeInsets.bottom, trailing: edgeInsets.right)
        }
    }
    
}

extension UIEdgeInsets {
    
    /// 通过 XZEdgeInsets 构造。
    /// - Parameters:
    ///   - edgeInsets: XZEdgeInsets 边距
    ///   - layoutDirection: 布局方向
    public init(_ edgeInsets: NSDirectionalEdgeInsets, _ layoutDirection: UIUserInterfaceLayoutDirection) {
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
    public func scalingAspect(toFit size: CGSize) -> CGSize {
        if size.width == 0 || size.height == 0 {
            return .zero
        }
        if width == 0 {
            return CGSize(width: 0, height: height)
        }
        if height == 0 {
            return CGSize(width: width, height: 0)
        }
        if width <= size.width && height <= size.height {
            return self;
        }
        let w = size.height * (width / height);
        if w > size.width {
            return CGSize(width: size.width, height: size.width * (height / width))
        }
        return CGSize(width: w, height: size.height)
    }
    
    /// 等比缩小到指定范围以内，如果已经在范围内则不缩小。
    /// - Parameter size: 范围
    /// - Returns: CGSize
    public mutating func scaleAspect(within size: CGSize) {
        self = scalingAspect(toFit: size)
    }
    
    /// 创建一个指定宽高比，以及指定大小以内的 CGSize 。
    /// - Parameters:
    ///   - aspectRatio: 宽高比。
    ///   - maxSize: 宽高最大值。
    public init(_ size: CGSize, ratio: CGSize) {
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
    
}


extension CGRect {
    
    /// 在当前区域内，计算指定大小的内容，按指定模式进行适配时的方位。
    /// - Parameters:
    ///   - size: 待适配内容的大小
    ///   - contentMode: 适配模式
    public func adjusting(_ size: CGSize, using contentMode: UIView.ContentMode) -> CGRect {
        switch (contentMode) {
        case .scaleToFill:
            return self;
            
        case .scaleAspectFit:
            if (size.width == 0) {
                return CGRect(x: self.minX, y: self.midY, width: 0, height: 0)
            }
            if (size.height == 0) {
                return CGRect(x: self.midX, y: self.minY, width: 0, height: 0)
            }
            let height = self.size.width * (size.height / size.width)
            if (height > self.size.height) {
                // 高度比容器高，那么以容器的高为最大值，计算宽度。
                let width = self.size.height * size.width / size.height
                let x = (self.size.width - width) * 0.5 + self.minX
                return CGRect(x: x, y: self.minY, width: width, height: self.size.height)
            }
            // 高度没有容器高，计算其在垂直方向居中的坐标。
            let y = (self.size.height - height) * 0.5 + self.minY
            return CGRect(x: self.minX, y: y, width: self.size.width, height: height)
            
        case .scaleAspectFill:
            if size.width == 0 {
                return CGRect(x: self.minX, y: self.minY, width: 0, height: self.height)
            }
            if size.height == 0 {
                return CGRect(x: self.minX, y: self.maxY, width: self.width, height: 0)
            }
            // 高度比容器低，则以容器的高度为最大值，计算宽度，并计算其在水平方向居中的坐标。
            let height = self.size.width * (size.height / size.width)
            if (height < self.size.height) {
                let width = self.size.height * size.width / size.height
                let x = (self.size.width - width) * 0.5 + self.minX
                return CGRect(x: x, y: self.minY, width: width, height: self.size.height)
            }
            let y = (self.size.height - height) * 0.5 + self.minY
            return CGRect(x: self.minX, y: y, width: self.size.width, height: height)
            
        case .center:
            let x = (self.size.width - size.width) * 0.5 + self.minX
            let y = (self.size.height - size.height) * 0.5 + self.minY
            return CGRect(x: x, y: y, width: size.width, height: size.height)
            
        case .top:
            let x = (self.size.width - size.width) * 0.5 + self.minX
            return CGRect(x: x, y: self.minY, width: size.width, height: size.height)
            
        case .bottom:
            let x = (self.size.width - size.width) * 0.5 + self.minX
            let y = self.maxY - size.height
            return CGRect(x: x, y: y, width: size.width, height: size.height)
            
        case .left:
            let y = (self.size.height - size.height) * 0.5 + self.minY
            return CGRect(x: self.minX, y: y, width: size.width, height: size.height)
            
        case .right:
            let x = self.maxX - size.width
            let y = (self.size.height - size.height) * 0.5 + self.minY
            return CGRect(x: x, y: y, width: size.width, height: size.height)
            
        case .topLeft:
            return CGRect(x: self.minX, y: self.minY, width: size.width, height: size.height)
            
        case .topRight:
            let x = self.maxX - size.width
            return CGRect(x: x, y: self.minY, width: size.width, height: size.height)
            
        case .bottomLeft:
            let y = self.maxY - size.height
            return CGRect(x: self.minX, y: y, width: size.width, height: size.height)
            
        case .bottomRight:
            let x = self.maxX - size.width
            let y = self.maxY - size.height
            return CGRect(x: x, y: y, width: size.width, height: size.height)
            
        default:
            return self;
        }
    }
    
    /// 在当前区域内，计算指定大小的内容，按指定模式依次进行适配时的方位。
    /// - Parameters:
    ///   - size: 内容的大小
    ///   - contentModes: 适配模式，顺序会影响结果
    public func adjusting(_ size: CGSize, using contentModes: [UIView.ContentMode]) -> CGRect {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return contentModes.reduce(rect, { (rect, contentMode) -> CGRect in
            return rect.adjusting(rect.size, using: contentMode)
        })
    }
}
