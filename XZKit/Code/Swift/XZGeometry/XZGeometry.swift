//
//  XZGeometry.swift
//  XZKit
//
//  Created by Xezun on 2019/3/27.
//  Copyright © 2019 Xezun Individual. All rights reserved.
//

import Foundation
import UIKit

#if SWIFT_PACKAGE
import XZGeometryObjC
#endif

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
    public init(inside size: CGSize, ratio: CGSize) {
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
    
    /// 按 contentMode 模式，将当前大小的内容缩放到 rect 区域内。
    ///
    /// 根据 contentMode 模式适配规则，生成的 CGRect 可能与当前大小不同。
    ///
    /// - Parameters:
    ///   - aspect: 待创建 CGRect 的大小或宽高比
    ///   - contentMode: 适配模式
    public func scalingAspectRatio(inside rect: CGRect, contentMode: UIView.ContentMode) -> CGRect {
        return __CGRectScaleAspectRatioInsideWithMode(rect, self, contentMode)
    }
    
    /// 按 contentModes 模式，依次将当前大小的内容缩放到 rect 区域内。
    ///
    /// 根据 contentMode 模式适配规则，生成的 CGRect 可能与当前大小不同。
    ///
    /// - Parameters:
    ///   - rect: 缩放区域
    ///   - contentModes: 适配模式
    public func scalingAspectRatio(inside rect: CGRect, contentModes: [UIView.ContentMode]) -> CGRect {
        return contentModes.reduce(CGRect.init(origin: rect.origin, size: self), { (aspect, contentMode) -> CGRect in
            return aspect.size.scalingAspectRatio(inside: rect, contentMode: contentMode)
        })
    }
}


extension CGRect {
    
    /// 在 rect 区域内，为大小为 aspect 的内容，创建一个按 contentMode 模式适配的 CGRect 结构体。
    ///
    /// - Parameters:
    ///   - rect: 适配区域
    ///   - aspect: 适配大小，根据 contentMode 模式，函数返回值结构体宽高值可能并非与此参数相同
    ///   - contentMode: 适配模式
    public init(inside rect: CGRect, aspect: CGSize, contentMode: UIView.ContentMode) {
        self = __CGRectMakeAspectRatioWithMode(rect, aspect, contentMode)
    }
    
    /// 在 rect 区域内，为比例为 ratio 的内容，创建一个按 contentMode 模式适配的 CGRect 结构体。
    ///
    /// - Parameters:
    ///   - rect: 待创建 CGRect 所在的区域
    ///   - ratio: 待创建 CGRect 的宽高比，根据 contentMode 模式，函数返回值结构体宽高比可能并非与此参数相同
    ///   - contentMode: 待创建 CGRect 在 aspect 区域中的适配模式
    public init(inside rect: CGRect, ratio: CGSize, contentMode: UIView.ContentMode) {
        self = __CGRectMakeAspectRatioInsideWithMode(rect, ratio, contentMode);
    }
    
}
