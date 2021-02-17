//
//  XZImageCorners.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import <XZKit/XZImageCorner.h>

NS_ASSUME_NONNULL_BEGIN

@class XZImageCorner;

NS_SWIFT_NAME(XZImage.Corners)
@interface XZImageCorners : XZImageCorner

@property (nonatomic, strong, readonly) XZImageCorner *topLeft;
@property (nonatomic, strong, readonly) XZImageCorner *bottomLeft;
@property (nonatomic, strong, readonly) XZImageCorner *bottomRight;
@property (nonatomic, strong, readonly) XZImageCorner *topRight;

@end

NS_ASSUME_NONNULL_END
