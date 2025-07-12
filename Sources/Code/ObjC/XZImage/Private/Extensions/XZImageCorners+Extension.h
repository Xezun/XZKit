//
//  XZImageCorners+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import "XZImageCorners.h"
#import "XZImageCorner+Extension.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZImageCorners ()

@property (nonatomic, strong, readonly) XZImageCorner *topLeftIfLoaded;
@property (nonatomic, strong, readonly) XZImageCorner *bottomLeftIfLoaded;
@property (nonatomic, strong, readonly) XZImageCorner *bottomRightIfLoaded;
@property (nonatomic, strong, readonly) XZImageCorner *topRightIfLoaded;

- (instancetype)initWithImageCorners:(nullable XZImageCorners *)imageCorners NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
