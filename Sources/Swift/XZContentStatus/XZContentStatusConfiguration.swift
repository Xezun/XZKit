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
    @MainActor open class Configuration: Copyable {
        
        /// 呈现当前状态配置的状态视图。
        public let view: UIView?
        
        /// 配置。
        /// - Parameter view: 自定义视图
        public init(view: UIView?) {
            self.view = view
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
        
        internal func setText(for rawValue: String) {
            switch rawValue {
            case "empty":
                self.text = "页面是空的"
            case "error":
                self.text = "服务器繁忙"
            case "loading":
                self.text = "页面加载中"
            case "unreachable":
                self.text = "网络不给力"
            case "unavailable":
                self.text = "服务不可用"
            default:
                break
            }
        }
        
        internal func setImage(for rawValue: String) {
            let color  = UIColor.systemGray
            let size   = CGFloat(60.0)
            let weight = UIImage.SymbolWeight.light
            let scale  = UIImage.SymbolScale.medium
            
            switch rawValue {
            case "empty":
                if #available(iOS 15, *) {
                    self.image = UIImage(systemName: "rectangle.on.rectangle.slash.circle", color: color, pointSize: size, weight: weight, scale: scale)
                } else if #available(iOS 14, *) {
                    self.image = UIImage(systemName: "tray.circle", color: color, pointSize: size, weight: weight, scale: scale)
                } else {
                    self.image = UIImage(systemName: "magnifyingglass.circle", color: color, pointSize: size, weight: weight, scale: scale)
                }
            case "error":
                self.image = UIImage(systemName: "exclamationmark.circle", color: color, pointSize: size, weight: weight, scale: scale)
            case "loading":
                if #available(iOS 18, *) {
                    self.image = UIImage(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle", color: color, pointSize: size, weight: weight, scale: scale)
                } else if #available(iOS 14, *) {
                    self.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle", color: color, pointSize: size, weight: weight, scale: scale)
                } else {
                    self.image = UIImage(systemName: "arrow.2.circlepath.circle", color: color, pointSize: size, weight: weight, scale: scale)
                }
                if #available(iOS 18.0, *) {
                    self.setSymbolEffect(.rotate, options: .repeat(.continuous))
                }
            case "unreachable":
                if #available(iOS 17, *) {
                    self.image = UIImage(systemName: "wifi.exclamationmark.circle", color: color, pointSize: size, weight: weight, scale: scale)
                } else if #available(iOS 15, *) {
                    self.image = UIImage(systemName: "wifi.circle", color: color, pointSize: size, weight: weight, scale: scale)
                } else {
                    self.image = UIImage(systemName: "wifi.slash", color: color, pointSize: size, weight: weight, scale: scale)
                }
            case "unavailable":
                self.image = UIImage(systemName: "xmark.circle", color: color, pointSize: size, weight: weight, scale: scale)
            default:
                break
            }
        }
        
    }
}
