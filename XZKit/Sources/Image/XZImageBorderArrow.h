//
//  XZImageBorderArrow.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageAttribute.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(XZImageBorder.Arrow)
@interface XZImageBorderArrow : XZImageAttribute

/// 底边中点，距离其所在边的中点的距离。
/// @note 箭头底边不会超出其所在矩形的边，不包括圆角。
@property (nonatomic) CGFloat anchor;
/// 顶点，距离其所在边的中点的距离。
/// @note 箭头顶点不超过其所在矩形的边，包括圆角。
@property (nonatomic) CGFloat vector;
/// 底宽，至少是边粗细的二倍。
@property (nonatomic) CGFloat width;
/// 高
@property (nonatomic) CGFloat height;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithArrow:(nullable XZImageBorderArrow *)arrow NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
