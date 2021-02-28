//
//  XZImageBorders+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageBorders.h>
#import <XZKit/XZImageBorder+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageBorders ()

@property (nonatomic, strong, readonly, nullable) XZImageBorder *topIfLoaded;
@property (nonatomic, strong, readonly, nullable) XZImageBorder *leftIfLoaded;
@property (nonatomic, strong, readonly, nullable) XZImageBorder *bottomIfLoaded;
@property (nonatomic, strong, readonly, nullable) XZImageBorder *rightIfLoaded;

- (instancetype)initWithImageBorders:(nullable XZImageBorders *)imageBorders NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
