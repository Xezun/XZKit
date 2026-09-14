//
//  XZImageBorder.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZImageLine.h>
#import <XZKit/XZImageArrow.h>
#else
#import "XZImageLine.h"
#import "XZImageArrow.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZImageBorders;

/// 一种描述矩形边的类。
NS_SWIFT_NAME(XZImage.Border)
@interface XZImageBorder : XZImageLine

/// 箭头
@property (nonatomic, strong, readonly) XZImageArrow *arrow;

@end

NS_ASSUME_NONNULL_END
