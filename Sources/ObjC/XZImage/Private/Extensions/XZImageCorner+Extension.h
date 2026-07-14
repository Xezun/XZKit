//
//  XZImageCorner+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import "XZImageCorner.h"
#import "XZImageLine+Extension.h"
#import "XZImageCorners+Extension.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZImageCorner ()

- (instancetype)initWithImageCorners:(nullable XZImageCorners *)imageCorners;

- (BOOL)setRadiusValue:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
