//
//  CollectionViewFlowLayout.swift
//  XZKit
//
//  Created by Xezun on 2018/7/10.
//  Copyright © 2018年 XEZUN INC.com All rights reserved.
//

import UIKit

@available(*, unavailable, renamed: "XZKit.UICollectionViewDelegateFlowLayout")
typealias CollectionViewDelegateFlowLayout = XZKit.UICollectionViewDelegateFlowLayout

@available(*, unavailable, renamed: "XZKit.UICollectionViewFlowLayout")
typealias CollectionViewFlowLayout = XZKit.UICollectionViewFlowLayout

/// 通过本协议，可以具体的控制 XZKit.UICollectionViewFlowLayout 布局的 LineAlignment、InteritemAlignment 等内容。
@objc(XZCollectionViewDelegateFlowLayout)
public protocol UICollectionViewDelegateFlowLayout: UIKit.UICollectionViewDelegateFlowLayout {
    
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
    @objc optional func collectionView(_ collectionView: UIKit.UICollectionView, layout collectionViewLayout: UIKit.UICollectionViewLayout, edgeInsetsForSectionAt section: Int) -> XZEdgeInsets
}

extension UICollectionViewFlowLayout {
    
    /// LineAlignment 描述了每行内元素的排列方式。
    /// 当滚动方向为垂直方向时，水平方向上为一行，那么 LineAlignment 可以表述为向左对齐、向右对齐等；
    /// 当滚动方向为水平时，垂直方向为一行，那么 LineAlignment 可以表述为向上对齐、向下对齐。
    @objc(XZCollectionViewFlowLayoutLineAlignment)
    public enum LineAlignment: Int, CustomStringConvertible {
        
        /// 向首端对齐，末端不足留空。
        /// - Note: 首端对齐与布局方向相关，例如 A、B、C 三元素在同一行，自左向右布局 [ A B C _ ]，自右向左则为 [ _ C B A ] 。
        case leading
        /// 向末端对齐，首端不足留空。
        /// - Note: 末端对齐与布局方向相关，例如 A、B、C 三元素在同一行，自左向右布局 [ _ A B C ]，自右向左则为 [ C B A _ ] 。
        case trailing
        /// 居中对齐，两端可能留空。
        case center
        /// 两端对齐，平均分布，占满整行；如果行只有一个元素，该元素首端对齐。
        /// - Note: 每行的元素间距可能都不一样。
        case justified
        /// 两端对齐，平均分布，占满整行，如果行只有一个元素，该元素居中对齐。
        /// - Note: 每行的元素间距可能都不一样。
        case justifiedCenter
        /// 两端对齐，平均分布，占满整行，如果行只有一个元素，该元素末端对齐。
        /// - Note: 每行的元素间距可能都不一样。
        case justifiedTrailing
        
        public var description: String {
            switch self {
            case .leading:              return "leading"
            case .trailing:             return "trailing"
            case .center:               return "center"
            case .justified:            return "justified"
            case .justifiedCenter:      return "justifiedCenter"
            case .justifiedTrailing:    return "justifiedTrailing"
            }
        }
    }
    
    /// 同一行元素与元素的对齐方式。
    @objc(XZCollectionViewFlowLayoutInteritemAlignment)
    public enum InteritemAlignment: Int, CustomStringConvertible {
        
        /// 垂直滚动时，顶部对齐；水平滚动时，布局方向从左到右，左对齐，布局方向从右到左，右对齐。
        case ascender
        /// 垂直滚动时，水平中线对齐；水平滚动时，垂直中线对齐。
        case median
        /// 垂直滚动时，底部对齐；水平滚动时，布局方向从左到右，右对齐，布局方向从右到左，左对齐。
        case descender
        
        public var description: String {
            switch self {
            case .ascender:  return "ascender"
            case .median:    return "median"
            case .descender: return "descender"
            }
        }
        
    }
    
    fileprivate class SectionItem {
        let header: XZKit.UICollectionViewLayoutAttributes?
        let items: [XZKit.UICollectionViewLayoutAttributes]
        let footer: XZKit.UICollectionViewLayoutAttributes?
        init(header: XZKit.UICollectionViewLayoutAttributes?, items: [XZKit.UICollectionViewLayoutAttributes], footer: XZKit.UICollectionViewLayoutAttributes?, frame: CGRect) {
            self.header = header
            self.items = items
            self.footer = footer
            self.frame = frame
        }
        /// Section 的 frame ，用于优化性能。
        let frame: CGRect
    }
    
}

/// XZKit.UICollectionViewFlowLayout 布局属性，记录了 Cell 所在行列的信息。
@objc(XZCollectionViewLayoutAttributes)
open class UICollectionViewLayoutAttributes: UIKit.UICollectionViewLayoutAttributes, UICollectionViewIndexPath {
    public var item: Int {
        return indexPath.item
    }
    public var section: Int {
        return indexPath.section
    }
    public fileprivate(set) var line: Int = 0
    public fileprivate(set) var column: Int = 0
}

/// 支持多种对齐方式的 UICollectionView 自定义布局，为了区分于 UIKit.UICollectionViewFlowLayout ，引用需加 XZKit 前缀。
/// - Note: 优先使用 XZKit.UICollectionViewDelegateFlowLayout 作为代理协议，并兼容 UIKit.UICollectionViewDelegateFlowLayout 协议。
/// - Note: 对于 zIndex 进行了特殊处理，排序越后的视图 zIndex 越大；Header/Footer 的 zIndex 比 Cell 的大。
@objc(XZCollectionViewFlowLayout)
open class UICollectionViewFlowLayout: UIKit.UICollectionViewLayout {
    
    /// 滚动方向。默认 .vertical 。
    @objc open var scrollDirection: UIKit.UICollectionView.ScrollDirection = .vertical {
        didSet { invalidateLayout() }
    }
    
    /// 行间距。滚动方向为垂直时，水平方向为一行；滚动方向为水平时，垂直方向为一行。默认 0 ，代理方法的返回值优先。
    @objc open var minimumLineSpacing: CGFloat = 0 {
        didSet { invalidateLayout() }
    }
    
    /// 内间距。同一行内两个元素之间的距离。默认 0 ，代理方法的返回值优先。
    @objc open var minimumInteritemSpacing: CGFloat = 0 {
        didSet { invalidateLayout() }
    }
    
    /// 元素大小。默认 (50, 50)，代理方法返回的大小优先。
    @objc open var itemSize: CGSize = CGSize.init(width: 50, height: 50) {
        didSet { invalidateLayout() }
    }
    
    /// SectionHeader 大小，默认 0 ，代理方法的返回值优先。
    @objc open var headerReferenceSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    /// SectionFooter 大小，默认 0 ，代理方法的返回值优先。
    @objc open var footerReferenceSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    /// SectionItem 外边距。不包括 SectionHeader/SectionFooter 。默认 .zero ，代理方法的返回值优先。
    @objc open var sectionInsets: XZEdgeInsets = .zero {
        didSet { invalidateLayout() }
    }
    
    /// 行对齐方式，默认 .leading ，代理方法的返回值优先。
    @objc open var lineAlignment: LineAlignment = .justified {
        didSet { invalidateLayout() }
    }
    
    /// 元素对齐方式，默认 .median ，代理方法的返回值优先。
    @objc open var interitemAlignment: InteritemAlignment = .median {
        didSet { invalidateLayout() }
    }
    
    /// 记录了所有元素信息。
    fileprivate var sectionItems = [SectionItem]()
    /// 记录了 contentSize 。
    fileprivate var contentSize = CGSize.zero
}


extension UICollectionViewFlowLayout {
    
    open override class var layoutAttributesClass: Swift.AnyClass {
        return XZKit.UICollectionViewLayoutAttributes.self
    }
    
    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    open override func invalidateLayout() {
        super.invalidateLayout()
        sectionItems.removeAll()
    }
    
    /// 当 UICollectionView 的宽度改变时，需重新计算布局。
    ///
    /// - Parameter newBounds: The collectionView's new bounds.
    /// - Returns: true or false.
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        switch scrollDirection {
        case .vertical:
            return (newBounds.width != contentSize.width)
        case .horizontal:
            return (newBounds.height != contentSize.height)
        default:
            return false
        }
    }
    
    private func adjustedContentInset(_ collectionView: UIKit.UICollectionView) -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            // iOS 11 以后，导航栏的高度，安全边距合并到这个属性了。
            return collectionView.adjustedContentInset
        } else {
            // iOS 11 之前，导航栏的高度是加入到这个属性里的。
            return collectionView.contentInset
        }
    }
    
    override open func prepare() {
        guard let collectionView = self.collectionView else { return }
        let delegate = collectionView.delegate as? UIKit.UICollectionViewDelegateFlowLayout
        let frame = collectionView.frame
        let adjustedContentInset = self.adjustedContentInset(collectionView)
        
        // 使用 (0, 0) 作为起始坐标进行计算，根据 adjustedContentInset 来计算内容区域大小。
        
        switch self.scrollDirection {
        case .horizontal:
            contentSize = CGSize.init(width: 0, height: frame.height - adjustedContentInset.top - adjustedContentInset.bottom)
            for section in 0 ..< collectionView.numberOfSections {
                let x = contentSize.width
                let headerAttributes = self.prepareHorizontal(collectionView, delegate: delegate, layoutAttributesForHeaderInSection: section)
                let itemAttributes   = self.prepareHorizontal(collectionView, delegate: delegate, layoutAttributesForItemsInSection: section)
                let footerAttributes = self.prepareHorizontal(collectionView, delegate: delegate, layoutAttributesForFooterInSection: section)
                headerAttributes?.zIndex = itemAttributes.count + section
                footerAttributes?.zIndex = itemAttributes.count + section
                let frame = CGRect.init(x: x, y: 0, width: contentSize.width - x, height: contentSize.height)
                self.sectionItems.append(SectionItem.init(header: headerAttributes, items: itemAttributes, footer: footerAttributes, frame: frame))
            }
            
        case .vertical: fallthrough
        default:
            contentSize = CGSize.init(width: frame.width - adjustedContentInset.left - adjustedContentInset.right, height: 0)
            for section in 0 ..< collectionView.numberOfSections {
                let y = contentSize.height
                let headerAttributes = self.prepareVertical(collectionView, delegate: delegate, layoutAttributesForHeaderInSection: section)
                let itemAttributes   = self.prepareVertical(collectionView, delegate: delegate, layoutAttributesForItemsInSection: section)
                let footerAttributes = self.prepareVertical(collectionView, delegate: delegate, layoutAttributesForFooterInSection: section)
                // 同一 Section 的 Header/Footer 具有相同的 zIndex 并且越靠后越大，保证后面的 SectionHeader/Footer 在前面的之上。
                // 同时，Header/Footer 的 zIndex 比 Cell 的 zIndex 都大，Cell 也是索引越大 zIndex 越大。
                headerAttributes?.zIndex = itemAttributes.count + section
                footerAttributes?.zIndex = itemAttributes.count + section
                let frame = CGRect.init(x: 0, y: y, width: contentSize.width, height: contentSize.height - y)
                self.sectionItems.append(SectionItem.init(header: headerAttributes, items: itemAttributes, footer: footerAttributes, frame: frame))
            }
        }
        
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UIKit.UICollectionViewLayoutAttributes]? {
        // 超出范围肯定没有了。
        if rect.maxX <= 0 || rect.minX >= contentSize.width || rect.minY >= contentSize.height || rect.maxY <= 0 {
            return nil
        }
        
        // 如果当前已有找到在 rect 范围内的，那么如果遍历时，又遇到不在 rect 内的，说明已经超出屏幕，没有必要继续遍历了。
        // 由于对齐方式的不同，Cell可能与指定区域没有交集，但是其后面的 Cell 却可能在该区域内。
        
        var array = [UICollectionViewLayoutAttributes]()
        
        // 遍历所有 Cell 布局。
        for sectionItem in self.sectionItems {
            guard rect.intersects(sectionItem.frame) else {
                continue
            }
            if let header = sectionItem.header {
                if rect.intersects(header.frame) {
                    array.append(header)
                }
            }
            for item in sectionItem.items {
                if rect.intersects(item.frame) {
                    array.append(item)
                }
            }
            if let footer = sectionItem.footer {
                if rect.intersects(footer.frame) {
                    array.append(footer)
                }
            }
        }
        
        return array
    }
    
    override open func layoutAttributesForItem(at indexPath: Foundation.IndexPath) -> UIKit.UICollectionViewLayoutAttributes? {
        return sectionItems[indexPath.section].items[indexPath.item]
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: Foundation.IndexPath) -> UIKit.UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UIKit.UICollectionView.elementKindSectionHeader: return sectionItems[indexPath.section].header
        case UIKit.UICollectionView.elementKindSectionFooter: return sectionItems[indexPath.section].footer
        default: fatalError("Not supported UICollectionElementKind `\(elementKind)`.")
        }
    }
    
    /// Returns .leftToRight.
    open override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
        return .leftToRight
    }
    
    /// Retruns true.
    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
    
}



extension UICollectionViewFlowLayout {
    
    /// 准备指定 Section 的 Header 布局信息。
    @objc open func prepareVertical(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForHeaderInSection section: Int) -> XZKit.UICollectionViewLayoutAttributes? {
        let headerSize = delegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? self.headerReferenceSize
        guard headerSize != .zero else {
            return nil
        }
        let headerAttributes = XZKit.UICollectionViewLayoutAttributes.init(
            forSupplementaryViewOfKind: UIKit.UICollectionView.elementKindSectionHeader,
            with: Foundation.IndexPath.init(item: 0, section: section)
        )
        headerAttributes.frame = CGRect.init(
            // SectionHeader 水平居中
            x: (contentSize.width - headerSize.width) * 0.5,
            y: contentSize.height,
            width: headerSize.width,
            height: headerSize.height
        )
        contentSize.height += headerSize.height
        return headerAttributes
    }
    
    /// 准备指定 Section 的 Footer 布局信息。
    @objc open func prepareVertical(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForFooterInSection section: Int) -> XZKit.UICollectionViewLayoutAttributes? {
        let footerSize = delegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? self.footerReferenceSize
        guard footerSize != .zero else {
            return nil
        }
        let footerAttributes = XZKit.UICollectionViewLayoutAttributes.init(
            forSupplementaryViewOfKind: UIKit.UICollectionView.elementKindSectionFooter,
            with: Foundation.IndexPath.init(item: 0, section: section)
        )
        
        footerAttributes.frame = CGRect.init(
            x: (contentSize.width - footerSize.width) * 0.5,
            y: contentSize.height,
            width: footerSize.width,
            height: footerSize.height
        )
        contentSize.height += footerSize.height
        
        return footerAttributes
    }
    
    /// 获取行对齐方式。
    @objc open func collectionView(_ collectionView: UIKit.UICollectionView, lineAlignmentForLineAt indexPath: XZKit.UICollectionViewIndexPath, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> LineAlignment {
        guard let delegate = delegate as? UICollectionViewDelegateFlowLayout else { return self.lineAlignment }
        guard let lineAlignment = delegate.collectionView?(collectionView, layout: self, lineAlignmentForLineAt: indexPath) else { return self.lineAlignment }
        return lineAlignment
    }
    
    /// 获取元素对齐方式。
    @objc open func collectionView(_ collectionView: UIKit.UICollectionView, interitemAlignmentForItemAt indexPath: UICollectionViewIndexPath, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> InteritemAlignment {
        guard let delegate = delegate as? UICollectionViewDelegateFlowLayout else { return self.interitemAlignment }
        guard let interitemAlignment = delegate.collectionView?(collectionView, layout: self, interitemAlignmentForItemAt: indexPath) else { return self.interitemAlignment }
        return interitemAlignment
    }
    
    @objc open func collectionView(_ collectionView: UIKit.UICollectionView, edgeInsetsForSectionAt section: Int, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> XZEdgeInsets {
        if let delegate = delegate as? UICollectionViewDelegateFlowLayout {
            if let edgeInsets = delegate.collectionView?(collectionView, layout: self, edgeInsetsForSectionAt: section) {
                return edgeInsets
            }
        }
        if let edgeInsets = delegate?.collectionView?(collectionView, layout: self, insetForSectionAt: section) {
            return XZEdgeInsets.init(edgeInsets, layoutDirection: collectionView.userInterfaceLayoutDirection)
        }
        return self.sectionInsets
    }
    
    @objc open func collectionView(_ collectionView: UIKit.UICollectionView, sizeForItemAt indexPath: IndexPath, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> CGSize {
        guard let delegate = delegate as? UICollectionViewDelegateFlowLayout else { return self.itemSize }
        guard let itemSize = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) else { return self.itemSize }
        return itemSize
    }
    
    /// 准备指定 Section 的 Cell 布局信息。
    @objc open func prepareVertical(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForItemsInSection section: Int) -> [XZKit.UICollectionViewLayoutAttributes] {
        let sectionInsets = self.collectionView(collectionView, edgeInsetsForSectionAt: section, delegate: delegate)
        contentSize.height += sectionInsets.top
        
        let minimumLineSpacing = delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) ?? self.minimumLineSpacing
        let minimumInteritemSpacing = delegate?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? self.minimumInteritemSpacing
        
        var sectionAttributes = [XZKit.UICollectionViewLayoutAttributes]()
        
        // 行最大宽度。
        let maxLineLength: CGFloat = contentSize.width - sectionInsets.leading - sectionInsets.trailing
        
        // Section 高度，仅内容区域，不包括 header、footer 和内边距。
        // 初始值扣除一个间距，方便使用 间距 + 行高度 来计算高度。
        // 每计算完一行，增加此值，并在最终增加到 contentSize 中。
        var sectionHeight: CGFloat = -minimumLineSpacing
        
        // 当前正在计算的行的宽度，新行开始后此值会被初始化。
        // 初始值扣除一个间距，方便使用 间距 + 宽度 来计算总宽度。
        var currentLineLength: CGFloat = -minimumInteritemSpacing
        // 行最大高度。以行中最高的 Item 为行高度。
        var currentLineHeight: CGFloat = 0
        /// 保存了一行的 Cell 的布局信息。
        var currentLineAttributes = [XZKit.UICollectionViewLayoutAttributes]()
        
        /// 当一行的布局信息获取完毕时，从当前上下文中添加行布局信息，并重置上下文变量。
        func addLineAttributesFromCurrentContext() {
            var length: CGFloat = 0
            
            let lineLayoutInfo = self.collectionView(collectionView, lineLayoutForLineWith: currentLineAttributes, maxLineLength: maxLineLength, lineLength: currentLineLength, minimumInteritemSpacing: minimumInteritemSpacing, delegate: delegate)
            
            for column in 0 ..< currentLineAttributes.count {
                let itemAttributes = currentLineAttributes[column]
                itemAttributes.column = column
                
                var x: CGFloat = 0
                
                if column == 0 {
                    x = sectionInsets.leading + lineLayoutInfo.indent
                    length = itemAttributes.size.width
                } else {
                    x = sectionInsets.leading + lineLayoutInfo.indent + length + lineLayoutInfo.spacing
                    length = length + lineLayoutInfo.spacing + itemAttributes.size.width
                }

                var y: CGFloat = contentSize.height + sectionHeight + minimumLineSpacing
                
                let interitemAlignment = self.collectionView(collectionView, interitemAlignmentForItemAt: itemAttributes, delegate: delegate)
                switch interitemAlignment {
                case .ascender: break
                case .median:    y += (currentLineHeight - itemAttributes.size.height) * 0.5
                case .descender: y += (currentLineHeight - itemAttributes.size.height)
                }
                
                itemAttributes.frame = CGRect.init(x: x, y: y, width: itemAttributes.size.width, height: itemAttributes.size.height)
                sectionAttributes.append(itemAttributes)
            }
            currentLineAttributes.removeAll()
            // 开始新的一行，Section 高度增加，重置高度、宽度。
            sectionHeight += (minimumLineSpacing + currentLineHeight)
            currentLineHeight = 0
            currentLineLength = -minimumInteritemSpacing
        }
        
        var currentLine: Int = 0
        // 获取所有 Cell 的大小。
        for index in 0 ..< collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath.init(item: index, section: section)
            let itemSize = self.collectionView(collectionView, sizeForItemAt: indexPath, delegate: delegate)
            
            // 新的宽度超出最大宽度，且行元素不为空，那么该换行了，把当前行中的所有元素移动到总的元素集合中。
            var newLineWidth = currentLineLength + (minimumInteritemSpacing + itemSize.width)
            if newLineWidth > maxLineLength && !currentLineAttributes.isEmpty {
                // 将已有数据添加到布局中。
                addLineAttributesFromCurrentContext()
                // 换行。
                currentLine += 1
                // 新行的宽度
                newLineWidth = itemSize.width
            }
            
            // 如果没有超出最大宽度，或者行为空（其中包括，单个 Cell 的宽度超过最大宽度的情况），或者换行后的新行，将元素添加到行中。
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttributes.line   = currentLine
            itemAttributes.size   = itemSize
            itemAttributes.zIndex = index
            currentLineAttributes.append(itemAttributes)
            
            // 当前行宽度、高度。
            currentLineLength = newLineWidth
            currentLineHeight = max(currentLineHeight, itemSize.height)
        }
        addLineAttributesFromCurrentContext()
        
        contentSize.height += sectionHeight
        contentSize.height += sectionInsets.bottom
        
        return sectionAttributes
    }
    
    // MARK: - 水平方向。

    @objc open func prepareHorizontal(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForHeaderInSection section: Int) -> XZKit.UICollectionViewLayoutAttributes? {
        let headerSize = delegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? self.headerReferenceSize
        guard headerSize != .zero else {
            return nil
        }
        let headerAttributes = XZKit.UICollectionViewLayoutAttributes.init(
            forSupplementaryViewOfKind: UIKit.UICollectionView.elementKindSectionHeader,
            with: Foundation.IndexPath.init(item: 0, section: section)
        )
        headerAttributes.frame = CGRect.init(
            x: contentSize.width,
            y: (contentSize.height - headerSize.height) * 0.5,
            width: headerSize.width,
            height: headerSize.height
        )
        contentSize.width += headerSize.width
        return headerAttributes
    }
    
    @objc open func prepareHorizontal(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForFooterInSection section: Int) -> XZKit.UICollectionViewLayoutAttributes? {
        let footerSize = delegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? self.footerReferenceSize
        guard footerSize != .zero else {
            return nil
        }
        let footerAttributes = XZKit.UICollectionViewLayoutAttributes.init(
            forSupplementaryViewOfKind: UIKit.UICollectionView.elementKindSectionFooter,
            with: Foundation.IndexPath.init(item: 0, section: section)
        )
        footerAttributes.frame = CGRect.init(
            x: contentSize.width,
            y: (contentSize.height - footerSize.height) * 0.5,
            width: footerSize.width,
            height: footerSize.height
        )
        contentSize.width += footerSize.width
        return footerAttributes
    }
    
    @objc open func prepareHorizontal(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForItemsInSection section: Int) -> [XZKit.UICollectionViewLayoutAttributes] {
        let sectionInsets = self.collectionView(collectionView, edgeInsetsForSectionAt: section, delegate: delegate)
        contentSize.width += sectionInsets.leading
        
        let minimumLineSpacing = delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) ?? self.minimumLineSpacing
        let minimumInteritemSpacing = delegate?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? self.minimumInteritemSpacing
        
        var sectionAttributes = [XZKit.UICollectionViewLayoutAttributes]()
        
        // 行最大宽度。
        let maxLineLength: CGFloat = contentSize.height - sectionInsets.top - sectionInsets.bottom
        
        // Section 高度，仅内容区域，不包括 header、footer 和内边距。
        // 初始值扣除一个间距，方便使用 间距 + 行高度 来计算高度。
        // 每计算完一行，增加此值，并在最终增加到 contentSize 中。
        var sectionHeight: CGFloat = -minimumLineSpacing
        
        // 当前正在计算的行的宽度，新行开始后此值会被初始化。
        // 初始值扣除一个间距，方便使用 间距 + 宽度 来计算总宽度。
        var currentLineLength: CGFloat = -minimumInteritemSpacing
        // 行最大高度。以行中最高的 Item 为行高度。
        var currentLineHeight: CGFloat = 0
        /// 保存了一行的 Cell 的布局信息。
        var currentLineAttributes = [UICollectionViewLayoutAttributes]()
        
        /// 当一行的布局信息获取完毕时，从当前上下文中添加行布局信息，并重置上下文变量。
        func addLineAttributesFromCurrentContext() {
            let lineLayoutInfo = self.collectionView(collectionView, lineLayoutForLineWith: currentLineAttributes, maxLineLength: maxLineLength, lineLength: currentLineLength, minimumInteritemSpacing: minimumInteritemSpacing, delegate: delegate)
            
            var length: CGFloat = 0
            for column in 0 ..< currentLineAttributes.count {
                let itemAttributes = currentLineAttributes[column]
                itemAttributes.column = column
                
                var y: CGFloat = 0
                if column == 0 {
                    y = contentSize.height - sectionInsets.bottom - lineLayoutInfo.indent - itemAttributes.size.height
                    length = itemAttributes.size.height
                } else {
                    y = contentSize.height - sectionInsets.bottom - lineLayoutInfo.indent - length - lineLayoutInfo.spacing - itemAttributes.size.height
                    length = length + lineLayoutInfo.spacing + itemAttributes.size.height
                }
                
                var x: CGFloat = contentSize.width + sectionHeight + minimumLineSpacing
                
                let interitemAlignment = self.collectionView(collectionView, interitemAlignmentForItemAt: itemAttributes, delegate: delegate)
                switch interitemAlignment {
                case .ascender: break
                case .median:    x += (currentLineHeight - itemAttributes.size.width) * 0.5
                case .descender: x += (currentLineHeight - itemAttributes.size.width)
                }
                
                itemAttributes.frame = CGRect.init(x: x, y: y, width: itemAttributes.size.width, height: itemAttributes.size.height)
                sectionAttributes.append(itemAttributes)
            }
            currentLineAttributes.removeAll()
            sectionHeight += (minimumLineSpacing + currentLineHeight)
            currentLineHeight = 0
            currentLineLength = -minimumInteritemSpacing
        }
        
        var currentLine: Int = 0
        // 获取所有 Cell 的大小。
        for index in 0 ..< collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath.init(item: index, section: section)
            let itemSize = self.collectionView(collectionView, sizeForItemAt: indexPath, delegate: delegate)
            
            var newLineLength = currentLineLength + (minimumInteritemSpacing + itemSize.height)
            if newLineLength > maxLineLength && !currentLineAttributes.isEmpty {
                addLineAttributesFromCurrentContext()
                currentLine += 1
                newLineLength = itemSize.height
            }
            
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttributes.line = currentLine
            itemAttributes.zIndex = index
            itemAttributes.size = itemSize
            currentLineAttributes.append(itemAttributes)
            
            currentLineLength = newLineLength
            currentLineHeight = max(currentLineHeight, itemSize.width)
        }
        
        addLineAttributesFromCurrentContext()
        
        contentSize.width += sectionHeight
        contentSize.width += sectionInsets.trailing
        
        return sectionAttributes
    }
    
    /// 根据行信息计算行布局。因为每一行不能完全占满，根据对齐方式不同，x 坐标相对于起始点，可能需要不同的偏移，元素的间距也可能需要重新计算。
    private func collectionView(_ collectionView: UICollectionView, lineLayoutForLineWith currentLineAttributes: [UICollectionViewLayoutAttributes], maxLineLength: CGFloat, lineLength currentLineLength: CGFloat, minimumInteritemSpacing: CGFloat, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> (indent: CGFloat, spacing: CGFloat) {
        let lineAlignment = self.collectionView(collectionView, lineAlignmentForLineAt: currentLineAttributes[0], delegate: delegate)
        switch lineAlignment {
        case .leading:
            return (0, minimumInteritemSpacing)
        case .trailing:
            return (maxLineLength - currentLineLength, minimumInteritemSpacing)
        case .center:
            return ((maxLineLength - currentLineLength) * 0.5, minimumInteritemSpacing)
        case .justified:
            if currentLineAttributes.count > 1 {
                return (0, minimumInteritemSpacing + (maxLineLength - currentLineLength) / CGFloat(currentLineAttributes.count - 1))
            }
            return (0, 0)
        case .justifiedCenter:
            if currentLineAttributes.count > 1 {
                return (0, minimumInteritemSpacing + (maxLineLength - currentLineLength) / CGFloat(currentLineAttributes.count - 1))
            }
            return ((maxLineLength - currentLineLength) * 0.5, 0)
        case .justifiedTrailing:
            if currentLineAttributes.count > 1 {
                return (0, minimumInteritemSpacing + (maxLineLength - currentLineLength) / CGFloat(currentLineAttributes.count - 1))
            }
            return ((maxLineLength - currentLineLength), 0)
        }
        
    }

}


/// 描述了 UICollectionView 中元素的布局信息。
@objc(XZCollectionViewIndexPath)
public protocol UICollectionViewIndexPath: NSObjectProtocol {
    /// 元素在其所在的 section 中的序数。
    @objc var item:    Int { get }
    /// 元素所在的 section 在 UICollectionView 中的序数。
    @objc var section: Int { get }
    /// 元素在其所在的 line 中的序数。
    @objc var column:  Int { get }
    /// 元素所在的 line 在 section 中的序数。
    @objc var line:    Int { get }
}
