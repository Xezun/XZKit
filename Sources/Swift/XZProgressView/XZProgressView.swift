//
//  XZProgressView.swift
//  XZKit
//
//  Created by Xezun on 2017/8/9.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit

extension XZProgressView {

    /// 进度条样式。
    /// - Note: 角度计算规则：以视图中心为坐标原点的平面直角坐标系，x 轴正向上的所有点角度为 0；绕原点逆时针方向旋转角度增加，顺时针旋转角度减小；角度以弧度计算。
    ///
    /// - line: 直线型样式的进度条，angle 为直线起始点的角度。
    /// - arc: 圆弧型样式的进度条，startAngle 为圆弧起点的角度，endAngle 为圆弧终点角度；弧度不能大于 2π 否则实际效果可能与预期的不一致。
    public enum Style: Sendable {
        
        case line(angle: CGFloat)
        
        case arc(startAngle: CGFloat, endAngle: CGFloat)
        
        /// 水平的从左到右的进度条样式。
        public static let horizontalBar         = Style.line(angle: CGFloat.pi)
        /// 水平的从右到左的进度条样式。
        public static let horizontalInvertedBar = Style.line(angle: 0)
        /// 垂直自上而下的进度条样式。
        public static let verticalBar           = Style.line(angle: CGFloat.pi * 0.5)
        /// 垂直自下而上的进度条样式。
        public static let verticalInvertedBar   = Style.line(angle: CGFloat.pi * 1.5)
        /// 顺时针圆形样式进度条，起点在顶部。
        public static let clockwiseCircle       = Style.arc(startAngle: CGFloat.pi * 0.5, endAngle: -CGFloat.pi * 1.5)
        /// 逆时针圆形样式进度条，起点在顶部。
        public static let anticlockwiseCircle   = Style.arc(startAngle: CGFloat.pi * 0.5, endAngle: CGFloat.pi * 2.5)
    }
    
}

/// XZProgressView 用于展示进度的视图。
@MainActor
open class XZProgressView: UIView {
    
    open override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    private var trackLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }
    
    private let shapeView = XZShapeView.init()
    
    private var shapeLayer: CAShapeLayer {
        return shapeView.layer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        super.tintColor = .clear
        didInitialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialize()
    }
    
    private func didInitialize() {
        shapeView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        shapeView.frame = bounds
        addSubview(shapeView);
        
        let trackLayer = self.trackLayer
        trackLayer.fillRule = .evenOdd
        trackLayer.fillColor = tintColor.cgColor
        trackLayer.strokeColor = UIColor.systemGray6.cgColor
        trackLayer.lineWidth = 2.0
        trackLayer.strokeEnd = 1.0
        trackLayer.lineCap = .round
        
        let shapeLayer = self.shapeLayer
        shapeLayer.lineCap = .round
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red: 0x0C / 255.0, green: 0x64 / 255.0, blue: 0xFF / 255.0, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // 更新路径
        updatePathIfNeeded()
    }
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        setNeedsUpdatePath()
    }
    
    /// 进度， 0 ～ 1.0 。
    open var progress: CGFloat {
        get {
            return shapeLayer.strokeEnd
        }
        set {
            setProgress(newValue, animated: false)
        }
    }
    
    /// 设置进度以及是否动画展示进度变化过程，动画为 CALayer 默认的隐式动画。
    open func setProgress(_ progress: CGFloat, animated: Bool) {
        if animated {
            shapeLayer.strokeEnd = progress
        } else {
            UIView.performWithoutAnimation {
                shapeLayer.strokeEnd = progress
            }
        }
    }
    
    /// 进度条样式，默认 .clockwiseCircle 。
    open var style: XZProgressView.Style = .clockwiseCircle {
        didSet {
            setNeedsUpdatePath()
        }
    }
    
    /// 线端样式。
    open var lineCap: CAShapeLayerLineCap {
        get {
            return shapeLayer.lineCap
        }
        set {
            trackLayer.lineCap = newValue
            shapeLayer.lineCap = newValue
            setNeedsUpdatePath()
        }
    }
    
    /// 进度条宽度。默认 2.0 Point 。
    open var trackWidth: CGFloat {
        get {
            return shapeLayer.lineWidth
        }
        set {
            trackLayer.lineWidth = newValue
            shapeLayer.lineWidth = newValue
            setNeedsUpdatePath()
        }
    }
    
    /// 进度条轨道的颜色。最小值时，进度条颜色，即进度未完成区的颜色。默认 UIColor.groupTableViewBackground 。
    open var trackColor: UIColor? {
        get {
            guard let strokeColor = trackLayer.strokeColor else {
                return nil
            }
            return UIColor.init(cgColor: strokeColor)
        }
        set {
            trackLayer.strokeColor = newValue?.cgColor
        }
    }
    
    /// 进度条指示进度的颜色。最大值时，进度条颜色，即进度已完成区的颜色。默认 0x0C64FFFF 。
    open var color: UIColor? {
        get {
            guard let strokeColor = shapeLayer.strokeColor else {
                return nil
            }
            return UIColor.init(cgColor: strokeColor)
        }
        set {
            shapeLayer.strokeColor = newValue?.cgColor
        }
    }
    
    /// 填充色。如果进度条是封闭的图形，tintColor 可以改变封闭图形内部的颜色。
    open override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set {
            super.tintColor = newValue
            trackLayer.fillColor = newValue?.cgColor
        }
    }
    
    private var needsUpdatePath = false
    
    private func setNeedsUpdatePath() {
        if needsUpdatePath {
            return
        }
        needsUpdatePath = true
        RunLoop.main.perform(inModes: [.common]) { [weak self] in
            MainActor.assumeIsolated {
                self?.updatePathIfNeeded()
            }
        }
    }
    
    private func updatePathIfNeeded() {
        guard needsUpdatePath else {
            return
        }
        needsUpdatePath = false
        let trackPath = shapeLayerPath(with: bounds)
        trackLayer.path = trackPath
        shapeLayer.path = trackPath
    }
    
    private func shapeLayerPath(with bounds: CGRect) -> CGPath? {
        let trackWidth = self.trackWidth * 0.5
        switch style {
        case .line(let angle):
            switch lineCap {
            case .round:
                return XZProgressView.linePath(with: bounds.insetBy(dx: trackWidth, dy: trackWidth), angle: angle)
            case .square:
                let d = trackWidth * (abs(sin(angle)) + abs(cos(angle)))
                return XZProgressView.linePath(with: bounds.insetBy(dx: d, dy: d), angle: angle)
            default:
                return XZProgressView.linePath(with: bounds.insetBy(dx: trackWidth * abs(sin(angle)), dy: trackWidth * abs(cos(angle))), angle: angle)
            }
        
        case .arc(let startAngle, let endAngle):
            let radius = min(bounds.width, bounds.height) * 0.5 - trackWidth
            guard radius > 0 else { return nil }
            if startAngle > endAngle {
                return UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: radius, startAngle: -startAngle, endAngle: -endAngle, clockwise: true).cgPath
            }
            return UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: radius, startAngle: -startAngle, endAngle: -endAngle, clockwise: false).cgPath
        }
    }
    
    private static func linePath(with bounds: CGRect, angle: CGFloat) -> CGPath? {
        if bounds.isNull || bounds.isEmpty || bounds.isInfinite {
            return nil
        }
        if angle < 0 {
            return linePath(with: bounds, angle: angle + CGFloat.pi * 2.0)
        } else if angle >= CGFloat.pi * 2.0 {
            return linePath(with: bounds, angle: angle - CGFloat.pi * 2.0)
        }
        
        var start = CGPoint.zero
        var end   = CGPoint.zero
        
        if abs(angle - CGFloat.pi) < 0.0001 { // 180度
            start.x = bounds.minX
            start.y = bounds.midY
            end.x = bounds.maxX
            end.y = bounds.midY
        } else if angle < 0.0001 { // 0度
            start.x = bounds.maxX
            start.y = bounds.midY
            end.x = bounds.minX
            end.y = bounds.midY
        } else if abs(angle - CGFloat.pi * 0.5) < 0.0001 { // 90度
            start.x = bounds.midX
            start.y = bounds.minY
            end.x = bounds.midX
            end.y = bounds.maxY
        } else if abs(angle - CGFloat.pi * 1.5) < 0.0001 { // 270度
            start.x = bounds.midX
            start.y = bounds.maxY
            end.x = bounds.midX
            end.y = bounds.minY
        } else {
            let h = bounds.height * 0.5;
            let w = bounds.width * 0.5;
            
            let scale = abs(tan(angle));
            var x = w
            var y = w * scale
            
            if y > h {
                x = h / scale
                y = h
            }
            
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            
            if angle < CGFloat.pi * 0.5 {
                start.x = center.x + x
                start.y = center.y - y
                end.x = center.x - x
                end.y = center.y + y
            } else if angle < CGFloat.pi {
                start.x = center.x - x
                start.y = center.y - y
                end.x = center.x + x
                end.y = center.y + y
            } else if angle < CGFloat.pi * 1.5 {
                start.x = center.x - x
                start.y = center.y + y
                end.x = center.x + x
                end.y = center.y - y
            } else {
                start.x = center.x + x
                start.y = center.y + y
                end.x = center.x - x
                end.y = center.y - y
            }
        }
        
        let linePath = UIBezierPath.init()
        linePath.move(to: start)
        linePath.addLine(to: end)
        return linePath.cgPath
    }
    
}
