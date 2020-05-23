//
//  UIImageView.swift
//  XZKit
//
//  Created by Xezun on 2017/4/24.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit


extension UIImageView {
    
    /// 占位图。
    @objc(xz_placeholder)
    open var placeholder: UIImage? {
        get { return placeholderImageViewIfLoaded?.image }
        set { placeholderImageView.image = newValue      }
    }
    
    /// 高亮状态下的占位图。
    @objc(highlightedPlaceholder)
    open var xz_highlightedPlaceholder: UIImage? {
        get { return placeholderImageViewIfLoaded?.highlightedImage }
        set { placeholderImageView.highlightedImage = newValue      }
    }
    
    /// 动态占位图。
    @objc(xz_animationPlaceholder)
    open var animationPlaceholder: [UIImage]? {
        get { return placeholderImageViewIfLoaded?.animationImages }
        set { placeholderImageView.animationImages = newValue }
    }
    
    /// 高亮状态下的动态占位图。
    @objc(xz_highlightedAnimationPlaceholder)
    open var highlightedAnimationPlaceholder: [UIImage]? {
        get { return placeholderImageViewIfLoaded?.highlightedAnimationImages }
        set { placeholderImageView.highlightedAnimationImages = newValue      }
    }
    
    /// 显示占位图的视图。
    /// - Note: 占位图视图在首次加载时会同步当前 UIImageView 的 backgroundColor、contentMode、alpha、isHighlighted 的属性值。
    /// - Note: 占位图视图添加到视图上时，将自己放在当前视图子视图的底部。
    @objc(xz_placeholderImageView)
    open var placeholderImageView: UIImageView {
        if let placeholderImageView = objc_getAssociatedObject(self, &AssociationKey.placeholderImageView) as? UIImageViewPlaceholderImageView {
            return placeholderImageView;
        }
        let placeholderImageView = UIImageViewPlaceholderImageView.init(for: self)
        objc_setAssociatedObject(self, &AssociationKey.placeholderImageView, placeholderImageView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.insertSubview(placeholderImageView, at: 0);
        return placeholderImageView;
    }
    
    /// 获取已创建的占位图视图。
    @objc(xz_placeholderImageViewIfLoaded) open var placeholderImageViewIfLoaded: UIImageView? {
        return objc_getAssociatedObject(self, &AssociationKey.placeholderImageView) as? UIImageViewPlaceholderImageView
    }

    
}


private struct AssociationKey {
    static var placeholderImageView = 0
}



public class UIImageViewPlaceholderImageView: UIImageView {
    
    private static var associationKey = 0
    
    public init(for imageView: UIImageView) {
        super.init(frame: imageView.bounds);
        self.autoresizingMask  = [.flexibleWidth, .flexibleHeight];
        
        // 同步属性
        self.backgroundColor    = imageView.backgroundColor;
        self.contentMode        = imageView.contentMode;
        self.alpha              = imageView.alpha;
        self.isHighlighted      = imageView.isHighlighted;
        if self.isHighlighted {
            self.isHidden = (imageView.highlightedImage != nil || imageView.highlightedAnimationImages != nil)
        } else {
            self.isHidden = (imageView.image != nil || imageView.animationImages != nil)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // 获取旧的父视图。
        guard let superview = self.superview as? UIImageView else { return }
        // 父视图的占位图视图必须是当前视图。
        guard superview.placeholderImageViewIfLoaded == self else {
            return
        }
        // 解除与父视图的绑定关系。
        objc_setAssociatedObject(superview, &AssociationKey.placeholderImageView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        // 移除属性观察
        superview.removeObserver(self, forKeyPath: #keyPath(UIImageView.isHighlighted), context: &ObserverContext.isHighlighted);
        superview.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &ObserverContext.image);
        superview.removeObserver(self, forKeyPath: #keyPath(UIImageView.highlightedImage), context: &ObserverContext.highlightedImage)
        superview.removeObserver(self, forKeyPath: #keyPath(UIImageView.animationImages), context: &ObserverContext.animationImages);
        superview.removeObserver(self, forKeyPath: #keyPath(UIImageView.highlightedAnimationImages), context: &ObserverContext.highlightedAnimationImages);
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview();
        
        // 获取父视图
        guard let superview = self.superview as? UIImageView else { return; }
        // 父视图的占位图视图必须是当前视图。
        guard superview.placeholderImageViewIfLoaded == self else {
            return
        }
        
        // 添加属性观察
        superview.addObserver(self, forKeyPath: #keyPath(UIImageView.isHighlighted), options: .new, context: &ObserverContext.isHighlighted);
        superview.addObserver(self, forKeyPath: #keyPath(UIImageView.image), options: .new, context: &ObserverContext.image);
        superview.addObserver(self, forKeyPath: #keyPath(UIImageView.highlightedImage), options: .new, context: &ObserverContext.highlightedImage);
        superview.addObserver(self, forKeyPath: #keyPath(UIImageView.animationImages), options: .new, context: &ObserverContext.animationImages);
        superview.addObserver(self, forKeyPath: #keyPath(UIImageView.highlightedAnimationImages), options: .new, context: &ObserverContext.highlightedAnimationImages);
    }
    
    private struct ObserverContext {
        static var isHighlighted    = 1;
        static var image            = 2;
        static var highlightedImage = 3;
        static var animationImages  = 4;
        static var highlightedAnimationImages = 5;
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch context {
        case &ObserverContext.image: fallthrough
        case &ObserverContext.isHighlighted: fallthrough
        case &ObserverContext.animationImages: fallthrough
        case &ObserverContext.highlightedImage: fallthrough
        case &ObserverContext.highlightedAnimationImages:
            guard let imageView = object as? UIImageView else { return }
            guard superview === imageView else { return }
            
            let isHighlighted = imageView.isHighlighted
            
            self.isHighlighted = isHighlighted
            
            // 高亮状态，会默认显示非高亮状态下的图片，但是普通状态不会默认显示高亮状态下的图片。
            if isHighlighted {
                self.isHidden = (imageView.image != nil || self.highlightedImage != nil || imageView.animationImages != nil || imageView.highlightedAnimationImages != nil)
            } else {
                self.isHidden = (imageView.image != nil || self.animationImages != nil)
            }
            
            // 是否有必要每次都检测占位图的位置，需要验证。
            // 但是如果不处理，虽然可能导致占位图遮挡了自视图，但是方便了开发者控制占位图的位置。
            // imageView.sendSubview(toBack: self)
            
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
    }
    
}



