//
//  XZImagePathArcItem.h
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZImagePath.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImagePathArcItem : NSObject <XZImagePathItem>
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@end

NS_ASSUME_NONNULL_END
