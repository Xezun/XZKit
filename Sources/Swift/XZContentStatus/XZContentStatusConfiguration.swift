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
        
        public init(view: UIView?) {
            self.view = view
        }
        
        public init(text: String?, image: UIImage?) {
            self.view  = nil
            self.text  = text
            self.image = image
        }
        
        public convenience init(for contentStatus: String) {
            switch contentStatus {
            case "empty":
                self.init(.empty)
            case "error":
                self.init(.error)
            case "loading":
                self.init(.loading)
            case "unreachable":
                self.init(.unreachable)
            case "unavailable":
                self.init(.unavailable)
            default:
                self.init(view: nil)
            }
        }
        
        public convenience init(_ configuration: Configuration) {
            self.init(view: configuration.view)
            self.text            = configuration.text
            self.image           = configuration.image
            self.isInteractive   = configuration.isInteractive
            self.textColor       = configuration.textColor
            self.font            = configuration.font
            self.addSymbolEffect = configuration.addSymbolEffect
        }
        
        private static func symbol(_ name: String) -> UIImage? {
            return UIImage(systemName: name, color: XZContentStatus.tintColor, pointSize: 60.0, weight: .light, scale: .medium)
        }
        
        public static let empty = ({ () -> XZContentStatus.Configuration in
            let configuration = XZContentStatus.Configuration.init(view: nil)
            configuration.text = "页面是空的"
            if #available(iOS 18, *) {
                configuration.image = XZContentStatus.Configuration.symbol("text.page.badge.magnifyingglass")
            } else {
                configuration.image = XZContentStatus.Configuration.symbol("rectangle.and.text.magnifyingglass")
            }
            return configuration
        })()
        
        public static let error = ({ () -> XZContentStatus.Configuration in
            let configuration = XZContentStatus.Configuration.init(view: nil)
            configuration.text  = "服务器繁忙"
            configuration.image = XZContentStatus.Configuration.symbol("exclamationmark.circle")
            return configuration
        })()
        
        public static let loading = ({ () -> XZContentStatus.Configuration in
            let configuration = XZContentStatus.Configuration.init(view: nil)
            configuration.text = "页面加载中"
            if #available(iOS 18, *) {
                configuration.image = XZContentStatus.Configuration.symbol("arrow.trianglehead.2.clockwise.rotate.90.circle")
            } else {
                configuration.image = XZContentStatus.Configuration.symbol("arrow.triangle.2.circlepath.circle")
            }
            if #available(iOS 18.0, *) {
                configuration.setSymbolEffect(.rotate, options: .repeat(.continuous))
            }
            return configuration
        })()
        
        public static let unreachable = ({ () -> XZContentStatus.Configuration in
            let configuration = XZContentStatus.Configuration.init(view: nil)
            configuration.text = "网络不给力"
            if #available(iOS 17, *) {
                configuration.image = XZContentStatus.Configuration.symbol("wifi.exclamationmark.circle")
            } else {
                configuration.image = XZContentStatus.Configuration.symbol("wifi.circle")
            }
            return configuration
        })()
        
        public static let unavailable = ({ () -> XZContentStatus.Configuration in
            let configuration = XZContentStatus.Configuration.init(view: nil)
            configuration.text  = "服务不可用"
            configuration.image = XZContentStatus.Configuration.symbol("xmark.circle")
            return configuration
        })()
        
    }
}
