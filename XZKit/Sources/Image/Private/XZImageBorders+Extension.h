//
//  XZImageBorders+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageBorders.h>
#import <XZKit/XZImageLineDash+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageBorders () <XZImageLineDashDelegate>

@property (nonatomic, strong, readonly, nullable) XZImageBorder *topIfLoaded;
@property (nonatomic, strong, readonly, nullable) XZImageBorder *leftIfLoaded;
@property (nonatomic, strong, readonly, nullable) XZImageBorder *bottomIfLoaded;
@property (nonatomic, strong, readonly, nullable) XZImageBorder *rightIfLoaded;

@end

NS_ASSUME_NONNULL_END
