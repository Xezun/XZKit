//
//  XZToast.swift
//  ChatGPT
//
//  Created by 徐臻 on 2023/12/11.
//

import UIKit

/// 提示内容
public enum XZToast {
    /// 消息提示
    case message(_ text: String)
    /// 加载提示
    case loading(_ text: String)
    
    /// Toast 回调闭包
    /// - Parameter finished: 是否完成整个展示过程，被中断或切换到其它 toast 时，此参数为 false
    public typealias Completion = (_ finished: Bool) -> Void
    
}

extension UIResponder {
    
    @objc public func showToast(_ toast: XZToast, duration: TimeInterval = 3.0, completion: XZToast.Completion? = nil) {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        
        window.rootViewController?.showToast(toast, duration: duration, completion: completion)
    }
    
    @objc public func hideToast(_ completion: XZToast.Completion? = nil) {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        window.rootViewController?.hideToast(completion)
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

@MainActor
fileprivate func XZToastDidComplete(_ completion: XZToast.Completion?, _ finished: Bool) {
    if let completion = completion {
        DispatchQueue.main.async {
            completion(finished)
        }
    }
}

extension UIViewController {
    
    @objc public override func showToast(_ toast: XZToast, duration: TimeInterval = 3.0, completion: XZToast.Completion? = nil) {
        guard let view = self.view else { return XZToastDidComplete(completion, false) }
        
        var toastView : XZToastView! = self.toastView
        if toastView == nil {
            toastView = XZToastView.init()
            toastView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
            toastView.alpha = 0
            view.addSubview(toastView)
            self.toastView = toastView
        } else {
            toastView.identifier += 1
            XZToastDidComplete(toastView.completion, false)
            view.bringSubviewToFront(toastView)
        }
        toastView.toast = toast
        toastView.completion = completion
        
        let identifier = toastView.identifier
        let bounds = view.bounds.inset(by: view.safeAreaInsets)
        
        toastView.sizeToFit()
        toastView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        toastView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            toastView.alpha = 1.0
        }
        
        switch (toast) {
        case .message:
            // 延时自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(duration) * 1000)) { [weak self, toastView] in
                guard let toastView = toastView else { return }
                guard let responder = self else { return }
                guard toastView.identifier == identifier else {
                    return
                }
                responder.toastView = nil
                
                UIView.animate(withDuration: 0.3) {
                    toastView.alpha = 0
                } completion: { finished in
                    XZToastDidComplete(toastView.completion, finished)
                    toastView.removeFromSuperview()
                }
            }
        case .loading:
            // 不需要隐藏
            break
        }
    }
    
    public override func hideToast(_ completion: XZToast.Completion? = nil) {
        guard let toastView = self.toastView else { return XZToastDidComplete(completion, false) }
        toastView.identifier += 1
        self.toastView = nil
        
        UIView.animate(withDuration: 0.3) {
            toastView.alpha = 0
        } completion: { finished in
            XZToastDidComplete(toastView.completion, true)
            XZToastDidComplete(completion, finished)
            toastView.removeFromSuperview()
        }
    }
    
}

extension UIView {
    
    public override func showToast(_ toast: XZToast, duration: TimeInterval = 3.0, completion: XZToast.Completion? = nil) {
        self.next?.showToast(toast, duration: duration, completion: completion)
    }
    
    public override func hideToast(_ completion: XZToast.Completion? = nil) {
        self.next?.hideToast(completion)
    }
    
}

extension UIWindow {
      
    public override func showToast(_ toast: XZToast, duration: TimeInterval = 3.0, completion: XZToast.Completion? = nil) {
        self.rootViewController?.showToast(toast, duration: duration, completion: completion)
    }
    
    public override func hideToast(_ completion: XZToast.Completion? = nil) {
        self.rootViewController?.hideToast(completion)
    }
    
}

fileprivate class XZToastView : UIView {
    
    var completion: XZToast.Completion?
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
                        let indicator = UIActivityIndicatorView.init(style: .medium)
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
        textLabel.font = UIFont.systemFont(ofSize: 15.0)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.8
        textLabel.textAlignment = .center
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
                    addSubview(indicator)
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
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
            return CGSize(width: max(min(maxWidth, textSize.width), 50.0) + 30.0, height: 10.0 + 50.0 + 10.0 + textSize.height + 10.0)
        }
    }
    
}


extension XZToast: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self = .message(value)
    }
}

@objc(XZToastType) public enum __XZOBJCToastType: Int {
    case message
    case loading
}

/// 支持 ObjC 类型的定义。理论上用内嵌类型最好，但是内嵌类型无法导出到 -Swift.h 头文件中。
@objc(XZToast) public class __XZOBJCToast: NSObject {
    @objc public var type: __XZOBJCToastType
    @objc public var text: String
    @objc public init(type: __XZOBJCToastType, text: String) {
        self.type = type
        self.text = text
        super.init()
    }
}

extension XZToast: ReferenceConvertible {
    
    public func _bridgeToObjectiveC() -> __XZOBJCToast {
        switch self {
        case let .message(text):
            return __XZOBJCToast.init(type: .message, text: text)
        case let .loading(text):
            return __XZOBJCToast.init(type: .loading, text: text)
        }
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __XZOBJCToast, result: inout XZToast?) {
        switch source.type {
        case .message:
            result = .loading(source.text)
        case .loading:
            fallthrough
        default:
            result = .message(source.text)
        }
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __XZOBJCToast, result: inout XZToast?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __XZOBJCToast?) -> XZToast {
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
    
    public typealias _ObjectiveCType = __XZOBJCToast
    
}

