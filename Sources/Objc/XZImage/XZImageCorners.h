//
//  XZImageCorners.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZImageCorner.h>
#else
#import "XZImageCorner.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZImageCorner;

/// 集合，包含了四个描述矩形角的对象。
NS_SWIFT_NAME(XZImage.Corners)
@interface XZImageCorners : XZImageCorner

@property (nonatomic, strong, readonly) XZImageCorner *topLeft;
@property (nonatomic, strong, readonly) XZImageCorner *bottomLeft;
@property (nonatomic, strong, readonly) XZImageCorner *bottomRight;
@property (nonatomic, strong, readonly) XZImageCorner *topRight;

@end

NS_ASSUME_NONNULL_END
