//
//  UICollectionViewDelegateFlowLayout.swift
//  XZKit
//
//  Created by Xezun on 2021/3/4.
//

import Foundation

/// 通过本协议，可以具体的控制 XZKit.UICollectionViewFlowLayout 布局的 LineAlignment、InteritemAlignment 等内容。
@objc(XZCollectionViewDelegateFlowLayout) public protocol UICollectionViewDelegateFlowLayout: UIKit.UICollectionViewDelegateFlowLayout {
    
    /// 当 XZKit.UICollectionViewFlowLayout 计算元素布局时，通过此代理方法，获取指定行的对齐方式。
    ///
    /// - Parameters:
    ///   - collectionView: UICollectionView 视图。
    ///   - collectionViewLayout: UICollectionViewLayout 视图布局对象。
    ///   - indexPath: 行的布局信息，包括行所在的区 section、行在区中的次序 line 。
    /// - Returns: 行对齐方式。
    @objc optional func collectionView(_ collectionView: UIKit.UICollectionView, layout collectionViewLayout: UIKit.UICollectionViewLayout, lineAlignmentForLineAt indexPath: XZKit.UICollectionViewIndexPath) -> XZKit.UICollectionViewFlowLayout.LineAlignment
    
    /// 获取同一行元素间的对齐方式：垂直滚动时，为同一横排元素在垂直方向上的对齐方式；水平滚动时，同一竖排元素，在水平方向的对齐方式。
    ///
    /// - Parameters:
    ///   - collectionView: UICollectionView 视图。
    ///   - collectionViewLayout: UICollectionViewLayout 视图布局对象。
    ///   - indexPath: 元素的布局信息，包括元素所在的区 section、在区中的次序 item、所在的行 line、在行中的次序 column 。
    /// - Returns: 元素对齐方式。
    @objc optional func collectionView(_ collectionView: UIKit.UICollectionView, layout collectionViewLayout: UIKit.UICollectionViewLayout, interitemAlignmentForItemAt indexPath: XZKit.UICollectionViewIndexPath) -> XZKit.UICollectionViewFlowLayout.InteritemAlignment
    
    /// 获取 section 的内边距，与原生的方法不同，本方法返回的为自适应布局方向的 XZKit.EdgeInsets 结构体。
    ///
    /// - Parameters:
    ///   - collectionView: UICollectionView 视图。
    ///   - collectionViewLayout: UICollectionViewLayout 视图布局对象。
    ///   - section: 指定的 section 序数。
    /// - Returns: 内边距。
    @objc optional func collectionView(_ collectionView: UIKit.UICollectionView, layout collectionViewLayout: UIKit.UICollectionViewLayout, edgeInsetsForSectionAt section: Int) -> UIEdgeInsets
}
