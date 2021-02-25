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

- (BOOL)setColorSilently:(UIColor *)color;
- (BOOL)setWidthSilently:(CGFloat)width;

- (void)updateWithLineSilently:(nullable XZImageLine *)line;

@end

NS_ASSUME_NONNULL_END
