//
//  XZImageBorder+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/18.
//

#import <XZKit/XZImageBorder.h>
#import <XZKit/XZImageLine+Extension.h>
#import <XZKit/XZImageArrow+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageBorder ()

- (instancetype)initWithImageBorders:(nullable XZImageBorders *)imageBorders;

@property (nonatomic, strong, readonly, nullable) XZImageArrow *arrowIfLoaded;

@end

NS_ASSUME_NONNULL_END
