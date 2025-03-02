//
//  XZToast.swift
//  ChatGPT
//
//  Created by Xezun on 2023/12/11.
//

import UIKit

/// 提示信息。
public enum XZToast {
    
    /// 消息提示。
    case message(_ text: String)
    
    /// 加载提示。
    /// - Note: 此类型的提示信息，不自动隐藏，需要调用 `hideToast()` 方法。
    case loading(_ text: String)
    
    /// Toast 回调闭包
    /// - Parameter finished: 是否完成整个展示过程，被中断或切换到其它 toast 时，此参数为 false
    public typealias Completion = (_ finished: Bool) -> Void
    
}

extension UIResponder {
    
    /// 展示提示信息。
    /// - Note: 提示信息基于控制，子视图调用此方法，等同于视图所在的控制器调用此方法，因此没有添加到控制器的视图调用此方法无效。
    /// - Parameters:
    ///   - toast: 提示内容
    ///   - duration: 展示时常
    ///   - offset: 位置偏移
    ///   - completion: 展示完成后的回调，如果控制器未加载，回调立即执行
    @objc public func showToast(_ toast: XZToast, duration: TimeInterval = 3.0, offset: CGPoint = .zero, completion: XZToast.Completion? = nil) {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        window.rootViewController?.showToast(toast, duration: duration, offset: offset, completion: completion)
    }
    
    /// 隐藏提示信息。
    /// - Parameter completion: 提示信息隐藏后的回调，如果当前没有 toast 回调将立即执行
    @objc public func hideToast(_ completion: XZToast.Completion? = nil) {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        window.rootViewController?.hideToast(completion)
    }
    
    /// 布局提示信息视图控件。
    ///
    /// 默认情况下，提示信息展示在页面安全区中心位置。当页面大小或者安全区大小发生改变时，可调用此方法调整位置。
    @objc public func layoutToastView() {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        window.rootViewController?.layoutToastView()
    }
    
    private static var _key = 0
    @objc(xz_toastView) fileprivate var toastView: XZToastView? {
        get {
            return objc_getAssociatedObject(self, &UIResponder._key) as? XZToastView
        }
        set {
            objc_setAssociatedObject(self, &UIResponder._key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIViewController {
    
    public override func showToast(_ toast: XZToast, duration: TimeInterval = 3.0, offset: CGPoint = .zero, completion: XZToast.Completion? = nil) {
        guard let view = self.viewIfLoaded else {
            completion?(false)
            return
        }
        
        var toastView : XZToastView! = self.toastView
        if toastView == nil {
            toastView = XZToastView.init()
            toastView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
            toastView.alpha = 0
            view.addSubview(toastView)
            self.toastView = toastView
        } else {
            // 复用现有的视图。
            toastView.didComplete(false)
            // 由于复用的视图，可能处于退场的过程中，因此获取当前的 alpha 作为动画的起始状态
            let alpha = toastView.layer.presentation()?.opacity ?? 1.0;
            toastView.layer.removeAllAnimations()
            toastView.alpha = CGFloat.init(alpha);
            toastView.identifier += 1
            view.bringSubviewToFront(toastView)
        }
        toastView.offset = offset
        toastView.toast = toast
        toastView.completion = completion
        
        if toastView.frame.isEmpty {
            self.layoutToastView()
            UIView.animate(withDuration: 0.35) {
                toastView.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.35) {
                self.layoutToastView()
                toastView.alpha = 1.0
            }
        }
        
        let identifier = toastView.identifier
        switch (toast) {
        case .message:
            // 延时自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(duration) * 1000)) { [weak self, toastView] in
                guard let toastView = toastView else { return }
                guard let responder = self else { return }
                guard toastView.identifier == identifier else {
                    return
                }
                
                UIView.animate(withDuration: 0.35) {
                    toastView.alpha = 0
                } completion: { finished in
                    responder.didHideToastView(toastView, identifier: identifier, finished: true)
                }
            }
        case .loading:
            // 不需要隐藏
            break
        }
    }
    
    public override func hideToast(_ completion: XZToast.Completion? = nil) {
        guard let toastView = self.toastView else {
            completion?(false)
            return
        }
        
        let identifier = toastView.identifier
        
        UIView.animate(withDuration: 0.35) {
            toastView.alpha = 0
        } completion: { finished in
            // showToast 的回调
            self.didHideToastView(toastView, identifier: identifier, finished: false)
            // hideToast 的回调
            completion?(finished)
        }
    }
    
    private func didHideToastView(_ toastView: XZToastView, identifier: Int, finished: Bool) {
        guard toastView.identifier == identifier else {
            return
        }
        
        // 执行 showToast 回调
        toastView.didComplete(finished)
        
        // 由于可能在回调中，重新展示 toast 所以要重新判断
        guard toastView.identifier == identifier else {
            return
        }
        
        // 移除并销毁视图
        toastView.removeFromSuperview()
        self.toastView = nil
    }
    
    public override func layoutToastView() {
        guard let toastView = self.toastView else { return }
        let offset = toastView.offset
        
        toastView.sizeToFit()
        toastView.center = self.toastCenter(in: view, offset: offset);
        toastView.layoutIfNeeded()
    }
    
    private func toastCenter(in view: UIView, offset: CGPoint) -> CGPoint {
        if let scrollView = view as? UIScrollView {
            let bounds = scrollView.bounds.inset(by: scrollView.adjustedContentInset)
            return CGPoint(x: bounds.midX + offset.x, y: bounds.midY + offset.y)
        }
        let bounds = view.bounds.inset(by: view.safeAreaInsets)
        return CGPoint(x: bounds.midX + offset.x, y: bounds.midY + offset.y)
    }
}

extension UIView {
    
    public override func showToast(_ toast: XZToast, duration: TimeInterval = 3.0, offset: CGPoint = .zero, completion: XZToast.Completion? = nil) {
        self.next?.showToast(toast, duration: duration, completion: completion)
    }
    
    public override func hideToast(_ completion: XZToast.Completion? = nil) {
        self.next?.hideToast(completion)
    }
    
    public override func layoutToastView() {
        self.next?.layoutToastView()
    }
    
}

extension UIWindow {
      
    public override func showToast(_ toast: XZToast, duration: TimeInterval = 3.0, offset: CGPoint = .zero, completion: XZToast.Completion? = nil) {
        self.rootViewController?.showToast(toast, duration: duration, completion: completion)
    }
    
    public override func hideToast(_ completion: XZToast.Completion? = nil) {
        self.rootViewController?.hideToast(completion)
    }
    
}

fileprivate class XZToastView : UIView {
    
    var completion: XZToast.Completion?
    
    /// 同步清除并执行 completion 回调
    func didComplete(_ finished: Bool) {
        guard let completion = self.completion else {
            return
        }
        self.completion = nil;
        completion(finished);
    }
    
    var toast: XZToast? {
        didSet {
            if let toast = self.toast {
                switch toast {
                case let .message(text):
                    contentView.textLabel.text = text
                    if contentView.indicator != nil {
                        contentView.indicator!.removeFromSuperview()
                        contentView.indicator = nil
                    }
                case let .loading(text):
                    if contentView.indicator == nil {
                        let indicator = {
                            if #available(iOS 13.0, *) {
                                return UIActivityIndicatorView.init(style: .large)
                            }
                            return UIActivityIndicatorView.init(style: .whiteLarge)
                        }()
                        indicator.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
                        indicator.color = .white
                        contentView.indicator = indicator
                    }
                    contentView.indicator!.startAnimating()
                    contentView.textLabel.text = text
                }
            } else {
                contentView.textLabel.text = nil
            }
        }
    }
    
    var identifier: Int = 0
    var offset = CGPoint.zero
    
    private let contentView = ContentView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 6.0
        addSubview(contentView)
        
        let textLabel = contentView.textLabel;
        textLabel.textColor = .white
        textLabel.numberOfLines = 5
        textLabel.font = UIFont.systemFont(ofSize: 16.0)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.8
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byTruncatingMiddle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds.inset(by: edgeInsets)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = contentView.sizeThatFits(size)
        return CGSize(width: edgeInsets.left + size.width + edgeInsets.right, height: edgeInsets.top + size.height + edgeInsets.bottom)
    }
    
    class ContentView: UIView {
        let textLabel = UILabel.init()
        var indicator: UIActivityIndicatorView? {
            didSet {
                oldValue?.removeFromSuperview()
                if let indicator = indicator {
                    indicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
                    addSubview(indicator)
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            textLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
            addSubview(textLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let indicatorSize = CGSize(width: 50.0, height: 50.0)
        private let edgeInsets    = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15);
        private let spacing: CGFloat = 10
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            if let indicator = self.indicator {
                indicator.frame = CGRect(x: (bounds.width - indicatorSize.width) * 0.5, y: edgeInsets.top, width: indicatorSize.width, height: indicatorSize.height)
                textLabel.frame = CGRect(x: edgeInsets.left, y: indicator.frame.maxY + spacing, width: bounds.width - edgeInsets.left - edgeInsets.right, height: bounds.height - edgeInsets.top - indicatorSize.height - spacing - edgeInsets.bottom)
            } else {
                textLabel.frame = CGRect(x: edgeInsets.left, y: edgeInsets.top, width: bounds.width - edgeInsets.left - edgeInsets.right, height: bounds.height - edgeInsets.top - edgeInsets.bottom)
            }
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let maxWidth = UIScreen.main.bounds.width - 100.0
            let textSize = textLabel.sizeThatFits(CGSize(width: maxWidth, height: 0))
            if indicator == nil {
                return CGSize(width: min(maxWidth, textSize.width) + 30.0, height: textSize.height + 20.0)
            }
            return CGSize(width: max(min(maxWidth, textSize.width), 80.0) + 30.0, height: 10.0 + 50.0 + 10.0 + textSize.height + 10.0)
        }
    }
    
}


extension XZToast: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self = .message(value)
    }
}

extension XZToast: ReferenceConvertible {
    
    public func _bridgeToObjectiveC() -> __XZToast {
        switch self {
        case let .message(text):
            return __XZToast.init(type: .message, text: text)
        case let .loading(text):
            return __XZToast.init(type: .loading, text: text)
        }
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __XZToast, result: inout XZToast?) {
        switch source.type {
        case .message:
            result = .loading(source.text)
        case .loading:
            fallthrough
        default:
            result = .message(source.text)
        }
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __XZToast, result: inout XZToast?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __XZToast?) -> XZToast {
        if let source = source {
            switch source.type {
            case .loading:
                return .loading(source.text)
            default:
                return .message(source.text)
            }
        }
#if DEBUG
        return .message("<XZToast> 参数错误")
#else
        return .message("")
#endif
    }
    
    public typealias ReferenceType = NSString

    public var debugDescription: String {
        return ""
    }
    
    public var description: String {
        return ""
    }
    
    public typealias _ObjectiveCType = __XZToast
    
}

