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
#import <XZKit/XZGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XZImageLinePath;

/// 定义了一种包含边框、圆角、箭头的图片类型。
@interface XZImage : NSObject

/// 绘制并生成 UIImage 对象。
/// @note XZImage 将持生成的图片，且在属性发生改动，或收到内存警告时，释放该图片，并在调用本属性再次生成。
@property (nonatomic, strong, readonly) UIImage *image;
/// 如果图片已绘制，则返回该图片对象。
@property (nonatomic, strong, readonly, nullable) UIImage *imageIfLoaded;

/// 图片大小。
/// @note 如果设置，属性 image 生成的大小不会超过此大小；
///       如果设置的不够大，生成的图片可能会有裁剪。
/// @note 如果不设置，XZImage 将根据背景图、圆角、箭头、边距等信息计算出最小 size 用于生成图片。
@property (nonatomic) CGSize size;
/// 背景色。
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
/// 背景图，将会绘制在背景色上。
@property (nonatomic, strong, nullable) UIImage *backgroundImage;
/// 背景图的显示方式
@property (nonatomic) UIViewContentMode contentMode;
/// 四边。
@property (nonatomic, strong, readonly) XZImageBorders *borders;
/// 四角。
@property (nonatomic, strong, readonly) XZImageCorners *corners;
/// 内边距。
@property (nonatomic) UIEdgeInsets contentInsets;

- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;

/// 如果发生内存警告，则会清理已生成的图片对象。
- (void)didReceiveMemoryWarning;

@end


@interface XZImage (XZExtendedImage)

/// 边框粗细
@property (nonatomic) CGFloat lineWidth;
/// 边框颜色
@property (nonatomic) UIColor *lineColor;
/// 虚线。
@property (nonatomic, strong, readonly) XZImageLineDash *lineDash;
@property (nonatomic, strong, readonly, nullable) XZImageLineDash *lineDashIfLoaded;
/// 圆角大小
@property (nonatomic) CGFloat cornerRadius;

/// 根据当前当前设置信息，输出图片的大小。
/// @note 除非属性 size 的大小不够显示，否则此属性与 size 的值相同。
@property (nonatomic, readonly) CGSize preferredSize;

/// 返回整个边框的路径。
/// @note 仅包含 XZImage 当前所描述外形，没有粗细、颜色信息。
@property (nonatomic, copy, readonly) UIBezierPath *path;

/// 绘制 XZImage 所有边、圆角、箭头的路径。
@property (nonatomic, copy, readonly) NSArray<id<XZImageLinePath>> *linePaths;

@end


/// 用于直接绘制 XZImage 边、圆角、箭头的路径。
@protocol XZImageLinePath <NSObject>
/// 执行绘制。
/// @note 此方法会设置画笔 context 的样式。
- (void)drawInContext:(CGContextRef)context;
/// 路径。
@property (nonatomic, readonly) UIBezierPath *path;
/// 当前路径所绘制的边或圆角。
/// @note 使用 `-drawInContext:` 方法不需要额外设置边的粗细颜色。
@property (nonatomic, readonly, nullable) XZImageLine *line;
@end

NS_ASSUME_NONNULL_END
