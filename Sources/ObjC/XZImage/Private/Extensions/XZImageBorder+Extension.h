//
//  XZImageBorder+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/18.
//

#if __has_include("XZKit.h")
#import "XZImageBorder.h"
#import "XZImageLine+Extension.h"
#import "XZImageArrow+Extension.h"
#else
#import <XZKit/XZImageBorder.h>
#import <XZKit/XZImageLine+Extension.h>
#import <XZKit/XZImageArrow+Extension.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZImageBorder ()

- (instancetype)initWithImageBorders:(nullable XZImageBorders *)imageBorders;

@property (nonatomic, strong, readonly, nullable) XZImageArrow *arrowIfLoaded;

@end

NS_ASSUME_NONNULL_END
