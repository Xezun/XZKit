//
//  XZImageLine.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import <XZKit/XZImageAttribute.h>
#import <XZKit/XZImageLineDash.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(XZImage.Line)
@interface XZImageLine : XZImageAttribute

/// 线条颜色
@property (nonatomic, strong, nullable) UIColor *color;
/// 线条粗细，最小值 0
@property (nonatomic) CGFloat width;
/// 虚线。
@property (nonatomic, strong, readonly) XZImageLineDash *dash;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithLine:(nullable XZImageLine *)line NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
