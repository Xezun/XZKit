//
//  XZImageLineDash.h
//  XZKit
//
//  Created by Xezun on 2021/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 虚线：实线、空白的按指定规律重复线段。
NS_SWIFT_NAME(XZImageLine.Dash)
@interface XZImageLineDash : NSObject <NSCopying>

/// 位移。绘制第一个 segments 虚线段时，从 phase 的位置开始绘制。
@property (nonatomic) CGFloat phase;
/// CGFloat 一维数组，表示虚线的间隔的线段。比如 [1, 2, 3, 4] 表示
/// 绘制“1点的实线 + 2点空白 + 3点实线 + 4点空白”，然后重复按照此绘制。
/// @note 该属性的 setter 和 getter 不是同一个类型。
@property (nonatomic, readonly, nullable) CGFloat *segments NS_RETURNS_INNER_POINTER;
/// 虚线段的个数。
@property (nonatomic, readonly) NSInteger numberOfSegments;

@property (nonatomic, readonly) BOOL isEmpty;

/// 便利构造方法。
/// @note 第一个宽度为 0 的参数表示结束。
/// @param segments 虚、实、虚...线的宽度，必须用小数形式
+ (XZImageLineDash *)lineDashWithSegments:(nullable NSArray<NSNumber *> *)segments;
+ (XZImageLineDash *)lineDashWithSegments:(const CGFloat * _Nullable)segments length:(NSInteger)length;

/// 便利构造方法。
/// @param phase 偏移
/// @param segments 虚实段长度
+ (XZImageLineDash *)lineDashWithPhase:(CGFloat)phase segments:(nullable NSArray<NSNumber *> *)segments;
+ (XZImageLineDash *)lineDashWithPhase:(CGFloat)phase segments:(const CGFloat * _Nullable)segments length:(NSInteger)length;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (BOOL)isEqualToDash:(XZImageLineDash *)dash;

/// 设置虚线段。
/// @param segments 一维 CGFloat 数组
- (void)setSegments:(NSArray<NSNumber *> * _Nullable)segments;
- (void)setSegments:(const CGFloat * _Nullable)segments length:(NSInteger)length;

/// 实线的宽度。
/// @note 仅设置此属性表示实现、空白宽度一致。
@property (nonatomic) CGFloat width;
/// 空白的宽度。
/// @note 仅设置此属性无效，可能并不会生效。
@property (nonatomic) CGFloat space;

@end

NS_ASSUME_NONNULL_END
