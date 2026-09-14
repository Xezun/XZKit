//
//  XZImageCorner+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#if __has_include("XZKit.h")
#import "XZImageCorner.h"
#import "XZImageLine+Extension.h"
#import "XZImageCorners+Extension.h"
#else
#import <XZKit/XZImageCorner.h>
#import <XZKit/XZImageLine+Extension.h>
#import <XZKit/XZImageCorners+Extension.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZImageCorner ()

- (instancetype)initWithImageCorners:(nullable XZImageCorners *)imageCorners;

- (BOOL)setRadiusValue:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
