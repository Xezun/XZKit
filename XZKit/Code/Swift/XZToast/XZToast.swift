//
//  XZToast.swift
//  ChatGPT
//
//  Created by Xezun on 2023/12/11.
//

import UIKit
import XZGeometry
import XZTextImageView

#if SWIFT_PACKAGE
import XZToastObjC
#endif

extension XZToast {
    
    public static func message(_ text: String) -> XZToast {
        let button = UIButton.init(type: .system)
        button.setTitle(text, for: .normal)
        button.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        button.backgroundColor = .init(white: 0, alpha: 0.7)
        button.layer.cornerRadius = 6.0
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        return XZToast.init(view: button)
    }
}

/// 提示信息。
//public struct XZToast : RawRepresentable, ExpressibleByStringLiteral {
//    
//    public typealias RawValue = String
//    public typealias StringLiteralType = String
//    
//    public var rawValue: String {
//        return text
//    }
//    
//    let type: __XZToastType
//    
//    public let text: String
//    
//    public let image: UIImage?
//    
//    public let view: UIView?
//    
//    public let isExclusive: Bool
//    
//    public init(stringLiteral value: String) {
//        self.init(rawValue: value)
//    }
//    
//    public init(rawValue: String) {
//        self.init(type: .message, text: rawValue, image: nil, view: nil, isExclusive: false)
//    }
//    
//    private init(type: __XZToastType, text: String, image: UIImage?, view: UIView?, isExclusive: Bool) {
//        self.type = type;
//        self.text = text;
//        self.image = image;
//        self.view = view;
//        self.isExclusive = isExclusive;
//    }
//    
//    /// 消息提示。
//    public static func message(_ text: String, image: UIImage? = nil) -> XZToast {
//        return self.init(type: .message, text: text, image: image, view: nil, isExclusive: false)
//    }
//    
//    /// 加载提示。
//    /// - Note: 此类型的提示信息，不自动隐藏，需要调用 `hideToast()` 方法。
//    public static func loading(_ text: String, image: UIImage? = nil) -> XZToast {
//        return self.init(type: .loading, text: text, image: image, view: nil, isExclusive: true)
//    }
//    
//    
//}

/// Toast 回调闭包
/// - Parameter finished: 是否完成整个展示过程，被中断或切换到其它 toast 时，此参数为 false
//public typealias XZToastCompletion = (_ finished: Bool) -> Void
//
//extension UIResponder {
//    
//    /// 展示 XZToast 提示信息。
//    /// - Note: 提示信息基于控制，子视图调用此方法，等同于视图所在的控制器调用此方法，因此没有添加到控制器的视图调用此方法无效。
//    /// - Parameters:
//    ///   - toast: 提示内容
//    ///   - duration: 展示时长
//    ///   - offset: 位置偏移
//    ///   - completion: 展示完成后的回调，如果控制器未加载，回调立即执行
//    @objc(xz_showToast:duration:position:offset:exclusive:completion:)
//    public func showToast(_ toast: XZToast, duration: TimeInterval, position: NSDirectionalRectEdge, offset: CGPoint, exclusive: Bool, completion: XZToastCompletion?) {
//        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
//        window.rootViewController?.showToast(toast, duration: duration, position: position, offset: offset, exclusive: exclusive, completion: completion)
//    }
//    
//    /// 隐藏 XZToast 提示信息。
//    /// - Parameter completion: 提示信息隐藏后的回调，如果当前没有 toast 回调将立即执行
//    @objc(xz_hideToast:) public func hideToast(_ completion: XZToastCompletion?) {
//        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
//        window.rootViewController?.hideToast(completion)
//    }
//    
//    /// 布局提示信息视图控件。
//    ///
//    /// 默认情况下，提示信息展示在页面安全区中心位置。当页面大小或者安全区大小发生改变时，可调用此方法调整位置。
//    @objc(xz_layoutToastView) public func layoutToastView() {
//        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
//        window.rootViewController?.layoutToastView()
//    }
//    
//    private static var _key = 0
//    
//    @objc(xz_toastView) fileprivate var toastView: XZToastView? {
//        @objc(xz_toastView) get {
//            return objc_getAssociatedObject(self, &UIResponder._key) as? XZToastView
//        }
//        @objc(xz_setToastView:) set {
//            objc_setAssociatedObject(self, &UIResponder._key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}
//
//extension UIView {
//    
//    public override func showToast(_ toast: XZToast, duration: TimeInterval, position: NSDirectionalRectEdge, offset: CGPoint, exclusive: Bool, completion: XZToastCompletion?) {
//        self.next?.showToast(toast, duration: duration, position: position, offset: offset, exclusive: exclusive, completion: completion)
//    }
//    
//    public override func hideToast(_ completion: XZToastCompletion?) {
//        self.next?.hideToast(completion)
//    }
//    
//    public override func layoutToastView() {
//        self.next?.layoutToastView()
//    }
//    
//}
//
//extension UIWindow {
//      
//    public override func showToast(_ toast: XZToast, duration: TimeInterval, position: NSDirectionalRectEdge, offset: CGPoint, exclusive: Bool, completion: XZToastCompletion?) {
//        self.rootViewController?.showToast(toast, duration: duration, position: position, offset: offset, exclusive: exclusive, completion: completion)
//    }
//    
//    public override func hideToast(_ completion: XZToastCompletion?) {
//        self.rootViewController?.hideToast(completion)
//    }
//    
//}
//
//extension UIViewController {
//    
//    public override func showToast(_ toast: XZToast, duration: TimeInterval, position: NSDirectionalRectEdge, offset: CGPoint, exclusive: Bool, completion: XZToastCompletion?) {
//        guard let view = self.viewIfLoaded else {
//            completion?(false)
//            return
//        }
//        
//        var toastView : XZToastView! = self.toastView
//        if toastView == nil {
//            toastView = XZToastView.init()
//            toastView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
//            toastView.alpha = 0
//            view.addSubview(toastView)
//            self.toastView = toastView
//        } else {
//            // 复用现有的视图。
//            toastView.didComplete(false)
//            // 由于复用的视图，可能处于退场的过程中，因此获取当前的 alpha 作为动画的起始状态
//            let alpha = toastView.layer.presentation()?.opacity ?? 1.0;
//            toastView.layer.removeAllAnimations()
//            toastView.alpha = CGFloat.init(alpha);
//            toastView.identifier += 1
//            view.bringSubviewToFront(toastView)
//        }
//        toastView.offset = offset
//        toastView.toast = toast
//        toastView.completion = completion
//        
//        if toastView.frame.isEmpty {
//            self.layoutToastView()
//            UIView.animate(withDuration: 0.35) {
//                toastView.alpha = 1.0
//            }
//        } else {
//            UIView.animate(withDuration: 0.35) {
//                self.layoutToastView()
//                toastView.alpha = 1.0
//            }
//        }
//        
//        let identifier = toastView.identifier
//        
//        if duration.isInfinite {
//            // 不
//        } else {
//            // 延时自动隐藏
//            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(Int(duration)))) { [weak self, toastView] in
//                guard let toastView = toastView else { return }
//                guard let responder = self else { return }
//                guard toastView.identifier == identifier else {
//                    return
//                }
//                
//                UIView.animate(withDuration: 0.35) {
//                    toastView.alpha = 0
//                } completion: { finished in
//                    responder.didHideToastView(toastView, identifier: identifier, finished: true)
//                }
//            }
//        }
//    }
//    
//    public override func hideToast(_ completion: XZToastCompletion?) {
//        guard let toastView = self.toastView else {
//            completion?(false)
//            return
//        }
//        
//        let identifier = toastView.identifier
//        
//        UIView.animate(withDuration: 0.35) {
//            toastView.alpha = 0
//        } completion: { finished in
//            // showToast 的回调
//            self.didHideToastView(toastView, identifier: identifier, finished: false)
//            // hideToast 的回调
//            completion?(finished)
//        }
//    }
//    
//    private func didHideToastView(_ toastView: XZToastView, identifier: Int, finished: Bool) {
//        guard toastView.identifier == identifier else {
//            return
//        }
//        
//        // 执行 showToast 回调
//        toastView.didComplete(finished)
//        
//        // 由于可能在回调中，重新展示 toast 所以要重新判断
//        guard toastView.identifier == identifier else {
//            return
//        }
//        
//        // 移除并销毁视图
//        toastView.removeFromSuperview()
//        self.toastView = nil
//    }
//    
//    public override func layoutToastView() {
//        guard let toastView = self.toastView else { return }
//        let offset = toastView.offset
//        
//        toastView.sizeToFit()
//        toastView.center = self.toastCenter(in: view, offset: offset);
//        toastView.layoutIfNeeded()
//    }
//    
//    private func toastCenter(in view: UIView, offset: CGPoint) -> CGPoint {
//        if let scrollView = view as? UIScrollView {
//            let bounds = scrollView.bounds.inset(by: scrollView.adjustedContentInset)
//            return CGPoint(x: bounds.midX + offset.x, y: bounds.midY + offset.y)
//        }
//        let bounds = view.bounds.inset(by: view.safeAreaInsets)
//        return CGPoint(x: bounds.midX + offset.x, y: bounds.midY + offset.y)
//    }
//    
//}
//
//private class XZToastView : UIView {
//    
//    var completion: XZToastCompletion?
//    
//    /// 同步清除并执行 completion 回调
//    func didComplete(_ finished: Bool) {
//        guard let completion = self.completion else {
//            return
//        }
//        self.completion = nil;
//        completion(finished);
//    }
//    
//    var toast: XZToast? {
//        didSet {
//            if let toast = self.toast {
//                contentView.textLabel.text = toast.text
//                
//                if let view = toast.view {
//                    contentView.imageView = view
//                } else if let image = toast.image {
//                    if let imageView = contentView.imageView as? UIImageView {
//                        imageView.image = image
//                    } else {
//                        let imageView = UIImageView.init(image: image)
//                        contentView.imageView = imageView
//                    }
//                } else if toast.isExclusive {
//                    
//                } else {
//                    contentView.imageView = nil;
//                }
//                
//                switch toast.type {
//                case .message:
//                    if let view = toast.view {
//                        contentView.imageView = view
//                    } else if let image = toast.image {
//                        if let imageView = contentView.imageView as? UIImageView {
//                            imageView.image = image
//                        } else {
//                            let imageView = UIImageView.init(image: image)
//                            contentView.imageView = imageView
//                        }
//                    } else {
//                        contentView.imageView = nil
//                    }
//                case .loading:
//                    if let view = toast.view {
//                        contentView.imageView = view
//                    } else if let image = toast.image {
//                        if let imageView = contentView.imageView as? UIImageView {
//                            imageView.image = image
//                        } else {
//                            let imageView = UIImageView.init(image: image)
//                            contentView.imageView = imageView
//                        }
//                    } else if let indicator = contentView.imageView as? UIActivityIndicatorView {
//                        indicator.startAnimating()
//                    } else {
//                        let indicator = {
//                            if #available(iOS 13.0, *) {
//                                return UIActivityIndicatorView.init(style: .large)
//                            }
//                            return UIActivityIndicatorView.init(style: .whiteLarge)
//                        }()
//                        indicator.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
//                        indicator.color = .white
//                        contentView.imageView = indicator
//                    }
//                    
//                    contentView.sizeToFit()
//                default:
//                    break
//                }
//            } else {
//                contentView.textLabel.text = nil
//            }
//        }
//    }
//    
//    var identifier: Int = 0
//    var offset = CGPoint.zero
//    
//    private let contentView = XZToastContentView.init()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        layer.shadowColor   = UIColor.black.cgColor
//        layer.shadowRadius  = 3.0
//        layer.shadowOpacity = 0.8
//        layer.shadowOffset  = .zero
//        
//        contentView.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10);
//        
//        contentView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
//        contentView.backgroundColor = UIColor(white: 0, alpha: 0.7)
//        contentView.clipsToBounds = true
//        contentView.layer.cornerRadius = 6.0
//        addSubview(contentView)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let rect = bounds.inset(by: layoutMargins)
//        contentView.center = CGPoint(x: rect.midX, y: rect.midY);
//    }
//    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        let size = contentView.sizeThatFits(size)
//        let edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        return CGSize(width: edgeInsets.left + size.width + edgeInsets.right, height: edgeInsets.top + size.height + edgeInsets.bottom)
//    }
//    
//}
//
//private class XZToastContentView: UIView, XZTextImageLayout {
//    
//    private(set) var textViewIfLoaded: UILabel?
//    private(set) var imageViewIfLoaded: UIView?
//    var contentInsets: NSDirectionalEdgeInsets = .zero {
//        didSet {
//            self.setNeedsLayout()
//        }
//    }
//    var textLayoutOrientation: XZRectEdge {
//        return .top
//    }
//    
//    let textLabel = UILabel.init()
//    
//    var imageView: UIView?  {
//        get {
//            return imageViewIfLoaded
//        }
//        set {
//            if let oldValue = imageViewIfLoaded {
//                oldValue.removeFromSuperview()
//                imageViewIfLoaded = nil
//            }
//            if let newValue = newValue {
//                imageViewIfLoaded = newValue;
//                let bounds = self.bounds
//                newValue.center = CGPoint(x: bounds.midX, y: bounds.midY)
//                addSubview(newValue)
//            }
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        textLabel.textColor = .white
//        textLabel.numberOfLines = 5
//        textLabel.font = UIFont.systemFont(ofSize: 16.0)
//        textLabel.adjustsFontSizeToFitWidth = true
//        textLabel.minimumScaleFactor = 0.8
//        textLabel.textAlignment = .center
//        textLabel.lineBreakMode = .byTruncatingMiddle
//        textLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
//        addSubview(textLabel)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private let indicatorSize = CGSize(width: 50.0, height: 50.0)
//    private let edgeInsets    = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15);
//    private let spacing: CGFloat = 10
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.layoutTextImageViews()
//    }
//    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        return textImageSizeThatFits(size)
//    }
//    
//    override var intrinsicContentSize: CGSize {
//        return textImageIntrinsicSize
//    }
//}
//
//extension XZToast: ReferenceConvertible {
//    
//    public typealias _ObjectiveCType = __XZToast
//    
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(type)
//        hasher.combine(text)
//    }
//    
//    public static func ==(lhs: XZToast, rhs: XZToast) -> Bool {
//        return false
//    }
//    
//    public func _bridgeToObjectiveC() -> __XZToast {
//        return .init(type: type, text: text, image: image, view: view, isExclusive: isExclusive)
//    }
//    
//    public static func _forceBridgeFromObjectiveC(_ source: __XZToast, result: inout XZToast?) {
//        result = .init(type: source.type, text: source.text, image: source.image, view: source.view, isExclusive: source.isExclusive)
//    }
//    
//    public static func _conditionallyBridgeFromObjectiveC(_ source: __XZToast, result: inout XZToast?) -> Bool {
//        _forceBridgeFromObjectiveC(source, result: &result)
//        return true
//    }
//    
//    public static func _unconditionallyBridgeFromObjectiveC(_ source: __XZToast?) -> XZToast {
//        if let source = source {
//            return .init(type: source.type, text: source.text, image: source.image, view: source.view, isExclusive: source.isExclusive)
//        }
//#if DEBUG
//        return .message("<XZToast> 参数错误")
//#else
//        if #available(iOS 15, *) {
//            return .message(String(localized: "未知信息"))
//        }
//        return .message(NSLocalizedString("未知信息", comment: "未知信息"));
//#endif
//    }
//    
//    public typealias ReferenceType = NSString
//
//    public var debugDescription: String {
//        return "<XZToast: \(text)>"
//    }
//    
//    public var description: String {
//        return text
//    }
//    
//}

private let successImageData = """
PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/PjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTV
kcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+PHN2ZyB0PSIxNz
QwOTgyNjI2MDcxIiBjbGFzcz0iaWNvbiIgdmlld0JveD0iMCAwIDEwMjQgMTAyNCIgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR
0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHAtaWQ9IjEwMjA1IiB3aWR0aD0iMTUwIiBoZWlnaHQ9IjE1MCIgeG1sbnM6eGxp
bms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPjxwYXRoIGQ9Ik01MDguMzU2ODU1IDc0Ljk2NTg5MWMtMjU2LjMzM
DAzMiAwLTQ2NC4xMzI1NTYgMjA3Ljc5MjI5MS00NjQuMTMyNTU2IDQ2NC4xMzI1NTYgMCAyNTYuMzMwMDMyIDIwNy44MDI1Mj
QgNDY0LjEzMjU1NiA0NjQuMTMyNTU2IDQ2NC4xMzI1NTYgMjU2LjM0MDI2NiAwIDQ2NC4xMzI1NTYtMjA3LjgwMjUyNCA0NjQ
uMTMyNTU2LTQ2NC4xMzI1NTZDOTcyLjQ4OTQxMiAyODIuNzU4MTgyIDc2NC42OTcxMjEgNzQuOTY1ODkxIDUwOC4zNTY4NTUg
NzQuOTY1ODkxek04MDcuMzE5ODY4IDM2Ny41NzM4NjhjMCAwLTIyOS45OTkxMDEgMTM2LjY3OTMzMi0zNzkuNDgwNjA3IDM4N
S45Mzc5NzktNzMuNDA1Mjc1LTEwOC4xMzc5NTMtMTc0LjIwNTc3LTIwMS4yMDE4ODMtMTc0LjIwNTc3LTIwMS4yMDE4ODNzLT
MuNDU4OTQxLTc5Ljg1MjQxMyA0OC4xMDc5MzItNTQuOTEzMjQ1YzAgMCA0MS4yNDEyMTggMTcuMTMwOTY3IDExMi40NjY3NDY
gODUuODM5MDQxIDIwOC43MzM3NzgtMTg2LjE4OTI2MSAzNzEuOTQ4NzEyLTI1NC43ODQ3NjYgMzcxLjk0ODcxMi0yNTQuNzg0
NzY2QzgyNi4yMTEwMDcgMzA4LjMyMTU5NyA4MDcuMzE5ODY4IDM2Ny41NzM4NjggODA3LjMxOTg2OCAzNjcuNTczODY4eiIgZ
mlsbD0iI2ZmZmZmZiIgcC1pZD0iMTAyMDYiPjwvcGF0aD48L3N2Zz4=
""";

private let failureImageData = """
PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/PjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTV
kcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+PHN2ZyB0PSIxNz
QxMDA1NjY5NzI3IiBjbGFzcz0iaWNvbiIgdmlld0JveD0iMCAwIDEwMjQgMTAyNCIgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR
0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHAtaWQ9IjIwMzAiIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5
L3hsaW5rIiB3aWR0aD0iMTUwIiBoZWlnaHQ9IjE1MCI+PHBhdGggZD0iTTUxMS4wNzA4MzggNzAuMjA5MDM4Yy0yNDQuMTQzN
DYzIDAtNDQyLjA3MDMyNCAxOTcuOTI2ODYyLTQ0Mi4wNzAzMjQgNDQyLjA3MDMyNHMxOTcuOTI2ODYyIDQ0Mi4wNzAzMjQgND
QyLjA3MDMyNCA0NDIuMDcwMzI0IDQ0Mi4wNzAzMjQtMTk3LjkyNjg2MiA0NDIuMDcwMzI0LTQ0Mi4wNzAzMjRTNzU1LjIxNTM
yNCA3MC4yMDkwMzggNTExLjA3MDgzOCA3MC4yMDkwMzh6TTcwNi4xOTY5MSA1NzEuNzg2NjY1IDMxNS45NDU3ODkgNTcxLjc4
NjY2NWMtMzIuODY5NjE4IDAtNTkuNTA2Mjc5LTI2LjY2NjMzNi01OS41MDYyNzktNTkuNTA2Mjc5IDAtMzIuODY4NTk1IDI2L
jYzNzY4NC01OS41MzQ5MzEgNTkuNTA2Mjc5LTU5LjUzNDkzMWwzOTAuMjUyMTQ1IDBjMzIuODY5NjE4IDAgNTkuNTA2Mjc5ID
I2LjY2NjMzNiA1OS41MDYyNzkgNTkuNTM0OTMxUzczOS4wOTUxODEgNTcxLjc4NjY2NSA3MDYuMTk2OTEgNTcxLjc4NjY2NXo
iIHAtaWQ9IjIwMzEiIGZpbGw9IiNmZmZmZmYiPjwvcGF0aD48L3N2Zz4=
"""

