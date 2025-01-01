//
//  XZImageLinePath.h
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZImage.h>

NS_ASSUME_NONNULL_BEGIN

@class UIBezierPath;

@interface XZImageLinePath : NSObject <XZImageLinePath>

/// 构造
+ (instancetype)imagePathWithLine:(nullable XZImageLine *)line startPoint:(CGPoint)startPoint;
/// 起点
@property (nonatomic, readonly) CGPoint startPoint;
/// 线型
@property (nonatomic, strong, readonly, nullable) XZImageLine *line;
/// 添加一条直线
- (void)appendLineToPoint:(CGPoint)endPoint;
/// 添加一个圆角
- (void)appendArcWithCenter:(CGPoint)center radius:(CGFloat)radiusTR startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle;

@end

@protocol XZImagePathItem <NSObject>
- (void)drawInContext:(CGContextRef)context;
- (void)addToPath:(UIBezierPath *)path;
@end

NS_ASSUME_NONNULL_END
