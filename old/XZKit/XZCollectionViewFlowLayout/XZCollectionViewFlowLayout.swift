//
//  CollectionViewFlowLayout.swift
//  XZKit
//
//  Created by Xezun on 2018/7/10.
//  Copyright © 2018年 XEZUN INC.com All rights reserved.
//

import UIKit

extension UICollectionViewFlowLayout {
    
    /// LineAlignment 描述了每行内元素的排列方式。
    /// 当滚动方向为垂直方向时，水平方向上为一行，那么 LineAlignment 可以表述为向左对齐、向右对齐等；
    /// 当滚动方向为水平时，垂直方向为一行，那么 LineAlignment 可以表述为向上对齐、向下对齐。
    @objc(XZCollectionViewLineAlignment)
    public enum LineAlignment: Int {
        
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
        
    }
    
    /// 同一行元素与元素的对齐方式。
    @objc(XZCollectionViewInteritemAlignment)
    public enum InteritemAlignment: Int {
        
        /// 垂直滚动时，顶部对齐；水平滚动时，布局方向从左到右，左对齐，布局方向从右到左，右对齐。
        case ascender
        /// 垂直滚动时，水平中线对齐；水平滚动时，垂直中线对齐。
        case median
        /// 垂直滚动时，底部对齐；水平滚动时，布局方向从左到右，右对齐，布局方向从右到左，左对齐。
        case descender
        
    }
    
    fileprivate class SectionItem {
        let header: UICollectionViewLayoutAttributes?
        let items: [UICollectionViewLayoutAttributes]
        let footer: UICollectionViewLayoutAttributes?
        init(header: UICollectionViewLayoutAttributes?, items: [UICollectionViewLayoutAttributes], footer: UICollectionViewLayoutAttributes?, frame: CGRect) {
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
    open var scrollDirection: UIKit.UICollectionView.ScrollDirection = .vertical {
        didSet { invalidateLayout() }
    }
    
    /// 行间距。滚动方向为垂直时，水平方向为一行；滚动方向为水平时，垂直方向为一行。默认 0 ，代理方法的返回值优先。
    open var minimumLineSpacing: CGFloat = 0 {
        didSet { invalidateLayout() }
    }
    
    /// 内间距。同一行内两个元素之间的距离。默认 0 ，代理方法的返回值优先。
    open var minimumInteritemSpacing: CGFloat = 0 {
        didSet { invalidateLayout() }
    }
    
    /// 元素大小。默认 (50, 50)，代理方法返回的大小优先。
    open var itemSize: CGSize = CGSize.init(width: 50, height: 50) {
        didSet { invalidateLayout() }
    }
    
    /// SectionHeader 大小，默认 0 ，代理方法的返回值优先。
    open var headerReferenceSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    /// SectionFooter 大小，默认 0 ，代理方法的返回值优先。
    open var footerReferenceSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    /// SectionItem 外边距。不包括 SectionHeader/SectionFooter 。默认 .zero ，代理方法的返回值优先。
    open var sectionInsets: UIEdgeInsets = .zero {
        didSet { invalidateLayout() }
    }
    
    /// 行对齐方式，默认 .leading ，代理方法的返回值优先。
    open var lineAlignment: LineAlignment = .justified {
        didSet { invalidateLayout() }
    }
    
    /// 元素对齐方式，默认 .median ，代理方法的返回值优先。
    open var interitemAlignment: InteritemAlignment = .median {
        didSet { invalidateLayout() }
    }
    
    /// 记录了所有元素信息。
    fileprivate var sectionItems = [SectionItem]()
    
    /// 记录了 contentSize 。
    fileprivate var contentSize = CGSize.zero
}


extension UICollectionViewFlowLayout {
    
    open override class var layoutAttributesClass: Swift.AnyClass {
        return UICollectionViewLayoutAttributes.self
    }
    
    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    open override func invalidateLayout() {
        sectionItems.removeAll()
        super.invalidateLayout()
    }
    
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
    
    private func adjustedContentInset(of collectionView: UIKit.UICollectionView) -> UIEdgeInsets {
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
        let size     = collectionView.frame.size
        let insets   = adjustedContentInset(of: collectionView)
        
        // 使用 (0, 0) 作为起始坐标进行计算，根据 adjustedContentInset 来计算内容区域大小。
        
        switch self.scrollDirection {
        case .vertical:
            contentSize = CGSize.init(width: size.width - insets.left - insets.right, height: 0)
            
            for section in 0 ..< collectionView.numberOfSections {
                let y = contentSize.height
                let header = self.prepare(vertical: collectionView, delegate: delegate, layoutAttributesForHeaderInSection: section)
                let cells  = self.prepare(vertical: collectionView, delegate: delegate, layoutAttributesForItemsInSection: section)
                let footer = self.prepare(vertical: collectionView, delegate: delegate, layoutAttributesForFooterInSection: section)
                // 同一 Section 的 Header/Footer 具有相同的 zIndex 并且越靠后越大，保证后面的 SectionHeader/Footer 在前面的之上。
                // 同时，Header/Footer 的 zIndex 比 Cell 的 zIndex 都大，Cell 也是索引越大 zIndex 越大。
                header?.zIndex = cells.count + section
                footer?.zIndex = cells.count + section
                let frame = CGRect.init(x: 0, y: y, width: contentSize.width, height: contentSize.height - y)
                self.sectionItems.append(SectionItem.init(header: header, items: cells, footer: footer, frame: frame))
            }
            
        case .horizontal:
            contentSize = CGSize.init(width: 0, height: size.height - insets.top - insets.bottom)
            for section in 0 ..< collectionView.numberOfSections {
                let x = contentSize.width
                let header = self.prepare(horizontal: collectionView, delegate: delegate, layoutAttributesForHeaderInSection: section)
                let cells  = self.prepare(horizontal: collectionView, delegate: delegate, layoutAttributesForItemsInSection: section)
                let footer = self.prepare(horizontal: collectionView, delegate: delegate, layoutAttributesForFooterInSection: section)
                header?.zIndex = cells.count + section
                footer?.zIndex = cells.count + section
                let frame = CGRect.init(x: x, y: 0, width: contentSize.width - x, height: contentSize.height)
                self.sectionItems.append(SectionItem.init(header: header, items: cells, footer: footer, frame: frame))
            }
            
        default:
            fatalError("scroll direction \(self.scrollDirection) not supported")
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
        case UIKit.UICollectionView.elementKindSectionHeader:
            return sectionItems[indexPath.section].header
            
        case UIKit.UICollectionView.elementKindSectionFooter:
            return sectionItems[indexPath.section].footer
            
        default:
            fatalError("Not supported UICollectionElementKind `\(elementKind)`.")
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
    open func prepare(vertical collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForHeaderInSection section: Int) -> UICollectionViewLayoutAttributes? {
        let size = delegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? self.headerReferenceSize
        if size.width <= 0 || size.height <= 0 {
            return nil
        }
        let headerAttributes = UICollectionViewLayoutAttributes.init(
            forSupplementaryViewOfKind: UIKit.UICollectionView.elementKindSectionHeader,
            with: Foundation.IndexPath.init(item: 0, section: section)
        )
        headerAttributes.frame = CGRect.init(
            // SectionHeader 水平居中
            x: (contentSize.width - size.width) * 0.5,
            y: contentSize.height,
            width: size.width,
            height: size.height
        )
        contentSize.height += size.height
        return headerAttributes
    }
    
    /// 准备指定 Section 的 Footer 布局信息。
    open func prepare(vertical collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForFooterInSection section: Int) -> UICollectionViewLayoutAttributes? {
        let size = delegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? self.footerReferenceSize
        if size.width <= 0 || size.height <= 0 {
            return nil
        }
        let footerAttributes = UICollectionViewLayoutAttributes.init(
            forSupplementaryViewOfKind: UIKit.UICollectionView.elementKindSectionFooter,
            with: Foundation.IndexPath.init(item: 0, section: section)
        )
        
        footerAttributes.frame = CGRect.init(
            x: (contentSize.width - size.width) * 0.5,
            y: contentSize.height,
            width: size.width,
            height: size.height
        )
        contentSize.height += size.height
        
        return footerAttributes
    }
    
    /// 获取行对齐方式。
    open func collectionView(_ collectionView: UIKit.UICollectionView, lineAlignmentForLineAt indexPath: UICollectionViewIndexPath, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> LineAlignment {
        if let delegate = delegate as? UICollectionViewDelegateFlowLayout,
           let alignment = delegate.collectionView?(collectionView, layout: self, lineAlignmentForLineAt: indexPath) {
            return alignment
        }
        return lineAlignment
    }
    
    /// 获取元素对齐方式。
    open func collectionView(_ collectionView: UIKit.UICollectionView, interitemAlignmentForItemAt indexPath: UICollectionViewIndexPath, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> InteritemAlignment {
        if let delegate = delegate as? UICollectionViewDelegateFlowLayout,
           let alignment = delegate.collectionView?(collectionView, layout: self, interitemAlignmentForItemAt: indexPath) {
            return alignment
        }
        return interitemAlignment
    }
    
    open func collectionView(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, edgeInsetsForSectionAt section: Int) -> UIEdgeInsets {
        if let delegate = delegate as? UICollectionViewDelegateFlowLayout,
           let sectionInsets = delegate.collectionView?(collectionView, layout: self, edgeInsetsForSectionAt: section) {
            return sectionInsets
        }
        return sectionInsets
    }
    
    open func collectionView(_ collectionView: UIKit.UICollectionView, sizeForItemAt indexPath: IndexPath, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> CGSize {
        if let itemSize = delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            return itemSize
        }
        return itemSize
    }
    
    open func collectionView(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let spacing = delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) {
            return spacing
        }
        return minimumLineSpacing
    }
    
    open func collectionView(_ collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let spacing = delegate?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) {
            return spacing
        }
        return minimumInteritemSpacing
    }
    
    struct Context {
        /// 当前行。
        var line: Int
        /// 当前行的宽度，初始值扣除一个间距，方便使用 间距 + 宽度 来计算总宽度。
        var width: CGFloat
        // 行最大高度。以行中最高的 Item 为行高度。
        var height: CGFloat = 0
        /// 保存了一行的 Cell 的布局信息。
        var attributes = [UICollectionViewLayoutAttributes]()
    }
    
    /// 准备指定 Section 的 Cell 布局信息。
    open func prepare(vertical collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForItemsInSection section: Int) -> [UICollectionViewLayoutAttributes] {
        let sectionInsets = self.collectionView(collectionView, delegate: delegate, edgeInsetsForSectionAt: section)
        contentSize.height += sectionInsets.top
        
        let minimumLineSpacing = self.collectionView(collectionView, delegate: delegate, minimumLineSpacingForSectionAt: section)
        let minimumInteritemSpacing = self.collectionView(collectionView, delegate: delegate, minimumInteritemSpacingForSectionAt: section)
        
        var sectionAttributes = [UICollectionViewLayoutAttributes]()
        
        // 行最大宽度。
        let maxLineLength: CGFloat = contentSize.width - sectionInsets.left - sectionInsets.right
        
        // Section 高度，仅内容区域，不包括 header、footer 和内边距。
        // 初始值扣除一个间距，方便使用 间距 + 行高度 来计算高度。
        // 每计算完一行，增加此值，并在最终增加到 contentSize 中。
        var sectionHeight: CGFloat = -minimumLineSpacing
        
        /// 行信息
        var context = Context.init(line: 0, width: -minimumInteritemSpacing)
        
        /// 当一行的布局信息获取完毕时，从当前上下文中添加行布局信息，并重置上下文变量。
        
        func addLineAttributesFromCurrentContext(_ context: Context) {
            var length: CGFloat = 0
            
            let lineLayoutInfo = self.collectionView(collectionView, layoutInfoFor: context.attributes, maxLength: maxLineLength, length: context.width, spacing: minimumInteritemSpacing, delegate: delegate)
            
            for column in 0 ..< context.attributes.count {
                let itemAttributes = context.attributes[column]
                itemAttributes.column = column
                
                var x: CGFloat = 0
                
                if column == 0 {
                    x = sectionInsets.left + lineLayoutInfo.indent
                    length = itemAttributes.size.width
                } else {
                    x = sectionInsets.left + lineLayoutInfo.indent + length + lineLayoutInfo.spacing
                    length = length + lineLayoutInfo.spacing + itemAttributes.size.width
                }

                var y: CGFloat = contentSize.height + sectionHeight + minimumLineSpacing
                
                let interitemAlignment = self.collectionView(collectionView, interitemAlignmentForItemAt: itemAttributes, delegate: delegate)
                switch interitemAlignment {
                case .ascender:
                    break
                case .median:
                    y += (context.height - itemAttributes.size.height) * 0.5
                case .descender:
                    y += (context.height - itemAttributes.size.height)
                }
                
                itemAttributes.frame = CGRect.init(x: x, y: y, width: itemAttributes.size.width, height: itemAttributes.size.height)
                sectionAttributes.append(itemAttributes)
            }
            // 开始新的一行，Section 高度增加，重置高度、宽度。
            sectionHeight += (minimumLineSpacing + context.height)
        }
                
        // 获取所有 Cell 的大小。
        for index in 0 ..< collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath.init(item: index, section: section)
            let itemSize = self.collectionView(collectionView, sizeForItemAt: indexPath, delegate: delegate)
            
            var newWidth = context.width + (minimumInteritemSpacing + itemSize.width)
            
            // 新的宽度超出最大宽度，且行元素不为空，那么该换行了，把当前行中的所有元素移动到总的元素集合中。
            if newWidth > maxLineLength && !context.attributes.isEmpty {
                addLineAttributesFromCurrentContext()
                
                context.attributes.removeAll()
                context.line   += 1
                context.height = 0
                context.width  = -minimumInteritemSpacing
                
                newWidth = itemSize.width
            }
            
            // 如果没有超出最大宽度，或者行为空（其中包括，单个 Cell 的宽度超过最大宽度的情况），或者换行后的新行，将元素添加到行中。
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttributes.line   = context.line
            itemAttributes.size   = itemSize
            itemAttributes.zIndex = index
            context.attributes.append(itemAttributes)
            
            // 当前行宽度、高度。
            context.width = newWidth
            context.height = max(context.height, itemSize.height)
        }
        addLineAttributesFromCurrentContext()
        
        contentSize.height += sectionHeight
        contentSize.height += sectionInsets.bottom
        
        return sectionAttributes
    }
    
    // MARK: - 水平方向。

    open func prepare(horizontal collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForHeaderInSection section: Int) -> UICollectionViewLayoutAttributes? {
        let headerSize = delegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? self.headerReferenceSize
        guard headerSize != .zero else {
            return nil
        }
        let headerAttributes = UICollectionViewLayoutAttributes.init(
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
    
    open func prepare(horizontal collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForFooterInSection section: Int) -> UICollectionViewLayoutAttributes? {
        let footerSize = delegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? self.footerReferenceSize
        guard footerSize != .zero else {
            return nil
        }
        let footerAttributes = UICollectionViewLayoutAttributes.init(
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
    
    
    
    open func prepare(horizontal collectionView: UIKit.UICollectionView, delegate: UIKit.UICollectionViewDelegateFlowLayout?, layoutAttributesForItemsInSection section: Int) -> [UICollectionViewLayoutAttributes] {
        let sectionInsets = self.collectionView(collectionView, edgeInsetsForSectionAt: section, delegate: delegate)
        contentSize.width += sectionInsets.left
        
        let minimumLineSpacing = delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) ?? self.minimumLineSpacing
        let minimumInteritemSpacing = delegate?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? self.minimumInteritemSpacing
        
        var sectionAttributes = [UICollectionViewLayoutAttributes]()
        
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
        
        /// 根据行信息计算行布局。因为每一行不能完全占满，根据对齐方式不同，x 坐标相对于起始点，可能需要不同的偏移，元素的间距也可能需要重新计算。
        func getCurrentLineLayoutInfo() -> (indent: CGFloat, spacing: CGFloat) {
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
        
        /// 当一行的布局信息获取完毕时，从当前上下文中添加行布局信息，并重置上下文变量。
        func addLineAttributesFromCurrentContext() {
            let lineLayoutInfo = getCurrentLineLayoutInfo()
            
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
        contentSize.width += sectionInsets.right
        
        return sectionAttributes
    }
    
    /// 根据行信息计算行布局。因为每一行不能完全占满，根据对齐方式不同，x 坐标相对于起始点，可能需要不同的偏移，元素的间距也可能需要重新计算。
    private func collectionView(_ collectionView: UICollectionView, layoutInfoFor currentLineAttributes: [UICollectionViewLayoutAttributes], maxLength: CGFloat, length: CGFloat, spacing: CGFloat, delegate: UIKit.UICollectionViewDelegateFlowLayout?) -> (indent: CGFloat, spacing: CGFloat) {
        let lineAlignment = self.collectionView(collectionView, lineAlignmentForLineAt: currentLineAttributes[0], delegate: delegate)
        switch lineAlignment {
        case .leading:
            return (0, spacing)
        case .trailing:
            return (maxLength - length, spacing)
        case .center:
            return ((maxLength - length) * 0.5, spacing)
        case .justified:
            if currentLineAttributes.count > 1 {
                return (0, spacing + (maxLength - length) / CGFloat(currentLineAttributes.count - 1))
            }
            return (0, 0)
        case .justifiedCenter:
            if currentLineAttributes.count > 1 {
                return (0, spacing + (maxLength - length) / CGFloat(currentLineAttributes.count - 1))
            }
            return ((maxLength - length) * 0.5, 0)
        case .justifiedTrailing:
            if currentLineAttributes.count > 1 {
                return (0, spacing + (maxLength - length) / CGFloat(currentLineAttributes.count - 1))
            }
            return ((maxLength - length), 0)
        }
    }

}


/// 描述了 UICollectionView 中元素的布局信息。
@objc(XZCollectionViewIndexPath) public protocol UICollectionViewIndexPath: class {
    /// 元素在其所在的 section 中的序数。
    var item:    Int { get }
    /// 元素所在的 section 在 UICollectionView 中的序数。
    var section: Int { get }
    /// 元素在其所在的 line 中的序数。
    var column:  Int { get }
    /// 元素所在的 line 在 section 中的序数。
    var line:    Int { get }
}


extension UICollectionViewFlowLayout.LineAlignment {
    
    public func lineLayout(with maxLength: CGFloat, length: CGFloat, minSpacing: CGFloat, count: Int) -> (indent: CGFloat, spacing: CGFloat) {
        switch self {
        case .leading:
            return (0, minSpacing)
        case .trailing:
            return (maxLength - length, minSpacing)
        case .center:
            return ((maxLength - length) * 0.5, minSpacing)
        case .justified:
            if count > 1 {
                return (0, minSpacing + (maxLength - length) / CGFloat(count - 1))
            }
            return (0, 0)
        case .justifiedCenter:
            if count > 1 {
                return (0, minSpacing + (maxLength - length) / CGFloat(count - 1))
            }
            return ((maxLength - length) * 0.5, 0)
        case .justifiedTrailing:
            if count > 1 {
                return (0, minSpacing + (maxLength - length) / CGFloat(count - 1))
            }
            return ((maxLength - length), 0)
        }
    }
    
}
