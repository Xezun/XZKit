//
//  XZContentStatus.swift
//  XZKit
//
//  Created by Xezun on 2017/7/21.
//  Copyright © 2017年 Xezun Individual. All rights reserved.
//

import UIKit

extension XZContentStatus {

    /// 页面是空的。
    public static let empty       = XZContentStatus.init(rawValue: "empty", configuration: .empty)
    /// 服务器繁忙。
    public static let error       = XZContentStatus.init(rawValue: "error", configuration: .error)
    /// 页面加载中。
    public static let loading     = XZContentStatus.init(rawValue: "loading", configuration: .loading)
    /// 网络不给力。
    public static let unreachable = XZContentStatus.init(rawValue: "unreachable", configuration: .unreachable)
    /// 服务不可用。
    public static let unavailable = XZContentStatus.init(rawValue: "unavailable", configuration: .unavailable)
    
    public static func empty(text: String?, image: UIImage?) -> XZContentStatus {
        let configuration = Configuration.init(.empty)
        configuration.text  = text
        configuration.image = image
        return XZContentStatus.init(rawValue: XZContentStatus.empty.rawValue, configuration: configuration)
    }
    
    public static func empty(text: String?) -> XZContentStatus {
        let configuration = Configuration.init(.empty)
        configuration.text = text
        return XZContentStatus.init(rawValue: XZContentStatus.empty.rawValue, configuration: configuration)
    }
    
    public static func empty(text: String?, image: UIImage?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.empty)
        configuration.text  = text
        configuration.image = image
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.empty.rawValue, configuration: configuration)
    }
    
    public static func empty(text: String?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.empty)
        configuration.text  = text
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.empty.rawValue, configuration: configuration)
    }
    
    public static func error(text: String?, image: UIImage?) -> XZContentStatus {
        let configuration = Configuration.init(.error)
        configuration.text  = text
        configuration.image = image
        return XZContentStatus.init(rawValue: XZContentStatus.error.rawValue, configuration: configuration)
    }
    
    public static func error(text: String?) -> XZContentStatus {
        let configuration = Configuration.init(.error)
        configuration.text  = text
        return XZContentStatus.init(rawValue: XZContentStatus.error.rawValue, configuration: configuration)
    }
    
    public static func error(text: String?, image: UIImage?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.error)
        configuration.text  = text
        configuration.image = image
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.error.rawValue, configuration: configuration)
    }
    
    public static func error(text: String?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.error)
        configuration.text  = text
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.error.rawValue, configuration: configuration)
    }
    
    public static func loading(text: String?, image: UIImage?) -> XZContentStatus {
        let configuration = Configuration.init(.loading)
        configuration.text  = text
        configuration.image = image
        return XZContentStatus.init(rawValue: XZContentStatus.loading.rawValue, configuration: configuration)
    }
    
    public static func loading(text: String?) -> XZContentStatus {
        let configuration = Configuration.init(.loading)
        configuration.text  = text
        return XZContentStatus.init(rawValue: XZContentStatus.loading.rawValue, configuration: configuration)
    }
    
    public static func loading(text: String?, image: UIImage?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.loading)
        configuration.text  = text
        configuration.image = image
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.loading.rawValue, configuration: configuration)
    }
    
    public static func loading(text: String?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.loading)
        configuration.text  = text
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.loading.rawValue, configuration: configuration)
    }
    
    public static func unreachable(text: String?, image: UIImage?) -> XZContentStatus {
        let configuration = Configuration.init(.unreachable)
        configuration.text  = text
        configuration.image = image
        return XZContentStatus.init(rawValue: XZContentStatus.unreachable.rawValue, configuration: configuration)
    }
    
    public static func unreachable(text: String?) -> XZContentStatus {
        let configuration = Configuration.init(.unreachable)
        configuration.text  = text
        return XZContentStatus.init(rawValue: XZContentStatus.unreachable.rawValue, configuration: configuration)
    }
    
    public static func unreachable(text: String?, image: UIImage?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.unreachable)
        configuration.text  = text
        configuration.image = image
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.unreachable.rawValue, configuration: configuration)
    }
    
    public static func unreachable(text: String?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.unreachable)
        configuration.text  = text
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.unreachable.rawValue, configuration: configuration)
    }
    
    public static func unavailable(text: String?, image: UIImage?) -> XZContentStatus {
        let configuration = Configuration.init(.unavailable)
        configuration.text  = text
        configuration.image = image
        return XZContentStatus.init(rawValue: XZContentStatus.unavailable.rawValue, configuration: configuration)
    }
    
    public static func unavailable(text: String?) -> XZContentStatus {
        let configuration = Configuration.init(.unavailable)
        configuration.text  = text
        return XZContentStatus.init(rawValue: XZContentStatus.unavailable.rawValue, configuration: configuration)
    }
    
    public static func unavailable(text: String?, image: UIImage?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.unavailable)
        configuration.text  = text
        configuration.image = image
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.unavailable.rawValue, configuration: configuration)
    }
    
    public static func unavailable(text: String?, isInteractive: Bool) -> XZContentStatus {
        let configuration = Configuration.init(.unavailable)
        configuration.text  = text
        configuration.isInteractive = isInteractive
        return XZContentStatus.init(rawValue: XZContentStatus.unavailable.rawValue, configuration: configuration)
    }
    
    public static func view(_ contentStatus: XZContentStatus, view: UIView) -> XZContentStatus {
        let configuration = XZContentStatus.Configuration.init(view: view)
        return XZContentStatus(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
    public static func view(_ contentStatus: XZContentStatus, view: UIView, isInteractive: Bool) -> XZContentStatus {
        let configuration = XZContentStatus.Configuration.init(view: view)
        configuration.isInteractive = isInteractive
        return XZContentStatus(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
}

/// 描述页面（视图或视图控制器）内容的状态的文本类型结构体。
/// 
/// - 判断内容状态是否相同唯一依据为 rawValue 属性。
/// - 一般情况下，页面状态属于一次性视图，所以仅支持配置全局样式。
@MainActor public struct XZContentStatus: @MainActor RawRepresentable, Equatable {
    
    public typealias RawValue = String
    
    /// 标识内容状态的值，判断状态是否相同的标识。
    public let rawValue: String
    
    /// 是否支持点击事件。
    public var isInteractive: Bool {
        return configuration.isInteractive
    }
    
    /// 当前配置的状态文案。可能并非当前显示的文案。
    public var text: String? {
        return configuration.text
    }
    
    /// 当前配置的状态图片。可能并非当前显示的图片。
    public var image: UIImage? {
        return configuration.image
    }
    
    /// 状态样式的配置。
    public let configuration: XZContentStatus.Configuration
    
    /// 创建内容状态值。
    public init(rawValue: String, configuration: XZContentStatus.Configuration) {
        self.rawValue = rawValue
        self.configuration = configuration
    }
    
    /// 创建自定义视图的内容状态值。
    /// - Parameters:
    ///   - rawValue: 状态值
    ///   - view: 自定义视图
    public init(rawValue: String, view: UIView) {
        self.rawValue = rawValue
        self.configuration = .init(view: view)
    }
    
    /// 创建内容状态值。
    public init(rawValue: String) {
        let configuration = XZContentStatus.Configuration.init(for: rawValue)
        self.init(rawValue: rawValue, configuration: configuration)
    }
    
    /// 创建内容状态值。
    public init(rawValue: String, isInteractive: Bool) {
        let configuration = XZContentStatus.Configuration.init(for: rawValue)
        configuration.isInteractive = isInteractive
        self.init(rawValue: rawValue, configuration: configuration)
    }
    
    /// 创建内容状态值。
    public init(rawValue: String, text: String?) {
        let configuration = XZContentStatus.Configuration.init(for: rawValue)
        configuration.text = text
        self.init(rawValue: rawValue, configuration: configuration)
    }
    
    /// 创建内容状态值。
    public init(rawValue: String, text: String?, isInteractive: Bool) {
        let configuration = XZContentStatus.Configuration.init(for: rawValue)
        configuration.text = text
        configuration.isInteractive = isInteractive
        self.init(rawValue: rawValue, configuration: configuration)
    }
    
    /// 创建内容状态值。
    public init(rawValue: String, image: UIImage?) {
        let configuration = XZContentStatus.Configuration.init(for: rawValue)
        configuration.image = image
        self.init(rawValue: rawValue, configuration: configuration)
    }
    
    /// 创建内容状态值。
    public init(rawValue: String, image: UIImage?, isInteractive: Bool) {
        let configuration = XZContentStatus.Configuration.init(for: rawValue)
        configuration.image = image
        configuration.isInteractive = isInteractive
        self.init(rawValue: rawValue, configuration: configuration)
    }
    
    /// 创建内容状态值。
    public init(rawValue: String, text: String?, image: UIImage?) {
        let configuration = XZContentStatus.Configuration.init(for: rawValue)
        configuration.text  = text
        configuration.image = image
        self.init(rawValue: rawValue, configuration: configuration)
    }
    
    /// 创建内容状态值。
    public init(rawValue: String, text: String?, image: UIImage?, isInteractive: Bool) {
        let configuration = XZContentStatus.Configuration.init(for: rawValue)
        configuration.text  = text
        configuration.image = image
        configuration.isInteractive = isInteractive
        self.init(rawValue: rawValue, configuration: configuration)
    }
    
    /// 复制内容状态值。
    public init(_ contentStatus: XZContentStatus, isInteractive: Bool = true) {
        let configuration = Configuration.init(contentStatus.configuration)
        configuration.isInteractive = isInteractive
        self.init(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
    /// 复制内容状态值。
    public init(_ contentStatus: XZContentStatus, text: String?) {
        let configuration = Configuration.init(contentStatus.configuration)
        configuration.text = text
        self.init(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
    /// 复制内容状态值。
    public init(_ contentStatus: XZContentStatus, text: String?, isInteractive: Bool) {
        let configuration = Configuration.init(contentStatus.configuration)
        configuration.text = text
        configuration.isInteractive = isInteractive
        self.init(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
    /// 复制已有状态值。
    public init(_ contentStatus: XZContentStatus, text: String?, image: UIImage?) {
        let configuration = Configuration.init(contentStatus.configuration)
        configuration.text = text
        configuration.image = image
        self.init(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
    /// 复制内容状态值。
    public init(_ contentStatus: XZContentStatus, text: String?, image: UIImage?, isInteractive: Bool) {
        let configuration = Configuration.init(contentStatus.configuration)
        configuration.text = text
        configuration.image = image
        configuration.isInteractive = isInteractive
        self.init(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
    /// 复制内容状态值。
    public init(_ contentStatus: XZContentStatus, image: UIImage?) {
        let configuration = Configuration.init(contentStatus.configuration)
        configuration.image = image
        self.init(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
    /// 复制内容状态值。
    public init(_ contentStatus: XZContentStatus, image: UIImage?, isInteractive: Bool) {
        let configuration = Configuration.init(contentStatus.configuration)
        configuration.image = image
        configuration.isInteractive = isInteractive
        self.init(rawValue: contentStatus.rawValue, configuration: configuration)
    }
    
}

extension XZContentStatus {
    
    /// 默认状态视图。
    public static var viewClass: any XZContentStatusView.Type = XZContentStatus.RepresentationView.self
    /// 背景色
    public static var backgroundColor: UIColor = .systemGray6
    /// 状态文案文本颜色。
    public static var textColor: UIColor = .systemGray
    /// 状态文案字体。
    public static var font: UIFont       = .systemFont(ofSize: UIFont.labelFontSize, weight: .regular)
    /// 图片渲染色。
    public static var tintColor: UIColor = .systemGray
    
}


extension XZContentStatus: @MainActor ReferenceConvertible, @MainActor CustomStringConvertible {
    
    public typealias ReferenceType = __XZContentStatus
    
    public typealias _ObjectiveCType = __XZContentStatus
    
    public func _bridgeToObjectiveC() -> __XZContentStatus {
        return __XZContentStatus.init(rawValue: rawValue, configuration: configuration)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __XZContentStatus, result: inout XZContentStatus?) {
        if let configuration = source.configuration as? Configuration {
            result = XZContentStatus(rawValue: source.rawValue, configuration: configuration)
        } else {
            result = XZContentStatus.init(rawValue: source.rawValue)
        }
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __XZContentStatus, result: inout XZContentStatus?) -> Bool {
        guard source.rawValue.count > 0 else {
            return false
        }
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __XZContentStatus?) -> XZContentStatus {
        guard let source = source, source.rawValue.count > 0 else {
            return .error
        }
        if let configuration = source.configuration as? Configuration {
            return XZContentStatus(rawValue: source.rawValue, configuration: configuration)
        }
        return XZContentStatus.init(rawValue: source.rawValue)
    }
    
    public var debugDescription: String {
        return description
    }
    
    public var description: String {
        return rawValue
    }
    
}
