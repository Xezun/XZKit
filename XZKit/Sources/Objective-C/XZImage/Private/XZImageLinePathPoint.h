//
//  XZImageLinePathPoint.h
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZImageLinePath.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageLinePathPoint : NSObject <XZImagePathItem>
@property (nonatomic) CGPoint endPoint;
@end

NS_ASSUME_NONNULL_END
