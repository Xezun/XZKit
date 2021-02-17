//
//  XZImageLine.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 虚线
typedef struct XZImageLineDash {
    /// 虚线中每个线段的长度
    CGFloat width;
    /// 虚线中线段之间的间隔
    CGFloat space;
} NS_SWIFT_NAME(XZImageLine.Dash) XZImageLineDash;

FOUNDATION_STATIC_INLINE XZImageLineDash XZImageLineDashMake(CGFloat width, CGFloat space) {
    return (XZImageLineDash){width, space};
}

FOUNDATION_STATIC_INLINE BOOL XZImageLineDashEqualToLineDash(XZImageLineDash dash1, XZImageLineDash dash2) {
    return dash1.width == dash2.width && dash1.space == dash2.space;
}

NS_SWIFT_NAME(XZImage.Line)
@interface XZImageLine : NSObject

/// 线条颜色
@property (nonatomic, strong) UIColor *color;
/// 线条粗细
@property (nonatomic) CGFloat width;
/// 虚线
@property (nonatomic) XZImageLineDash dash;

@end

NS_ASSUME_NONNULL_END
