//
//  XZGeometry.swift
//  XZKit
//
//  Created by Xezun on 2019/3/27.
//  Copyright © 2019 Xezun Individual. All rights reserved.
//

import Foundation
import UIKit

//#if SWIFT_PACKAGE
//@_exported import XZGeometryCore
//#endif

// MARK: CGGeometry
// AVFoundation.AVMakeRectWithAspectRatioInsideRect

extension NSDirectionalEdgeInsets {
    
    /// 通过 UIEdgeInsets 构造。
    /// - Parameters:
    ///   - edgeInsets: 边距
    ///   - layoutDirection: 布局方向
    public init(_ edgeInsets: UIEdgeInsets, _ layoutDirection: UIUserInterfaceLayoutDirection) {
        self = __NSDirectionalEdgeInsetsFromUIEdgeInsets(edgeInsets, layoutDirection);
    }
    
}

extension UIEdgeInsets {
    
    /// 通过 XZEdgeInsets 构造。
    /// - Parameters:
    ///   - edgeInsets: XZEdgeInsets 边距
    ///   - layoutDirection: 布局方向
    public init(_ edgeInsets: NSDirectionalEdgeInsets, _ layoutDirection: UIUserInterfaceLayoutDirection) {
        self = __UIEdgeInsetsFromNSDirectionalEdgeInsets(edgeInsets, layoutDirection);
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
        return __CGRectContainsPointInEdgeInsets(self, edgeInsets, point)
    }
    
}

extension CGSize {
    
    /// 在 size 范围内创建一个宽高比为 ratio 的 CGSize 结构体。
    /// - Parameters:
    ///   - size: 待创建 CGSize 的尺寸范围
    ///   - ratio: 待创建 CGSize 的宽高比
    public init(ratio: CGSize, inside size: CGSize) {
        self = __CGSizeMakeAspectRatioInside(size, ratio)
    }
    
    /// 将当前大小的内容，缩放到 size 范围内，如果已经在范围内，则不缩放。
    /// - Parameter size: 指定范围
    /// - Returns: 缩放后的大小
    public func scalingAspectRatio(inside size: CGSize) -> CGSize {
        return __CGSizeScaleAspectRatioInside(size, self)
    }
    
    /// 等比缩小到指定范围以内，如果已经在范围内，则不缩放。
    /// - Parameter size: 范围
    /// - Returns: CGSize
    public mutating func scaleAspectRatio(inside size: CGSize) {
        self = scalingAspectRatio(inside: size)
    }
    
    /// 将当前区域，等比缩放到 rect 区域内，并按 contentMode 模式进行适配时的 CGRect 值。
    public func scalingAspectRatio(inside rect: CGRect, with contentMode: UIView.ContentMode) -> CGRect {
        return __CGRectScaleAspectRatioInsideWithMode(rect, self, contentMode);
    }
    
}


extension CGRect {
    
    // 按 contentMode 模式，将大小为 size 的范围，适配到当前区域时的 CGRect 值。
    public func adjusting(_ size: CGSize, with contentMode: UIView.ContentMode) -> CGRect {
        return __CGRectAdjustSizeWithMode(self, size, contentMode);
    }
    
    /// 在当前区域内，按 contentMode 模式，创建宽高比为 ratio 区域的 CGRect 值。
    public init(ratio: CGSize, inside rect: CGRect, with contentMode: UIView.ContentMode) {
        self = __CGRectMakeAspectRatioInsideWithMode(rect, ratio, contentMode);
    }
    
    /// 将宽高为 aspect 的区域，等比缩放到 rect 区域内，并按 contentMode 模式进行适配时的 CGRect 值。
    public init(aspect: CGSize, inside rect: CGRect, with contentMode: UIView.ContentMode) {
        self = __CGRectScaleAspectRatioInsideWithMode(rect, aspect, contentMode);
    }
    
}
