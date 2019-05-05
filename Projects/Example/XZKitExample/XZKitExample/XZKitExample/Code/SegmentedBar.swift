//
//  SegmentedBar.swift
//  XZKit
//
//  Created by mlibai on 2017/7/14.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

extension SegmentedBar {
    
    /// 1. 可接收点击事件，供 SegmentedBar 使用。
    /// 2. 点击事件需对外隐藏。
    /// 3. 尽量让使用者去布局视图。
    @objc(XZSegmentedBarItemView)
    open class ItemView: UIView {
        
        @objc(XZSegmentedBarItemViewContentView)
        private class ContentView: UIControl { }
        
        let contentView: UIView = ContentView()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
            
            (contentView as! ContentView).addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        fileprivate weak var delegate: SegmentedBarItemViewDelegate?
        
        @objc private func buttonAction(_ button: UIButton) {
            delegate?.itemViewWasTouchedUpInside(self)
        }
        
        fileprivate var index: Int = 0
        
        // 是否处于选中状态
        open var isSelected: Bool {
            get {
                return (contentView as! ContentView).isSelected
            }
            set {
                (contentView as! ContentView).isSelected = newValue
            }
        }
        
    }
    
}

@objc(XZSegmentedBarDelegate)
public protocol SegmentedBarDelegate: class {
    
    /// SegmentedBar 获取每个 item 的宽度。请返回大于 0 的数，否则使用默认设置。
    ///
    /// - Parameters:
    ///   - segmentedBar: SegmentedBar
    ///   - index: index of the item
    /// - Returns: the item's width
    func segmentedBar(_ segmentedBar: SegmentedBar, widthForItemAt index: Int) -> CGFloat
    
    /// 当 SegmentedBar 被点击时，触发了选中的 item 变更事件。
    ///
    /// - Parameters:
    ///   - segmentedBar: SegmentedBar
    ///   - index: the new selected index
    func segmentedBar(_ segmentedBar: SegmentedBar, didSelectItemAt index: Int)
}

@objc(XZSegmentedBarDataSource)
public protocol SegmentedBarDataSource: class {
    
    /// SegmentedBar 获取要显示 item 的个数。
    ///
    /// - Parameter segmentedBar: SegmentedBar
    /// - Returns: the count of item in SegmentedBar
    func numberOfItemsInSegmentedBar(_ segmentedBar: SegmentedBar) -> Int
    
    /// SegmentedBar 获取指定位置的 item 视图。
    ///
    /// - Parameters:
    ///   - segmentedBar: SegmentedBar
    ///   - index: the index of the view
    ///   - view: the view may be reused
    /// - Returns: the item view to be displayed
    func segmentedBar(_ segmentedBar: SegmentedBar, viewForItemAt index: Int, reusing view: SegmentedBar.ItemView?) -> SegmentedBar.ItemView
}


@objc(XZSegmentedBar)
open class SegmentedBar: UIView {

    open weak var dataSource: SegmentedBarDataSource?
    open weak var delegate: SegmentedBarDelegate?
    
    /// 默认宽度 44.0
    open var itemWidth: CGFloat = 44.0
    
    /// 指示器高度，暂不支持。
    open var indicatorHeight: CGFloat = 0.0
    
    var itemViews: [ItemView] = []
    
    /// 内部可滚动的 scrollView
    public let scrollView: UIScrollView = UIScrollView()
    
    // MARK: - 初始化
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialize()
    }
    
    private func didInitialize() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = self.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(scrollView)
    }
    
    // MARK: 布局
    
    func removeAllItemViews() {
        for itemView in itemViews {
            itemView.removeFromSuperview()
        }
        itemViews.removeAll()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let kBounds = self.bounds
        
        guard let dataSource = self.dataSource else {
            removeAllItemViews()
            return
        }
        
        let numberOfItems = dataSource.numberOfItemsInSegmentedBar(self)
        
        // 1. 没有
        guard numberOfItems > 0 else {
            removeAllItemViews()
            return
        }
        
        // 2. 数量发生变化
        if numberOfItems < itemViews.count {
            for _ in numberOfItems ..< itemViews.count {
                itemViews.last?.removeFromSuperview()
                itemViews.removeLast()
            }
        }
        
        // 3. 获取宽度
        var itemWidths: [CGFloat] = []
        var maxX: CGFloat = 0
        for index in 0 ..< numberOfItems {
            var itemWidth = self.itemWidth;
            if let width = delegate?.segmentedBar(self, widthForItemAt: index) {
                if width > 0 {
                    itemWidth = width;
                }
            }
            itemWidths.append(itemWidth)
            maxX += itemWidth
        }
        
        maxX = max(kBounds.width, maxX)
        
        // 4. 设置内容区域
        scrollView.contentSize = CGSize(width: maxX, height: kBounds.height)
        
        // 5. 子视图
        for index in 0 ..< numberOfItems {
            var itemView: ItemView! = nil
            if index < itemViews.count {
                itemView = dataSource.segmentedBar(self, viewForItemAt: index, reusing: itemViews[index])
                if itemViews[index] != itemView {
                    itemViews.remove(at: index)
                    itemViews.insert(itemView, at: index)
                }
            } else {
                itemView = dataSource.segmentedBar(self, viewForItemAt: index, reusing: nil)
                itemViews.append(itemView)
            }
            
            let itemWidth   = itemWidths[index]
            maxX -= itemWidth
            itemView.frame  = CGRect(x: maxX, y: 0, width: itemWidth, height: kBounds.height - indicatorHeight)
            
            scrollView.addSubview(itemView)
            
            itemView.index      = index
            itemView.delegate   = self
        }
        
        moveSelectedItemViewToCenter()
    }
    
    fileprivate weak var selectedItemView: ItemView? {
        didSet {
            guard oldValue != selectedItemView else {
                return
            }
            oldValue?.isSelected = false
            selectedItemView?.isSelected = true
        }
    }
    
    /// 当前选中的索引
    open var selectedIndex: Int? {
        get {
            return selectedItemView?.index
        }
        set {
            var itemView: ItemView? = nil
            if let index = newValue {
                if itemViews.isEmpty {
                    layoutIfNeeded()
                }
                itemView = itemViews[index]
            }
            self.selectedItemView = itemView
            moveSelectedItemViewToCenter()
        }
    }
    
    func moveSelectedItemViewToCenter() {
        if let point = selectedItemView?.center {
            let viewWidth = scrollView.bounds.width
            let minX: CGFloat = 0
            let maxX: CGFloat = scrollView.contentSize.width - viewWidth
            let asmX: CGFloat = point.x - viewWidth * 0.5
            let offset = CGPoint(x: min(maxX, max(minX, asmX)), y: 0)
            scrollView.setContentOffset(offset, animated: true)
        } else {
            scrollView.setContentOffset(.zero, animated: true)
        }
    }
    
    /// 刷新数据
    open func reloadData() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}

extension SegmentedBar: SegmentedBarItemViewDelegate {
    
    func itemViewWasTouchedUpInside(_ itemView: SegmentedBar.ItemView) {
        guard selectedItemView != itemView else {
            return
        }
        selectedItemView = itemView
        moveSelectedItemViewToCenter()
        delegate?.segmentedBar(self, didSelectItemAt: itemView.index)
    }
    
}


fileprivate protocol SegmentedBarItemViewDelegate: class {
    
    func itemViewWasTouchedUpInside(_ itemView: SegmentedBar.ItemView)
}
