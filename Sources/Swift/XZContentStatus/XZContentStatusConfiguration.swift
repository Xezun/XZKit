//
//  XZContentStatusConfiguration.swift
//  XZKit
//
//  Created by Xezun on 2026/6/10.
//

import UIKit

extension XZContentStatus {
    
    /// 配置状态视图的外观属性的对象。
    ///
    /// 修改外观属性不会对显示中的的视图生效。
    @MainActor open class Configuration {
        
        /// 呈现当前状态配置的状态视图。
        public let view: UIView?
        
        /// 配置。
        /// - Parameter view: 自定义视图
        public init(view: UIView?) {
            self.view = view
        }
        
        private init(text: String?, image: UIImage?, animated: Bool = false) {
            self.view  = nil
            self.text  = text
            self.image = image
            
            guard animated else {
                return
            }
            
            if #available(iOS 18.0, *) {
                self.setSymbolEffect(.rotate, options: .repeat(.continuous))
            }
        }
        
        /// 背景色
        public var backgroundColor: UIColor = XZContentStatus.backgroundColor
        
        /// 状态文案。
        public var text: String?
        
        /// 状态图片。
        public var image: UIImage?
        
        /// 是否可点击。
        public var isInteractive = true
        
        /// 状态文案文本颜色。
        public var textColor: UIColor = XZContentStatus.textColor
        
        /// 状态文案字体。
        public var font: UIFont = XZContentStatus.font
        
        // 不能给属性添加 @available 修饰，所以
        // 无法将 some DiscreteSymbolEffect & IndefiniteSymbolEffect & SymbolEffect 作为属性。
        internal var addSymbolEffect: ((_ imageView: UIImageView) -> Void)?
        
        /// 使用 Symbol Image 时，可通过此方法，添加动效。
        /// - Parameters:
        ///   - effect: 动效
        ///   - options: 动效可选项
        @available(iOS 17.0, *)
        public func setSymbolEffect(_ effect: (some DiscreteSymbolEffect & IndefiniteSymbolEffect & SymbolEffect), options: SymbolEffectOptions = .default) {
            self.addSymbolEffect = { imageView in
                imageView.addSymbolEffect(effect, options: options, animated: false)
            }
        }
        
        /// 移除已设置的动效。
        /// 在 ``setSymbolEffect(_:options:)`` 方法中，使用 Optional 参数，会造成无法使用点语法，所以用一个独立的方法来清除设置。
        public func removeSymbolEffect() {
            addSymbolEffect = nil
        }
        
        public convenience init(status rawValue: String, text: String?, image: UIImage?, isInteractive: Bool) {
            switch rawValue {
            case "empty":
                self.init(.empty, text: text, image: image, isInteractive: isInteractive)
            case "error":
                self.init(.error, text: text, image: image, isInteractive: isInteractive)
            case "loading":
                self.init(.loading, text: text, image: image, isInteractive: isInteractive)
            case "unreachable":
                self.init(.unreachable, text: text, image: image, isInteractive: isInteractive)
            case "unavailable":
                self.init(.unavailable, text: text, image: image, isInteractive: isInteractive)
            default:
                self.init(text: text, image: image, animated: false)
            }
        }
        
        public convenience init(_ configuration: Configuration, text: String?, image: UIImage?, isInteractive: Bool) {
            if let view = configuration.view {
                self.init(view: view)
            } else {
                self.init(view: nil)
                self.text            = text
                self.image           = image
                self.isInteractive   = isInteractive
                self.textColor       = configuration.textColor
                self.font            = configuration.font
                self.addSymbolEffect = configuration.addSymbolEffect
            }
        }
        
        public convenience init(_ configuration: Configuration, text: String?, image: UIImage?) {
            if let view = configuration.view {
                self.init(view: view)
            } else {
                self.init(view: nil)
                self.text            = text
                self.image           = image
                self.isInteractive   = configuration.isInteractive
                self.textColor       = configuration.textColor
                self.font            = configuration.font
                self.addSymbolEffect = configuration.addSymbolEffect
            }
        }
        
        public convenience init(_ configuration: Configuration, text: String?, isInteractive: Bool) {
            if let view = configuration.view {
                self.init(view: view)
            } else {
                self.init(view: nil)
                self.text            = text
                self.image           = configuration.image
                self.isInteractive   = isInteractive
                self.textColor       = configuration.textColor
                self.font            = configuration.font
                self.addSymbolEffect = configuration.addSymbolEffect
            }
        }
        
        public convenience init(_ configuration: Configuration, text: String?) {
            if let view = configuration.view {
                self.init(view: view)
            } else {
                self.init(view: nil)
                self.text            = text
                self.image           = configuration.image
                self.isInteractive   = configuration.isInteractive
                self.textColor       = configuration.textColor
                self.font            = configuration.font
                self.addSymbolEffect = configuration.addSymbolEffect
            }
        }
        
        public convenience init(_ configuration: Configuration, image: UIImage?, isInteractive: Bool) {
            if let view = configuration.view {
                self.init(view: view)
            } else {
                self.init(view: nil)
                self.text            = configuration.text
                self.image           = image
                self.isInteractive   = isInteractive
                self.textColor       = configuration.textColor
                self.font            = configuration.font
                self.addSymbolEffect = configuration.addSymbolEffect
            }
        }
        
        public convenience init(_ configuration: Configuration, image: UIImage?) {
            if let view = configuration.view {
                self.init(view: view)
            } else {
                self.init(view: nil)
                self.text            = configuration.text
                self.image           = image
                self.isInteractive   = configuration.isInteractive
                self.textColor       = configuration.textColor
                self.font            = configuration.font
                self.addSymbolEffect = configuration.addSymbolEffect
            }
        }
        
        public convenience init(_ configuration: Configuration, isInteractive: Bool) {
            if let view = configuration.view {
                self.init(view: view)
            } else {
                self.init(view: nil)
                self.text            = configuration.text
                self.image           = configuration.image
                self.isInteractive   = isInteractive
                self.textColor       = configuration.textColor
                self.font            = configuration.font
                self.addSymbolEffect = configuration.addSymbolEffect
            }
        }
        
        public convenience init(_ configuration: Configuration) {
            if let view = configuration.view {
                self.init(view: view)
            } else {
                self.init(view: nil)
                self.text            = configuration.text
                self.image           = configuration.image
                self.isInteractive   = configuration.isInteractive
                self.textColor       = configuration.textColor
                self.font            = configuration.font
                self.addSymbolEffect = configuration.addSymbolEffect
            }
        }
        
        public static let empty = Configuration.init(text: "页面是空的", image: ({ () -> UIImage? in
            if #available(iOS 18, *) {
                return UIImage(systemName: "text.page.badge.magnifyingglass", color: .systemGray, pointSize: 60.0, weight: .light, scale: .medium)
            }
            return UIImage(systemName: "rectangle.and.text.magnifyingglass", color: .systemGray, pointSize: 60.0, weight: .light, scale: .medium)
        })())
        
        public static let error = Configuration.init(text: "服务器繁忙", image: ({ () -> UIImage? in
            return UIImage(systemName: "exclamationmark.circle", color: .systemGray, pointSize: 60.0, weight: .light, scale: .medium)
        })())
        
        public static let loading = Configuration.init(text: "页面加载中", image: ({ () -> UIImage? in
            if #available(iOS 18, *) {
                return UIImage(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle", color: .systemGray, pointSize: 60.0, weight: .light, scale: .medium)
            }
            return UIImage(systemName: "arrow.triangle.2.circlepath.circle", color: .systemGray, pointSize: 60.0, weight: .light, scale: .medium)
        })(), animated: true)
        
        public static let unreachable = Configuration.init(text: "网络不给力", image: ({ () -> UIImage? in
            if #available(iOS 17, *) {
                return UIImage(systemName: "wifi.exclamationmark.circle", color: .systemGray, pointSize: 60.0, weight: .light, scale: .medium)
            }
            return UIImage(systemName: "wifi.circle", color: .systemGray, pointSize: 60.0, weight: .light, scale: .medium)
        })())
        
        public static let unavailable = Configuration.init(text: "服务不可用", image: ({ () -> UIImage? in
            return UIImage(systemName: "xmark.circle", color: .systemGray, pointSize: 60.0, weight: .light, scale: .medium)
        })())
        
    }
}
