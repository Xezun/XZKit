//
//  XZImageCorners+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageCorners.h>
#import <XZKit/XZImageLineDash+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageCorners () <XZImageLineDashDelegate>

@property (nonatomic, strong, readonly) XZImageCorner *topLeftIfLoaded;
@property (nonatomic, strong, readonly) XZImageCorner *bottomLeftIfLoaded;
@property (nonatomic, strong, readonly) XZImageCorner *bottomRightIfLoaded;
@property (nonatomic, strong, readonly) XZImageCorner *topRightIfLoaded;

@end

NS_ASSUME_NONNULL_END
