//
//  XZImage.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZImageLevels.h>
#import <XZKit/XZImageBorders.h>
#import <XZKit/XZImageBorder.h>
#import <XZKit/XZImageCorners.h>
#import <XZKit/XZImageCorner.h>
#import <XZKit/XZKit+Geometry.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImage : NSObject

/// 图片大小。
@property (nonatomic) CGSize size;
/// 背景色。
@property (nonatomic, strong) UIColor *backgroundColor;
/// 背景图
@property (nonatomic, strong) UIImage *backgroundImage;
/// 背景图的显示方式
@property (nonatomic) UIViewContentMode contentMode;
/// 四边。
@property (nonatomic, strong, readonly) XZImageBorders *borders;
/// 四角。
@property (nonatomic, strong, readonly) XZImageCorners *corners;
/// 内边距。
@property (nonatomic) UIEdgeInsets contentInsets;

/// 边框粗细
@property (nonatomic) CGFloat borderWidth;
/// 边框颜色
@property (nonatomic) UIColor *borderColor;
/// 虚线
@property (nonatomic) XZImageLineDash borderDash;
/// 圆角大小
@property (nonatomic) CGFloat cornerRadius;

- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;

/// 绘制并生成 UIImage 对象。
@property (nonatomic, readonly) UIImage *image;

@end

NS_ASSUME_NONNULL_END
