//
//  UIView+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

enum {
    /// 弹性宽高。
    UIViewAutoresizingFlexibleSize              = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight,
    /// 弹性左右边距。
    UIViewAutoresizingFlexibleHorizontalMargin  = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin,
    /// 弹性上下边距。
    UIViewAutoresizingFlexibleVerticalMargin    = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin,
    /// 弹性边距。
    UIViewAutoresizingFlexibleMargin            = UIViewAutoresizingFlexibleHorizontalMargin | UIViewAutoresizingFlexibleVerticalMargin,
    /// 弹性上左边距。
    UIViewAutoresizingFlexibleTopLeftMargin     = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin,
    /// 弹性上右边距。
    UIViewAutoresizingFlexibleTopRightMargin    = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin,
    /// 弹性下左边距。
    UIViewAutoresizingFlexibleBottomLeftMargin  = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin,
    /// 弹性下右边距。
    UIViewAutoresizingFlexibleBottomRightMargin = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin,
};

/// @define
/// 遍历视图层级的块函数。
/// @param subview 当前被遍历的视图
/// @param hierarchy 当前被遍历的视图的层级
/// @param stop 控制是否终止遍历
/// @returns 返回值“YES/NO”表示“是/否”继续遍历当前被遍历视图的子视图
typedef BOOL (^XZViewHierarchyEnumerator)(__kindof UIView *subview, NSInteger hierarchy, BOOL *stop);

@interface UIView (XZKit)

/// 遍历当前视图的层级，包括自身。
/// @code
/// // 遍历 self.view 的子视图，遍历深度 2 层。
/// [self.view xz_enumerateHierarchy:^BOOL(UIView *subview, NSInteger hierarchy, BOOL *stop) {
///     XZPrint(@"%ld: <%@, %p>", hierarchy, NSStringFromClass(subview.class), subview);
///     return hierarchy < 2;
/// }];
/// @endcode
/// @param enumerator 遍历时执行的块函数
- (void)xz_enumerateHierarchy:(NS_NOESCAPE XZViewHierarchyEnumerator)enumerator NS_SWIFT_NAME(enumerateHierarchy(_:));

/// 获取当前视图的图片快照。
///
/// @param afterUpdates 是否等待视图执行已添加但是未执行的更新。
/// @return 视图快照图片。
- (nullable UIImage *)xz_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates NS_SWIFT_NAME(snapshotImage(afterScreenUpdates:));

@end

@interface UIView (XZDescription)

/// 获取当前视图及所有层级的描述。
/// @note 字符串格式与 recursiveDescription 类似，但是为了方便查看，仅附带的视图的地址和 frame 信息。
@property (nonatomic, copy, readonly) NSString *xz_description NS_SWIFT_NAME(hierarchyDescription);

@end

@interface UILabel (XZDescription)
@end

@interface UIImageView (XZDescription)
@end


NS_ASSUME_NONNULL_END
