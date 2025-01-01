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

@property (nonatomic, readonly) BOOL isEffective;

@property (nonatomic, strong, readonly) XZImageLineDash *dashIfLoaded;

- (BOOL)setColorValue:(UIColor *)color;
- (BOOL)setWidthValue:(CGFloat)width;
- (BOOL)setMiterLimitValue:(CGFloat)miterLimit;

- (void)updateWithLineValue:(nullable XZImageLine *)line;

@end

NS_ASSUME_NONNULL_END
