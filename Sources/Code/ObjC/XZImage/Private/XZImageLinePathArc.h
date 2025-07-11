//
//  XZImageLinePathArc.h
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZImageLinePath.h>
#else
#import "XZImageLinePath.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZImageLinePathArc : NSObject <XZImagePathItem>
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@end

NS_ASSUME_NONNULL_END
