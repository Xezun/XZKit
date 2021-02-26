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

extension XZEdgeInsets: Equatable {
    
    public init(_ edgeInsets: UIEdgeInsets, layoutDirection: UIUserInterfaceLayoutDirection) {
        switch (layoutDirection) {
        case .rightToLeft:
            self.init(top: edgeInsets.top, leading: edgeInsets.right, bottom: edgeInsets.bottom, trailing: edgeInsets.left)
        default:
            self.init(top: edgeInsets.top, leading: edgeInsets.left, bottom: edgeInsets.bottom, trailing: edgeInsets.right)
        }
    }
    
    static public func == (lhs: XZEdgeInsets, rhs: XZEdgeInsets) -> Bool {
        return lhs.top == rhs.top && lhs.leading == rhs.leading && lhs.bottom == rhs.bottom && lhs.trailing == rhs.trailing
    }
    
}

extension UIEdgeInsets {
    
    public init(_ edgeInsets: XZEdgeInsets, layoutDirection: UIUserInterfaceLayoutDirection) {
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
    public init(ratio: CGSize, in size: CGSize) {
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
        return CGSizeFitingInRectWithContentMode(self, rect, contentMode)
    }
}
