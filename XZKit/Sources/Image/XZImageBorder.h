//
//  XZImageBorder.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import <XZKit/XZImageLine.h>
#import <XZKit/XZImageBorderArrow.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(XZImage.Border)
@interface XZImageBorder : XZImageLine

/// 箭头
@property (nonatomic, strong, readonly) XZImageBorderArrow *arrow;

- (instancetype)initWithLine:(nullable XZImageLine *)line NS_UNAVAILABLE;
- (instancetype)initWithBorder:(nullable XZImageBorder *)border NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
