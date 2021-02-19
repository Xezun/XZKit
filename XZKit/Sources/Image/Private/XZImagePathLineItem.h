//
//  XZImagePathLineItem.h
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZImagePath.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImagePathLineItem : NSObject <XZImagePathItem>
@property (nonatomic) CGPoint endPoint;
@end

NS_ASSUME_NONNULL_END
