//
//  XZImageBorder.h
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import <XZKit/XZImageLine.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(XZImageBorder.Arrow)
@interface XZImageBorderArrow : NSObject  {
    @protected
    CGFloat _lineOffset;
    CGPoint _vectorOffsets[3];
}

/// 底边中点，距离其所在边的中点的距离
@property (nonatomic) CGFloat anchor;
/// 顶点，距离其所在边的中点的距离
@property (nonatomic) CGFloat vector;
/// 底宽
@property (nonatomic) CGFloat width;
/// 高
@property (nonatomic) CGFloat height;

@end

NS_SWIFT_NAME(XZImage.Border)
@interface XZImageBorder : XZImageLine {
    @protected
    XZImageBorderArrow *_arrow;
}

/// 箭头
@property (nonatomic, strong, readonly) XZImageBorderArrow *arrow;

@end

NS_ASSUME_NONNULL_END
