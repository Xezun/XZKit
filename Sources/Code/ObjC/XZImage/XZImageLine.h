//
//  XZImageLine.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZImageAttribute.h>
#import <XZKit/XZImageLineDash.h>
#else
#import "XZImageAttribute.h"
#import "XZImageLineDash.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 描述了线条的特征，如颜色、粗细、虚线等。
NS_SWIFT_NAME(XZImage.Line)
@interface XZImageLine : XZImageAttribute

/// 线条颜色
@property (nonatomic, strong, nullable) UIColor *color;
/// 线条粗细，最小值 0
@property (nonatomic) CGFloat width;
/// 尖角长度限制。
/// @note 只会影响箭头，默认值 10 。
@property (nonatomic) CGFloat miterLimit;
/// 虚线。
@property (nonatomic, strong, readonly) XZImageLineDash *dash;

@end

NS_ASSUME_NONNULL_END
