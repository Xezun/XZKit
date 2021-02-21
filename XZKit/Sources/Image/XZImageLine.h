//
//  XZImageLine.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZImageLineDash.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(XZImage.Line)
@interface XZImageLine : NSObject

/// 线条颜色
@property (nonatomic, strong, nullable) UIColor *color;
/// 线条粗细
@property (nonatomic) CGFloat width;
/// 虚线。
@property (nonatomic, strong, readonly) XZImageLineDash *dash;
- (void)dashDidLoad;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithLine:(nullable XZImageLine *)line NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
