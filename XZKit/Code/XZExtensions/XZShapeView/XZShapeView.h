//
//  XZShapeView.h
//  XZKit
//
//  Created by Xezun on 2021/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// layer 为 CAShapeLayer 的 UIView 子类
@interface XZShapeView : UIView

@property (nonatomic, strong, readonly) CAShapeLayer *layer;

// 以下属性没有做额外处理，与访问 CAShapeLayer 对应的属性相同。

@property (nonatomic, nullable) CGPathRef path;
@property (nonatomic, nullable) CGColorRef fillColor;
@property (nonatomic, nullable) CGColorRef strokeColor;
@property (nonatomic) CGFloat lineWidth;

@end

NS_ASSUME_NONNULL_END
