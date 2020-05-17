//
//  UIView+Bubble.swift
//  UIMenu
//
//  Created by mlibai on 2017/7/31.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

extension UIView {
    
   
}



/// BubbleView 显示一个气泡。
/// - 请使用 tintColor 来改变气泡的背景色。
public class BubbleView: UIView {
    
    /// 圆角大小，默认 8 。
    public var cornerRadius: CGFloat = 8 {
        didSet {
            setNeedsLayout();
            setNeedsDisplay();
        }
    };
    
    /// 指针高度，默认 8 。
    public var pointerHeight: CGFloat  = 8{
        didSet {
            setNeedsLayout();
            setNeedsDisplay();
        }
    };
    
    /// 指针宽度，默认 15.0 。
    public var pointerWidth: CGFloat   = 15 {
        didSet {
            setNeedsDisplay();
        }
    };
    
    /// 指针位置。
    public var pointerPosition: CGPoint = CGPoint.zero {
        didSet {
            setNeedsDisplay();
        }
    };
    
    /// 显示内容的视图。
    public let contentView: UIView = UIView();
    
    /// 初始化。
    /// - 背景色被设置为透明色，请勿更改。
    /// - tintColor 设置为暗黑色。
    ///
    /// - Parameter frame: CGRect
    override public init(frame: CGRect) {
        super.init(frame: frame)
        didInitialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialize()
    }
    
    private func didInitialize() {
        backgroundColor = UIColor.clear
        tintColor = UIColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0);
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        addSubview(contentView)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let edge = cornerRadius * 0.3 + pointerHeight;
        contentView.frame = bounds.insetBy(dx: edge, dy: edge);
    }
    
    override open func draw(_ rect: CGRect) {
        guard let tintColor = self.tintColor else { return }
        tintColor.setFill()
        
        let bounds = self.bounds;
        
        let roundedRect: CGRect = bounds.insetBy(dx: pointerHeight, dy: pointerHeight);
        let path = UIBezierPath.init(roundedRect: roundedRect, cornerRadius: cornerRadius);
        
        /// 检查并将箭头坐标转换成一个合法的坐标。
        func makeArrow(_ point: CGPoint) -> (vector1: CGPoint, vector2: CGPoint, vector3: CGPoint) {
            let half = pointerWidth * 0.5;
            let minY = pointerHeight + cornerRadius + half;
            let maxY = bounds.maxY - minY;
            if point.y <= minY {
                let v = CGPoint.init(x: min(bounds.maxX - minY, max(minY, point.x)), y: bounds.minY);
                return (v, CGPoint.init(x: v.x - half, y: v.y + pointerHeight), CGPoint.init(x: v.x + half, y: v.y + pointerHeight));
            } else if point.y >= maxY {
                let v = CGPoint.init(x: min(bounds.maxX - minY, max(minY, point.x)), y: bounds.maxY);
                return (v, CGPoint.init(x: v.x - half, y: v.y - pointerHeight), CGPoint.init(x: v.x + half, y: v.y - pointerHeight));
            } else if point.x < bounds.midX {
                let v =  CGPoint.init(x: bounds.minX, y: min(bounds.maxY - minY, max(minY, point.y)));
                return (v, CGPoint.init(x: v.x + pointerHeight, y: v.y - half), CGPoint.init(x: v.x + pointerHeight, y: v.y + half));
            } else {
                let v =  CGPoint.init(x: bounds.maxX, y: min(bounds.maxY - minY, max(minY, point.y)));
                return (v, CGPoint.init(x: v.x - pointerHeight, y: v.y - half), CGPoint.init(x: v.x - pointerHeight, y: v.y + half));
            }
        }
        
        let arrow = makeArrow(pointerPosition);
        path.move(to: arrow.vector1);
        path.addLine(to: arrow.vector2);
        path.addLine(to: arrow.vector3);
        path.close()
        path.fill()
    }
    
}


extension BubbleView {
    
    private static var _textLabel = 0
    
    var textLabel: UILabel {
        if let textLabel = objc_getAssociatedObject(self, &BubbleView._textLabel) as? UILabel {
            return textLabel
        }
        let textLabel = UILabel()
        textLabel.frame = contentView.bounds
        textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        contentView.addSubview(textLabel)
        objc_setAssociatedObject(self, &BubbleView._textLabel, textLabel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return textLabel
    }
    
    
}
