//
//  XZImageBorderArrow.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(XZImageBorder.Arrow)
@interface XZImageBorderArrow : NSObject 

/// 底边中点，距离其所在边的中点的距离
@property (nonatomic) CGFloat anchor;
/// 顶点，距离其所在边的中点的距离
@property (nonatomic) CGFloat vector;
/// 底宽
@property (nonatomic) CGFloat width;
/// 高
@property (nonatomic) CGFloat height;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithArrow:(nullable XZImageBorderArrow *)arrow NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
