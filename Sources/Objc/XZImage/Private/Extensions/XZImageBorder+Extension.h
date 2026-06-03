//
//  XZImageBorder+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/18.
//

#import "XZImageBorder.h"
#import "XZImageLine+Extension.h"
#import "XZImageArrow+Extension.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZImageBorder ()

- (instancetype)initWithImageBorders:(nullable XZImageBorders *)imageBorders;

@property (nonatomic, strong, readonly, nullable) XZImageArrow *arrowIfLoaded;

@end

NS_ASSUME_NONNULL_END
