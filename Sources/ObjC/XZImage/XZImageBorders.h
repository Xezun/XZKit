//
//  XZImageBorders.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageBorder.h"

NS_ASSUME_NONNULL_BEGIN

@class XZImageBorder;

/// 集合，包含了描述矩形四个边的对象。
NS_SWIFT_NAME(XZImage.Borders)
@interface XZImageBorders : XZImageBorder

@property (nonatomic, strong, readonly) XZImageBorder *top;
@property (nonatomic, strong, readonly) XZImageBorder *left;
@property (nonatomic, strong, readonly) XZImageBorder *bottom;
@property (nonatomic, strong, readonly) XZImageBorder *right;

@end

NS_ASSUME_NONNULL_END
