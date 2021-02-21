//
//  XZImageLine+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageLine.h>
#import <XZKit/XZImageLineDash+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageLine ()

@property (nonatomic, strong, readonly) XZImageLineDash *dashIfLoaded;

@end

NS_ASSUME_NONNULL_END
