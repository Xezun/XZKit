//
//  XZImageBorderArrow.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageAttribute.h>

NS_ASSUME_NONNULL_BEGIN

@class XZImageBorder;

/// 描述了线条的箭头的特征和属性。
/// @note 箭头与边使用相同的线型，因此箭头的实际绘制效果，除以下属性外，还受线条粗细的影响。
NS_SWIFT_NAME(XZImageBorder.Arrow)
@interface XZImageBorderArrow : XZImageAttribute

/// 箭头顶点到底边的垂直距离。
@property (nonatomic) CGFloat height;
/// 箭头底边长度。
@property (nonatomic) CGFloat width;

/// 箭头顶点，距离其所在边的中点的距离。
/// @note 箭头顶点不超过其所在矩形的边，包括圆角。
@property (nonatomic) CGFloat vector;
/// 箭头底边中点，距离其所在边的中点的距离。
/// @note 箭头底边不会超出其所在矩形的边，不包括圆角。
@property (nonatomic) CGFloat anchor;

/// 箭头所属的边。
@property (nonatomic, readonly, nullable) XZImageBorder *border;

@end

NS_ASSUME_NONNULL_END
