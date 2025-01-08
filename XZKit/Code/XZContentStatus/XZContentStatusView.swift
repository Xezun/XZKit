//
//  XZContentStatusView.swift
//  AFNetworking
//
//  Created by Xezun on 2017/12/2.
//

import UIKit
import XZTextImageView

public protocol XZContentStatusView1: UIControl, XZContentStatusRepresentable {
    
    func setTitle(_ title: String?, for contentStatus: XZContentStatus)
    func title(for contentStatus: XZContentStatus) -> String?
    
    func setTitleInsets(_ titleEdgeInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus)
    func titleInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets
    
    func setTitleColor(_ titleColor: UIColor?, for contentStatus: XZContentStatus)
    func titleColor(for contentStatus: XZContentStatus) -> UIColor?
    
    func setTitleFont(_ titleFont: UIFont?, for contentStatus: XZContentStatus)
    func titleFont(for contentStatus: XZContentStatus) -> UIFont?
    
    func setTitleShadowColor(_ titleShadowColor: UIColor?, for contentStatus: XZContentStatus)
    func titleShadowColor(for contentStatus: XZContentStatus) -> UIColor?
    
    func setAttributedTitle(_ attributedTitle: NSAttributedString?, for contentStatus: XZContentStatus)
    func attributedTitle(for contentStatus: XZContentStatus) -> NSAttributedString?
    
    func setImage(_ image: UIImage?, for contentStatus: XZContentStatus)
    func image(for contentStatus: XZContentStatus) -> UIImage?
    
    func setImageInsets(_ imageEdgeInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus)
    func imageInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets
    
    func setBackgroundImage(_ backgroundImage: UIImage?, for contentStatus: XZContentStatus)
    func backgroundImage(for contentStatus: XZContentStatus) -> UIImage?
    
    func setBackgroundColor(_ backgroundColor: UIColor?, for contentStatus: XZContentStatus)
    func backgroundColor(for contentStatus: XZContentStatus) -> UIColor?
    
    func setContentInsets(_ contentInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus)
    func contentInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets
    
}

@MainActor fileprivate class XZContentStatusStorage: NSObject {
    
    class Styles {
        var title: String?
        var attributedTitle: NSAttributedString?
        var image: UIImage?
        var backgroundImage: UIImage?
        var font: UIFont?
        var titleColor: UIColor?
        var titleShadowColor: UIColor?
    }
    
    var view: XZContentStatusView?
    var styles = [XZContentStatus: Styles]()
    var status = XZContentStatus.default
}

/// 呈现视图内容状态的视图。
@MainActor @objc open class XZContentStatusView: UIControl, XZTextImageLayout, XZContentStatusView1 {
    
    public var textLabelIfLoaded: UILabel?
    
    public var imageViewIfLoaded: UIImageView?
    
    /// 状态视图所属的视图。
    public unowned let view: UIView
    
    public var status = XZContentStatus.default {
        didSet {
            
        }
    }
    
    /// 新创建的视图与 view 相同大小且背景色一致。
    ///
    /// - Parameter view: 新构造的视图所属的视图。
    public required init(for view: UIView) {
        self.view = view
        super.init(frame: view.bounds)
        super.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        super.backgroundColor = view.backgroundColor
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

