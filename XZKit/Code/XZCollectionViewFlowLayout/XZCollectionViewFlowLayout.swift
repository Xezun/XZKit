//
//  CollectionViewFlowLayout.swift
//  XZKit
//
//  Created by Xezun on 2018/7/10.
//  Copyright © 2018年 XEZUN INC.com All rights reserved.
//

import UIKit

/// 通过本协议，可以具体的控制 XZCollectionViewFlowLayout 布局的行对齐、元素对齐方式。
@objc public protocol XZCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    
    /// 指定行 line 的对齐方式。
    ///
    /// - Parameters:
    ///   - collectionView: UICollectionView 视图。
    ///   - layout: 调用此方法的对象。
    ///   - indexPath: line 信息，可用 `section` 和 `line` 属性。
    /// - Returns: 行对齐方式。
    @objc(collectionView:layout:lineAlignmentForLineAtIndexPath:)
    optional func collectionView(_ collectionView: UICollectionView, layout: XZCollectionViewFlowLayout, lineAlignmentForLineAt indexPath: IndexPath) -> XZCollectionViewFlowLayout.LineAlignment
    
    /// 获取同一行元素间的对齐方式：垂直滚动时，为同一横排元素在垂直方向上的对齐方式；水平滚动时，同一竖排元素，在水平方向的对齐方式。
    ///
    /// - Parameters:
    ///   - collectionView: UICollectionView 视图。
    ///   - layout: UICollectionViewLayout 视图布局对象。
    ///   - indexPath: column 信息，可用 `section`、`item`、`line`、`column` 属性。
    /// - Returns: 元素对齐方式。
    @objc(collectionView:layout:interitemAlignmentForItemAtIndexPath:)
    optional func collectionView(_ collectionView: UICollectionView, layout: XZCollectionViewFlowLayout, interitemAlignmentForItemAt indexPath: IndexPath) -> XZCollectionViewFlowLayout.InteritemAlignment
    
}


extension IndexPath {
    
    /// 生成添加了行、列信息的 IndexPath 对象。
    /// - Parameters:
    ///   - indexPath: 元素的 item、section 信息。
    ///   - column: 元素的列序。
    ///   - line: 元素当行序。
    public init(indexPath: IndexPath, column: Int, line: Int) {
        self.init(item: indexPath.item, section: indexPath.section)
        self.append(line)
        self.append(column)
    }
    
    /// 为 section 中的 line 创建 IndexPath 对象。
    /// - Parameters:
    ///   - line: line 的次序。
    ///   - section: section 的次序。
    public init(line: Int, section: Int) {
        self.init(item: 0, section: section);
        self.append(line)
        self.append(0)
    }
 
    /// 元素在 section 中行序。
    public var line: Int {
        get {
            return self[2]
        }
        set {
            self[2] = newValue
        }
    }
    
    /// 元素在 line 中的列序。
    public var column: Int {
        get {
            return self[3]
        }
        set {
            self[3] = newValue
        }
    }
}



extension XZCollectionViewFlowLayout {
    
    /// 描述了元素的行对齐方式。
    /// 1. 垂直滚动时，水平方向为一行，行的首端为左，末端为右。
    /// 2. 水平滚动时，垂直方向为一行，行的首端为上，末端为下。
    @objc(XZCollectionViewLineAlignment) public enum LineAlignment: Int {
        
        /// 首端对齐，末端不足则留空，类似于文字排版的向左对齐。
        case leading
        /// 居中对齐，不足行两端留空，类似于文字排版的居中对齐。
        case center
        /// 末端对齐，首端不足则留空，类似于文字排版的向右对齐。
        case trailing
        /// 分散两端对齐，平均分布行空间，类似于文字排版的分散两端对齐。
        /// - Note: 只有一个元素的行使用 leading 进行对齐。
        case justified
        /// 两端对齐，平均分布行空间，只有一个元素的行或最后一行使用 leading 进行对齐。
        case justifiedLeading
        /// 两端对齐，平均分布行空间，只有一个元素的行或最后一行使用 center 进行对齐
        case justifiedCenter
        /// 两端对齐，平均分布行空间，只有一个元素的行或最后一行使用 trailing 进行对齐。
        case justifiedTrailing
        
    }
    
    /// 描述了元素的内对齐方式。
    /// 1. 垂直滚动时，元素的顶部为上，底部为下。
    /// 2. 水平滚动时，元素的顶部为左，底部为右。
    @objc(XZCollectionViewInteritemAlignment) public enum InteritemAlignment: Int {
        
        /// 顶部对齐。
        case ascended
        /// 中线对齐。
        case median
        /// 底部对齐。
        case descended
        
    }
    
}

/// 记录每一行的信息。
private struct XZCollectionViewLineAttributes {
    /// 只有行号 line 和 section 值有效，其它值为 0
    var indexPath: IndexPath
    var cells = [XZCollectionViewLayoutAttributes]()
    var width: CGFloat
    var height: CGFloat
    
    init(line: Int, section: Int, width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        self.indexPath = IndexPath.init(line: line, section: section)
    }
}

private class XZCollectionViewSectionAttributes {
    /// 记录 Section 的 frame ，用于查找优化性能。
    var frame: CGRect = .zero
    var header: XZCollectionViewLayoutAttributes?
    var cells = [XZCollectionViewLayoutAttributes]()
    var footer: XZCollectionViewLayoutAttributes?
    
    // 记录以下值，为局部刷新提供比对数据
    var lines = [XZCollectionViewLineAttributes]()
    var lineSpacing: CGFloat = 0
    var interitemSpacing: CGFloat = 0
    var edgeInsets: UIEdgeInsets = .zero
    /// section 容纳元素的最大宽度
    var width: CGFloat = 0
    /// section 容纳元素的最大高度
    var height: CGFloat = 0
}

/// 额外添加 Cell 所在行 line 和列 column 的信息。
/// - Note: 不能将 line 和 column 直接记录在 indexPath 属性中，会导致通过 indexPath 查询 cell 的方法 cellForItem(at:) 无效。因此，在代理方法的参数中，是重新生成的 indexPath 对象。
@objc open class XZCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    /// 在 section 中的行序。
    open var line: Int = 0
    /// 在 line 中的列序。
    open var column: Int = 0
}

/// 支持多种对齐方式的 UICollectionView 自定义布局。
/// - Note: 优先使用 XZCollectionViewDelegateFlowLayout 作为代理协议，并兼容 UICollectionViewDelegateFlowLayout 协议。
/// - Note: 对于 zIndex 进行了特殊处理，排序越后的视图 zIndex 越大；Header/Footer 的 zIndex 比所有的 cell 都大。
@objc open class XZCollectionViewFlowLayout: UICollectionViewLayout {
    
    /// 滚动方向。默认 .vertical 。
    @objc open var scrollDirection: UICollectionView.ScrollDirection = .vertical {
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
    @objc open var sectionInsets: UIEdgeInsets = .zero {
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
    
    /// 查询 section 中 line 的数量。
    /// - Parameter section: section 次序。
    /// - Returns: line 的数量。
    @objc open func numberOfLines(inSection section: Int) -> Int {
        return self.sections[section].lines.count
    }
    
    /// 查询 section 中 line 的 column 的数量。
    /// - Parameters:
    ///   - line: line 次序。
    ///   - section: section 次序。
    /// - Returns: column 的数量。
    @objc open func numberOfColumns(inLine line: Int, inSection section: Int) -> Int {
        return self.sections[section].lines[line].cells.count
    }
    
    /// 记录了所有元素信息。
    fileprivate var sections = [XZCollectionViewSectionAttributes]()
    
    /// 记录了 contentSize 。
    fileprivate var contentSize = CGSize.zero
    
    public convenience init(lineAlignment: LineAlignment = .justified, interitemAlignment: InteritemAlignment = .median) {
        self.init()
        self.lineAlignment = lineAlignment
        self.interitemAlignment = interitemAlignment
    }
}

// MARK: - 重写父类的方法

extension XZCollectionViewFlowLayout {
    
    open override class var layoutAttributesClass: Swift.AnyClass {
        return XZCollectionViewLayoutAttributes.self
    }
    
    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    open override func invalidateLayout() {
        sections.removeAll()
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
    
    override open func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else { return }
        let delegate      = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        let bounds        = collectionView.bounds
        let contentInsets = collectionView.adjustedContentInset
        
        // 使用 (0, 0) 作为起始坐标进行计算，根据 adjustedContentInset 来计算内容区域大小。
        
        switch scrollDirection {
        case .vertical:
            contentSize = CGSize.init(width: bounds.width - contentInsets.left - contentInsets.right, height: 0)
            prepareVertical(collectionView, delegate: delegate)
            
        case .horizontal:
            contentSize = CGSize.init(width: 0, height: bounds.height - contentInsets.top - contentInsets.bottom)
            prepareHorizontal(collectionView, delegate: delegate)
            
        default:
            fatalError("scroll direction \(scrollDirection) not supported")
        }
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 超出范围肯定没有了。
        if rect.maxX <= 0 || rect.minX >= contentSize.width || rect.minY >= contentSize.height || rect.maxY <= 0 {
            return nil
        }
        
        // 在遍历时，在已遍历到 rect 范围内的 section 后，如果遍历到不在 rect 内的 section 时，就没有继续遍历了。
        // 但是对于 cells 则不能这么处理，这是因为对齐方式可能导致同一行的 cells 在 rect 内不一定都相交。
        
        var array = [XZCollectionViewLayoutAttributes]()
        
        var hasFound = false
        for section in self.sections {
            if rect.intersects(section.frame) {
                hasFound = true;
                if let header = section.header {
                    if rect.intersects(header.frame) {
                        array.append(header)
                    }
                }
                for item in section.cells {
                    if rect.intersects(item.frame) {
                        array.append(item)
                    }
                }
                if let footer = section.footer {
                    if rect.intersects(footer.frame) {
                        array.append(footer)
                    }
                }
            } else if (hasFound) {
                break
            }
        }
        
        return array
    }
    
    override open func layoutAttributesForItem(at indexPath: Foundation.IndexPath) -> UICollectionViewLayoutAttributes? {
        return sections[indexPath.section].cells[indexPath.item]
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: Foundation.IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return sections[indexPath.section].header
            
        case UICollectionView.elementKindSectionFooter:
            return sections[indexPath.section].footer
            
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

extension XZCollectionViewFlowLayout {
    
    //
    fileprivate func prepareVertical(_ collectionView: UICollectionView, delegate: UICollectionViewDelegateFlowLayout?) {
        // 先创建元素后布局，这样 numberOfLines(inSection:) 等方法可以在代理方法中使用用，以及方便以后进行局部更新的逻辑处理。
        for section in 0 ..< collectionView.numberOfSections {
            let attributes = XZCollectionViewSectionAttributes.init()
            attributes.frame.size.width = contentSize.width
            
            if let size = _delegate(delegate, collectionView: collectionView, sizeForHeaderInSectionAt: section) {
                let kind      = UICollectionView.elementKindSectionHeader
                let indexPath = IndexPath.init(item: 0, section: section)
                let header = XZCollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: kind, with: indexPath)
                header.size = size
                attributes.header = header
            }
            
            let sectionInsets    = _delegate(delegate, collectionView: collectionView, edgeInsetsForSectionAt: section)
            let lineSpacing      = _delegate(delegate, collectionView: collectionView, minimumLineSpacingForSectionAt: section)
            let interitemSpacing = _delegate(delegate, collectionView: collectionView, minimumInteritemSpacingForSectionAt: section)
            let maxWidth         = contentSize.width - sectionInsets.left - sectionInsets.right
            
            do {
                var line = XZCollectionViewLineAttributes.init(line: 0, section: section, width: -interitemSpacing, height: 0)
                for index in 0 ..< collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath.init(item: index, section: section)
                    
                    let size = _delegate(delegate, collectionView: collectionView, sizeForItemAt: indexPath)
                    let cell = XZCollectionViewLayoutAttributes(forCellWith: indexPath)
                    cell.size   = size
                    cell.line   = line.indexPath.line
                    cell.column = line.cells.count
                    
                    let newWidth = line.width + (interitemSpacing + size.width)
                    
                    if newWidth <= maxWidth || line.cells.isEmpty {
                        line.width = newWidth
                        line.height = max(line.height, size.height)
                    } else {
                        attributes.lines.append(line)
                        // 新的一行
                        line.indexPath.line += 1
                        line.width  = size.width
                        line.height = size.height
                        line.cells.removeAll()
                    }
                    line.cells.append(cell)
                    attributes.cells.append(cell)
                }
                if !line.cells.isEmpty {
                    attributes.lines.append(line)
                }
            }
            
            if let size = _delegate(delegate, collectionView: collectionView, sizeForFooterInSectionAt: section) {
                let kind      = UICollectionView.elementKindSectionFooter
                let indexPath = IndexPath.init(item: 0, section: section)
                let footer = XZCollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: kind, with: indexPath)
                footer.size = size
                attributes.footer = footer
            }
            
            attributes.edgeInsets       = sectionInsets
            attributes.lineSpacing      = lineSpacing
            attributes.interitemSpacing = interitemSpacing
            attributes.width            = maxWidth
            self.sections.append(attributes)
        }
        
        // zIndex 规则：header/footer 比 cell 大；header 比 footer 大；后面的比前面的大。
        var zIndex = 0
        for section in self.sections {
            var sectionHeight : CGFloat = 0
            
            if let header = section.header {
                let size = header.size;
                let y = contentSize.height
                header.zIndex = zIndex + section.cells.count
                header.frame  = CGRect(x: 0, y: y, width: contentSize.width, height: size.height)
                sectionHeight += size.height
            }
            
            let sectionInsets    = section.edgeInsets
            let lineSpacing      = section.lineSpacing
            let interitemSpacing = section.interitemSpacing
            let maxWidth         = section.width
            let count            = section.lines.count
            
            sectionHeight += sectionInsets.top
            if count > 0 {
                sectionHeight -= lineSpacing
                for index in 0 ..< count {
                    let line = section.lines[index]
                    let style = _delegate(delegate, collectionView: collectionView, styleForLine: line, maxLength: maxWidth, length: line.width, interitemSpacing: interitemSpacing, isLastLine: index == count - 1)
                    var x = sectionInsets.left + style.indent - style.spacing
                    
                    sectionHeight += lineSpacing
                    for cell in line.cells {
                        let size = cell.size
                        
                        x += style.spacing
                        var y = contentSize.height + sectionHeight
                        switch _delegate(delegate, collectionView: collectionView, interitemAlignmentFor: cell) {
                        case .ascended:
                            break
                        case .median:
                            y += (line.height - size.height) * 0.5
                        case .descended:
                            y += (line.height - size.height)
                        }
                        
                        cell.zIndex = zIndex
                        cell.frame  = CGRect.init(x: x, y: y, width: size.width, height: size.height)
                        
                        x += size.width
                        zIndex += 1
                    }
                    sectionHeight += line.height
                }
            }
            sectionHeight += sectionInsets.bottom
            
            if let footer = section.footer {
                let size = footer.size;
                let y = contentSize.height + sectionHeight
                footer.zIndex = zIndex + 2
                footer.frame  = CGRect(x: 0, y: y, width: contentSize.width, height: size.height)
                sectionHeight += size.height
            }

            section.height = sectionHeight
            section.frame = CGRect.init(x: 0, y: contentSize.height, width: contentSize.width, height: sectionHeight)
            contentSize.height += sectionHeight
            zIndex += 2
        }
    }
    
    fileprivate func prepareHorizontal(_ collectionView: UICollectionView, delegate: UICollectionViewDelegateFlowLayout?) {
        // 先创建元素后布局，这样 numberOfLines(inSection:) 等方法可用。
        for section in 0 ..< collectionView.numberOfSections {
            let attributes = XZCollectionViewSectionAttributes.init()
            
            if let size = _delegate(delegate, collectionView: collectionView, sizeForHeaderInSectionAt: section) {
                let kind      = UICollectionView.elementKindSectionHeader
                let indexPath = IndexPath.init(item: 0, section: section)
                let header = XZCollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: kind, with: indexPath)
                header.size = size
                attributes.header = header
            }
            
            let sectionInsets    = _delegate(delegate, collectionView: collectionView, edgeInsetsForSectionAt: section)
            let lineSpacing      = _delegate(delegate, collectionView: collectionView, minimumLineSpacingForSectionAt: section)
            let interitemSpacing = _delegate(delegate, collectionView: collectionView, minimumInteritemSpacingForSectionAt: section)
            let maxHeight        = contentSize.height - sectionInsets.top - sectionInsets.bottom
            
            do {
                var line = XZCollectionViewLineAttributes.init(line: 0, section: section, width: 0, height: -interitemSpacing)
                for index in 0 ..< collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath.init(item: index, section: section)
                    
                    let size = _delegate(delegate, collectionView: collectionView, sizeForItemAt: indexPath)
                    let cell = XZCollectionViewLayoutAttributes(forCellWith: indexPath)
                    cell.size   = size
                    cell.line   = line.indexPath.line
                    cell.column = line.cells.count
                    
                    let newHeight = line.height + (interitemSpacing + size.height)
                    
                    if newHeight <= maxHeight || line.cells.isEmpty {
                        line.height = newHeight
                        line.width  = max(line.width, size.width)
                    } else {
                        attributes.lines.append(line)
                        // 新的一行
                        line.indexPath.line += 1
                        line.width  = size.width
                        line.height = size.height
                        line.cells.removeAll()
                    }
                    line.cells.append(cell)
                    attributes.cells.append(cell)
                }
                if !line.cells.isEmpty {
                    attributes.lines.append(line)
                }
            }
            
            if let size = _delegate(delegate, collectionView: collectionView, sizeForFooterInSectionAt: section) {
                let kind      = UICollectionView.elementKindSectionFooter
                let indexPath = IndexPath.init(item: 0, section: section)
                let footer = XZCollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: kind, with: indexPath)
                footer.size = size
                attributes.footer = footer
            }
            
            attributes.edgeInsets       = sectionInsets
            attributes.lineSpacing      = lineSpacing
            attributes.interitemSpacing = interitemSpacing
            attributes.height           = maxHeight
            self.sections.append(attributes)
        }
        
        // zIndex 规则：header/footer 比 cell 大；header 比 footer 大；后面的比前面的大。
        var zIndex = 0
        for section in self.sections {
            var sectionWidth : CGFloat = 0
            
            if let header = section.header {
                let size = header.size;
                let x = contentSize.width
                header.zIndex = zIndex + section.cells.count
                header.frame  = CGRect(x: x, y: 0, width: size.width, height: contentSize.height)
                sectionWidth += size.width
            }
            
            let sectionInsets    = section.edgeInsets
            let lineSpacing      = section.lineSpacing
            let interitemSpacing = section.interitemSpacing
            let maxHeight        = section.height
            let count            = section.lines.count
            
            sectionWidth += sectionInsets.left
            if count > 0 {
                sectionWidth -= lineSpacing
                for index in 0 ..< count {
                    let line = section.lines[index]
                    let style = _delegate(delegate, collectionView: collectionView, styleForLine: line, maxLength: maxHeight, length: line.height, interitemSpacing: interitemSpacing, isLastLine: index == count - 1)
                    var y = sectionInsets.top + style.indent - style.spacing
                    
                    sectionWidth += lineSpacing
                    for cell in line.cells {
                        let size = cell.size
                        
                        var x = contentSize.width + sectionWidth
                        switch _delegate(delegate, collectionView: collectionView, interitemAlignmentFor: cell) {
                        case .ascended:
                            break
                        case .median:
                            x += (line.width - size.width) * 0.5
                        case .descended:
                            x += (line.width - size.width)
                        }
                        y += style.spacing
                        
                        cell.zIndex = zIndex
                        cell.frame  = CGRect.init(x: x, y: y, width: size.width, height: size.height)
                        
                        y += size.height
                        zIndex += 1
                    }
                    sectionWidth += line.width
                }
            }
            sectionWidth += sectionInsets.right
            
            if let footer = section.footer {
                let size = footer.size;
                let x = contentSize.width + sectionWidth
                footer.zIndex = zIndex + 2
                footer.frame  = CGRect(x: x, y: 0, width: size.width, height: contentSize.height)
                sectionWidth += size.width
            }

            section.width = sectionWidth
            section.frame = CGRect.init(x: contentSize.width, y: 0, width: sectionWidth, height: contentSize.height)
            contentSize.width += sectionWidth
            zIndex += 2
        }
    }
    
    // MARK: - 调用代理方法的便利方法
    
    /// 根据行信息计算行布局。因为每一行不能完全占满，根据对齐方式不同，x 坐标相对于起始点，可能需要不同的偏移，元素的间距也可能需要重新计算。
    private func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, styleForLine line: XZCollectionViewLineAttributes, maxLength: CGFloat, length: CGFloat, interitemSpacing: CGFloat, isLastLine: Bool) -> (indent: CGFloat, spacing: CGFloat) {
        let lineAlignment = _delegate(delegate, collectionView: collectionView, lineAlignmentForLine: line)
        switch lineAlignment {
        case .leading:
            return (0, interitemSpacing)
        case .trailing:
            return (maxLength - length, interitemSpacing)
        case .center:
            return ((maxLength - length) * 0.5, interitemSpacing)
        case .justified:
            let count = line.cells.count
            if count > 1 {
                return (0, interitemSpacing + (maxLength - length) / CGFloat(count - 1))
            }
            return (0, interitemSpacing)
        case .justifiedLeading:
            let count = line.cells.count
            if isLastLine || count == 1 {
                return (0, interitemSpacing)
            }
            return (0, interitemSpacing + (maxLength - length) / CGFloat(count - 1))
        case .justifiedCenter:
            let count = line.cells.count
            if isLastLine || count == 1 {
                return ((maxLength - length) * 0.5, interitemSpacing)
            }
            return (0, interitemSpacing + (maxLength - length) / CGFloat(count - 1))
        case .justifiedTrailing:
            let count = line.cells.count
            if isLastLine || count == 1 {
                return (maxLength - length, interitemSpacing)
            }
            return (0, interitemSpacing + (maxLength - length) / CGFloat(count - 1))
        }
    }
    
    fileprivate func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, lineAlignmentForLine line: XZCollectionViewLineAttributes) -> LineAlignment {
        guard let delegate = delegate as? XZCollectionViewDelegateFlowLayout else { return self.lineAlignment }
        if let lineAlignment = delegate.collectionView?(collectionView, layout: self, lineAlignmentForLineAt: line.indexPath) {
            return lineAlignment
        }
        return lineAlignment
    }
    
    fileprivate func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, interitemAlignmentFor attributes: XZCollectionViewLayoutAttributes) -> InteritemAlignment {
        guard let delegate = delegate as? XZCollectionViewDelegateFlowLayout else { return interitemAlignment }
        let indexPath = IndexPath.init(indexPath: attributes.indexPath, column: attributes.column, line: attributes.line)
        if let itemAlignment = delegate.collectionView?(collectionView, layout: self, interitemAlignmentForItemAt: indexPath) {
            return itemAlignment
        }
        return interitemAlignment
    }
    
    fileprivate func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, edgeInsetsForSectionAt section: Int) -> UIEdgeInsets {
        guard let delegate = delegate as? XZCollectionViewDelegateFlowLayout else { return sectionInsets }
        if let sectionInsets = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) {
            return sectionInsets
        }
        return sectionInsets
    }
    
    fileprivate func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let itemSize = delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            return itemSize
        }
        return itemSize
    }
    
    fileprivate func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let spacing = delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) {
            return spacing
        }
        return minimumLineSpacing
    }
    
    fileprivate func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let spacing = delegate?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) {
            return spacing
        }
        return minimumInteritemSpacing
    }
    
    fileprivate func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, sizeForHeaderInSectionAt section: Int) -> CGSize? {
        if let size = delegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
            return size.width > 0 && size.height > 0 ? size : nil
        }
        if headerReferenceSize.width > 0 && headerReferenceSize.height > 0 {
            return headerReferenceSize
        }
        return nil
    }
    
    fileprivate func _delegate(_ delegate: UICollectionViewDelegateFlowLayout?, collectionView: UICollectionView, sizeForFooterInSectionAt section: Int) -> CGSize? {
        if let size = delegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
            return size.width > 0 && size.height > 0 ? size : nil
        }
        if footerReferenceSize.width > 0 && footerReferenceSize.height > 0 {
            return footerReferenceSize
        }
        return nil
    }
}

extension NSIndexPath {
    
    /// 元素在 section 中行序。
    @objc(xz_line) public var line: Int {
        return self.index(atPosition: 2)
    }
    
    /// 元素在 line 中的列序。
    @objc(xz_column) public var column: Int {
        return self.index(atPosition: 3)
    }
    
}
