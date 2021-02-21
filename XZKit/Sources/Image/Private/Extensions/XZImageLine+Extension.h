//
//  XZImageLine+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageLine.h>
#import <XZKit/XZImageAttribute+Extension.h>
#import <XZKit/XZImageLineDash+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageLine ()

@property (nonatomic, strong, readonly) XZImageLineDash *dashIfLoaded;

- (BOOL)xz_setColor:(UIColor *)color;
- (BOOL)xz_setWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
