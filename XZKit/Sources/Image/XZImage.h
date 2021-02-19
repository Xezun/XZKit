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

@protocol XZImagePath;

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

/// 根据当前当前设置信息，输出图片的大小。
/// @note 除非属性 size 的大小不够显示，否则此属性与 size 的值相同。
@property (nonatomic) CGSize preferredSize;

/// 返回整个边框的路径。
/// @note 仅包含 XZImage 当前所描述外形，没有粗细、颜色信息。
@property (nonatomic, readonly) UIBezierPath *path;

/// 绘制 XZImage 所有边、圆角、箭头的路径。
@property (nonatomic, readonly) NSArray<id<XZImagePath>> *imagePaths;

@end


/// 用于直接绘制 XZImage 边、圆角、箭头的路径。
@protocol XZImagePath <NSObject>
/// 执行绘制。
/// @note 此方法会设置画笔 context 的样式。
- (void)drawInContext:(CGContextRef)context;
/// 路径。
@property (nonatomic, readonly) UIBezierPath *path;
/// 当前路径所绘制的边或圆角。
/// @note 使用 `-drawInContext:` 方法不需要额外设置边的粗细颜色。
@property (nonatomic, readonly) XZImageLine *line;
@end

NS_ASSUME_NONNULL_END
