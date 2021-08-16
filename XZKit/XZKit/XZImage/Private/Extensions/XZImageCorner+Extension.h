//
//  XZImageCorner+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageCorner.h>
#import <XZKit/XZImageLine+Extension.h>
#import <XZKit/XZImageCorners+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageCorner ()

- (instancetype)initWithImageCorners:(nullable XZImageCorners *)imageCorners;

- (BOOL)setRadiusSilently:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
